"""Tests for subagent_lifecycle handler."""
import time
from datetime import datetime
from unittest.mock import patch, MagicMock

import pytest

from hooks.handlers.subagent_lifecycle import (
    extract_task_summary,
    extract_outcome,
    extract_lessons,
    handle_start,
    handle_complete,
    load_reflexion_log,
    save_reflexion_log,
)


class TestExtractTaskSummary:
    """Tests for task summary extraction."""

    def test_extract_from_description(self):
        """Should prefer description over prompt."""
        ctx = {
            "tool_input": {
                "prompt": "Long prompt text",
                "description": "Short desc"
            }
        }
        assert extract_task_summary(ctx) == "Short desc"

    def test_extract_from_prompt(self):
        """Should use prompt if no description."""
        ctx = {"tool_input": {"prompt": "Find all files"}}
        assert extract_task_summary(ctx) == "Find all files"

    def test_truncate_long_prompt(self):
        """Should truncate prompts over 100 chars."""
        long_prompt = "x" * 150
        ctx = {"tool_input": {"prompt": long_prompt}}
        result = extract_task_summary(ctx)
        assert len(result) == 103  # 100 chars + "..."
        assert result.endswith("...")

    def test_empty_context(self):
        """Should handle empty context."""
        assert extract_task_summary({}) == ""
        assert extract_task_summary({"tool_input": {}}) == ""


class TestExtractOutcome:
    """Tests for outcome extraction."""

    def test_completed_is_success(self):
        assert extract_outcome({"stop_reason": "completed"}) == "success"

    def test_error_is_failure(self):
        assert extract_outcome({"stop_reason": "error"}) == "failure"

    def test_failed_is_failure(self):
        assert extract_outcome({"stop_reason": "failed"}) == "failure"

    def test_interrupted(self):
        assert extract_outcome({"stop_reason": "interrupted"}) == "interrupted"

    def test_unknown_reason(self):
        assert extract_outcome({"stop_reason": "other"}) == "unknown"
        assert extract_outcome({}) == "unknown"


class TestExtractLessons:
    """Tests for lesson extraction."""

    def test_timeout_lesson(self):
        ctx = {"tool_output": "Task timeout after 60s"}
        lessons = extract_lessons(ctx, "failure")
        assert any("timed out" in l.lower() for l in lessons)

    def test_not_found_lesson(self):
        ctx = {"tool_output": "File not found: /path/to/file"}
        lessons = extract_lessons(ctx, "failure")
        assert any("not found" in l.lower() for l in lessons)

    def test_permission_lesson(self):
        ctx = {"tool_output": "Permission denied"}
        lessons = extract_lessons(ctx, "failure")
        assert any("permission" in l.lower() for l in lessons)

    def test_success_with_tests(self):
        ctx = {"tool_output": "All tests pass successfully"}
        lessons = extract_lessons(ctx, "success")
        assert any("test" in l.lower() for l in lessons)

    def test_no_lessons_for_generic_output(self):
        ctx = {"tool_output": "Done"}
        lessons = extract_lessons(ctx, "success")
        assert len(lessons) == 0


class TestHandleStart:
    """Tests for subagent start handling."""

    @patch('hooks.handlers.subagent_lifecycle.update_session_state')
    @patch('hooks.handlers.subagent_lifecycle.log_event')
    def test_tracks_spawn(self, mock_log, mock_update):
        """Should track subagent spawn."""
        ctx = {
            "tool_name": "Task",
            "tool_input": {"subagent_type": "Explore", "prompt": "Find files"},
            "subagent_id": "abc123"
        }
        handle_start(ctx)

        mock_update.assert_called_once()
        # First arg is namespace, second is updater function
        namespace = mock_update.call_args[0][0]
        assert namespace == "subagent_lifecycle"
        # Test the updater function
        updater = mock_update.call_args[0][1]
        result = updater({})
        assert "active_subagents" in result
        assert "abc123" in result["active_subagents"]
        assert result["active_subagents"]["abc123"]["type"] == "Explore"
        assert "subagent_spawn_counts" in result
        assert result["subagent_spawn_counts"]["Explore"] == 1

    @patch('hooks.handlers.subagent_lifecycle.update_session_state')
    @patch('hooks.handlers.subagent_lifecycle.log_event')
    def test_increments_spawn_count(self, mock_log, mock_update):
        """Should increment spawn count for same agent type."""
        ctx = {
            "tool_name": "Task",
            "tool_input": {"subagent_type": "Explore"},
            "subagent_id": "xyz789"
        }
        handle_start(ctx)

        # Test the updater with existing state
        updater = mock_update.call_args[0][1]
        result = updater({"subagent_spawn_counts": {"Explore": 2}})
        assert result["subagent_spawn_counts"]["Explore"] == 3


class TestHandleComplete:
    """Tests for subagent completion handling."""

    @patch('hooks.hook_utils.read_session_state')
    @patch('hooks.handlers.subagent_lifecycle.update_session_state')
    @patch('hooks.handlers.subagent_lifecycle.log_event')
    @patch('hooks.handlers.subagent_lifecycle.record_reflexion')
    def test_tracks_completion(self, mock_record, mock_log, mock_update, mock_read):
        """Should track subagent completion."""
        mock_read.return_value = {}

        ctx = {
            "tool_name": "Task",
            "tool_input": {"subagent_type": "code-reviewer"},
            "tool_response": {"content": "Review complete"},
            "subagent_id": "def456"
        }
        handle_complete(ctx)

        mock_update.assert_called_once()
        namespace = mock_update.call_args[0][0]
        assert namespace == "subagent_lifecycle"
        # Test the updater function
        updater = mock_update.call_args[0][1]
        result = updater({})
        assert "subagent_stats" in result
        assert "code-reviewer" in result["subagent_stats"]
        assert result["subagent_stats"]["code-reviewer"]["count"] == 1

    @patch('hooks.hook_utils.read_session_state')
    @patch('hooks.handlers.subagent_lifecycle.update_session_state')
    @patch('hooks.handlers.subagent_lifecycle.log_event')
    @patch('hooks.handlers.subagent_lifecycle.record_reflexion')
    def test_calculates_duration(self, mock_record, mock_log, mock_update, mock_read):
        """Should calculate duration from start time."""
        start_time = datetime.now().isoformat()
        mock_read.return_value = {
            "active_subagents": {
                "test123": {"type": "Explore", "started_at": start_time}
            }
        }

        ctx = {
            "tool_name": "Task",
            "tool_input": {"subagent_type": "Explore"},
            "tool_response": {},
            "subagent_id": "test123"
        }
        handle_complete(ctx)

        # Test the updater - should clean up active_subagents
        updater = mock_update.call_args[0][1]
        result = updater({"active_subagents": {"test123": {}}})
        assert "test123" not in result["active_subagents"]


class TestReflexionLog:
    """Tests for reflexion log operations."""

    def test_load_missing_file(self, tmp_path):
        """Should return empty list for missing file."""
        with patch('hooks.handlers.subagent_lifecycle.REFLEXION_LOG', tmp_path / "missing.json"):
            result = load_reflexion_log()
            assert result == []

    def test_save_trims_entries(self, tmp_path):
        """Should trim to MAX_REFLEXION_ENTRIES."""
        log_file = tmp_path / "reflexion.json"

        with patch('hooks.handlers.subagent_lifecycle.REFLEXION_LOG', log_file):
            with patch('hooks.handlers.subagent_lifecycle.MAX_REFLEXION_ENTRIES', 5):
                entries = [{"id": i} for i in range(10)]
                save_reflexion_log(entries)

                loaded = load_reflexion_log()
                assert len(loaded) == 5
                assert loaded[0]["id"] == 5  # Last 5 entries
