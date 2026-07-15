#!/usr/bin/env python3
"""
Unit tests for Smart Resume intelligence module

Tests cover:
1. load_session_context() - main entry point
2. _load_session_state() - session state extraction
3. _load_active_tasks() - priority-based task loading
4. _load_recent_decisions() - high-impact decision filtering
5. _load_key_events() - critical event filtering
6. _estimate_tokens() - token estimation accuracy
7. _generate_context_summary() - markdown generation
8. Graceful degradation - repository unavailability
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import unittest
from unittest.mock import patch, MagicMock
import time


class TestSmartResumeLoadSessionContext(unittest.TestCase):
    """Test load_session_context() main function"""

    @patch('intelligence.smart_resume.EventRepository')
    @patch('intelligence.smart_resume.DecisionRepository')
    @patch('intelligence.smart_resume.TaskRepository')
    @patch('intelligence.smart_resume.SessionRepository')
    @patch('intelligence.smart_resume.HAS_REPOS', True)
    def test_load_session_context_valid_session(
        self, mock_session_repo, mock_task_repo, mock_decision_repo, mock_event_repo
    ):
        """Test loading context for a valid session"""
        from intelligence.smart_resume import load_session_context

        mock_session_instance = MagicMock()
        mock_session_instance.get.return_value = {
            'id': 'test-session-001',
            'health_status': '🟢',
            'message_count': 15,
            'mode': 'BUILD',
            'scope': 'MEDIUM',
            'task_title': 'Test Task',
            'task_reference': 'TASK-001',
            'task_phase': 'implementation',
            'task_progress': 50,
            'branch': 'feature/test',
            'started_at': '2026-01-27T10:00:00',
            'ended_at': ''
        }
        mock_session_repo.return_value = mock_session_instance

        mock_task_instance = MagicMock()
        mock_task_instance.list.return_value = [
            {'id': 1, 'title': 'Active Task', 'status': 'in_progress', 'priority': 1}
        ]
        mock_task_repo.return_value = mock_task_instance

        mock_decision_instance = MagicMock()
        mock_decision_instance.list.return_value = []
        mock_decision_repo.return_value = mock_decision_instance

        mock_event_instance = MagicMock()
        mock_event_instance.list.return_value = []
        mock_event_repo.return_value = mock_event_instance

        result = load_session_context('test-session-001')

        self.assertIn('summary', result)
        self.assertIn('token_count', result)
        self.assertIn('load_time_ms', result)
        self.assertIn('components', result)
        self.assertIn('metadata', result)

        self.assertEqual(result['metadata']['session_id'], 'test-session-001')
        self.assertEqual(result['metadata']['health'], '🟢')

    @patch('intelligence.smart_resume.SessionRepository')
    @patch('intelligence.smart_resume.HAS_REPOS', True)
    def test_load_session_context_missing_session(self, mock_session_repo):
        """Test ValueError raised for missing session"""
        from intelligence.smart_resume import load_session_context

        mock_session_instance = MagicMock()
        mock_session_instance.get.return_value = None
        mock_session_repo.return_value = mock_session_instance

        with self.assertRaises(ValueError) as ctx:
            load_session_context('nonexistent-session')

        self.assertIn('not found', str(ctx.exception))

    @patch('intelligence.smart_resume.HAS_REPOS', False)
    def test_load_session_context_no_repos(self):
        """Test RuntimeError when repositories unavailable"""
        from intelligence.smart_resume import load_session_context

        with self.assertRaises(RuntimeError) as ctx:
            load_session_context('any-session')

        self.assertIn('Repositories not available', str(ctx.exception))

    @patch('intelligence.smart_resume.EventRepository')
    @patch('intelligence.smart_resume.DecisionRepository')
    @patch('intelligence.smart_resume.TaskRepository')
    @patch('intelligence.smart_resume.SessionRepository')
    @patch('intelligence.smart_resume.HAS_REPOS', True)
    def test_load_session_context_performance_target(
        self, mock_session_repo, mock_task_repo, mock_decision_repo, mock_event_repo
    ):
        """Test that load time is under 100ms target"""
        from intelligence.smart_resume import load_session_context

        mock_session_instance = MagicMock()
        mock_session_instance.get.return_value = {
            'id': 'perf-test',
            'health_status': '🟢',
            'mode': 'BUILD',
            'scope': 'SMALL'
        }
        mock_session_repo.return_value = mock_session_instance

        for mock_repo in [mock_task_repo, mock_decision_repo, mock_event_repo]:
            mock_instance = MagicMock()
            mock_instance.list.return_value = []
            mock_repo.return_value = mock_instance

        result = load_session_context('perf-test')

        self.assertLess(result['load_time_ms'], 100, "Load time exceeded 100ms target")


class TestLoadSessionState(unittest.TestCase):
    """Test _load_session_state() function"""

    def test_load_session_state_complete(self):
        """Test extraction of complete session state"""
        from intelligence.smart_resume import _load_session_state

        session = {
            'id': 'session-123',
            'health_status': '🟡',
            'message_count': 35,
            'mode': 'DEBUG',
            'scope': 'LARGE',
            'task_title': 'Fix Critical Bug',
            'task_reference': 'BUG-999',
            'task_phase': 'debugging',
            'task_progress': 75,
            'branch': 'fix/critical',
            'started_at': '2026-01-27T09:00:00',
            'ended_at': '2026-01-27T12:00:00'
        }

        result = _load_session_state(session, token_limit=400)

        self.assertEqual(result['id'], 'session-123')
        self.assertEqual(result['health'], '🟡')
        self.assertEqual(result['message_count'], 35)
        self.assertEqual(result['mode'], 'DEBUG')
        self.assertEqual(result['scope'], 'LARGE')
        self.assertEqual(result['task']['title'], 'Fix Critical Bug')
        self.assertEqual(result['task']['progress'], 75)
        self.assertEqual(result['branch'], 'fix/critical')

    def test_load_session_state_defaults(self):
        """Test default values for missing fields"""
        from intelligence.smart_resume import _load_session_state

        session = {'id': 'minimal-session'}

        result = _load_session_state(session, token_limit=400)

        self.assertEqual(result['health'], '🟢')
        self.assertEqual(result['message_count'], 0)
        self.assertEqual(result['mode'], 'BUILD')
        self.assertEqual(result['scope'], 'MEDIUM')
        self.assertEqual(result['task']['title'], 'Unknown')


class TestLoadActiveTasks(unittest.TestCase):
    """Test _load_active_tasks() function"""

    def test_load_active_tasks_priority_ordering(self):
        """Test in_progress tasks come before pending"""
        from intelligence.smart_resume import _load_active_tasks

        mock_repo = MagicMock()
        mock_repo.list.return_value = [
            {'id': 1, 'title': 'Pending Task', 'status': 'pending', 'priority': 1},
            {'id': 2, 'title': 'Active Task', 'status': 'in_progress', 'priority': 2},
            {'id': 3, 'title': 'Another Pending', 'status': 'pending', 'priority': 0},
        ]

        result = _load_active_tasks('session-1', mock_repo, token_limit=1200)

        self.assertEqual(len(result), 3)
        self.assertEqual(result[0]['status'], 'in_progress')

    def test_load_active_tasks_token_truncation(self):
        """Test tasks are truncated to fit token limit"""
        from intelligence.smart_resume import _load_active_tasks

        mock_repo = MagicMock()
        mock_repo.list.return_value = [
            {'id': i, 'title': f'Task {i}', 'status': 'pending', 'priority': 2}
            for i in range(50)
        ]

        result = _load_active_tasks('session-1', mock_repo, token_limit=200)

        self.assertLess(len(result), 50)

    def test_load_active_tasks_empty(self):
        """Test handling no active tasks"""
        from intelligence.smart_resume import _load_active_tasks

        mock_repo = MagicMock()
        mock_repo.list.return_value = []

        result = _load_active_tasks('session-1', mock_repo, token_limit=1200)

        self.assertEqual(result, [])


class TestLoadRecentDecisions(unittest.TestCase):
    """Test _load_recent_decisions() function"""

    def test_load_recent_decisions_high_impact_only(self):
        """Test filtering for high/critical impact decisions"""
        from intelligence.smart_resume import _load_recent_decisions

        mock_repo = MagicMock()
        mock_repo.list.return_value = [
            {'id': 1, 'title': 'Critical Decision', 'decision': 'A', 'impact': 'critical', 'decided_at': '2026-01-27T11:00:00'},
            {'id': 2, 'title': 'High Decision', 'decision': 'B', 'impact': 'high', 'decided_at': '2026-01-27T10:00:00'},
            {'id': 3, 'title': 'Medium Decision', 'decision': 'C', 'impact': 'medium', 'decided_at': '2026-01-27T09:00:00'},
            {'id': 4, 'title': 'Low Decision', 'decision': 'D', 'impact': 'low', 'decided_at': '2026-01-27T08:00:00'},
        ]

        result = _load_recent_decisions('session-1', mock_repo, token_limit=800)

        self.assertEqual(len(result), 2)
        self.assertTrue(all(d['impact'] in ['high', 'critical'] for d in result))
        self.assertEqual(result[0]['title'], 'Critical Decision')

    def test_load_recent_decisions_sorted_by_time(self):
        """Test decisions sorted most recent first"""
        from intelligence.smart_resume import _load_recent_decisions

        mock_repo = MagicMock()
        mock_repo.list.return_value = [
            {'id': 1, 'title': 'Older', 'decision': 'A', 'impact': 'high', 'decided_at': '2026-01-27T08:00:00'},
            {'id': 2, 'title': 'Newer', 'decision': 'B', 'impact': 'high', 'decided_at': '2026-01-27T12:00:00'},
        ]

        result = _load_recent_decisions('session-1', mock_repo, token_limit=800)

        self.assertEqual(result[0]['title'], 'Newer')


class TestLoadKeyEvents(unittest.TestCase):
    """Test _load_key_events() function"""

    def test_load_key_events_filters_important(self):
        """Test filtering for error/warning/blocker/milestone events"""
        from intelligence.smart_resume import _load_key_events

        mock_repo = MagicMock()
        mock_repo.list.return_value = [
            {'hook_name': 'error_handler', 'timestamp': '2026-01-27T11:00:00', 'status': 'error'},
            {'hook_name': 'warning_check', 'timestamp': '2026-01-27T10:00:00', 'status': 'warning'},
            {'hook_name': 'blocker_detected', 'timestamp': '2026-01-27T09:00:00', 'status': 'error'},
            {'hook_name': 'milestone_reached', 'timestamp': '2026-01-27T08:00:00', 'status': 'success'},
            {'hook_name': 'task_complete', 'timestamp': '2026-01-27T07:00:00', 'status': 'success'},
            {'hook_name': 'regular_event', 'timestamp': '2026-01-27T06:00:00', 'status': 'success'},
        ]

        result = _load_key_events('session-1', mock_repo, token_limit=600)

        self.assertEqual(len(result), 5)
        self.assertFalse(any(e['hook_name'] == 'regular_event' for e in result))

    def test_load_key_events_max_10(self):
        """Test max 10 events returned"""
        from intelligence.smart_resume import _load_key_events

        mock_repo = MagicMock()
        mock_repo.list.return_value = [
            {'hook_name': f'error_{i}', 'timestamp': f'2026-01-27T{i:02d}:00:00', 'status': 'error'}
            for i in range(20)
        ]

        result = _load_key_events('session-1', mock_repo, token_limit=5000)

        self.assertLessEqual(len(result), 10)


class TestEstimateTokens(unittest.TestCase):
    """Test _estimate_tokens() function"""

    def test_estimate_tokens_accuracy(self):
        """Test token estimation (chars / 4)"""
        from intelligence.smart_resume import _estimate_tokens

        text = "This is a test string with 40 characters"
        expected = len(text) // 4

        result = _estimate_tokens(text)

        self.assertEqual(result, expected)

    def test_estimate_tokens_empty(self):
        """Test empty string returns 0"""
        from intelligence.smart_resume import _estimate_tokens

        result = _estimate_tokens("")

        self.assertEqual(result, 0)

    def test_estimate_tokens_long_text(self):
        """Test longer text estimation"""
        from intelligence.smart_resume import _estimate_tokens

        text = "x" * 4000
        expected = 1000

        result = _estimate_tokens(text)

        self.assertEqual(result, expected)


class TestGenerateContextSummary(unittest.TestCase):
    """Test _generate_context_summary() function"""

    def test_generate_context_summary_format(self):
        """Test markdown summary generation"""
        from intelligence.smart_resume import _generate_context_summary

        session = {'id': 'test-session'}
        components = {
            'session_state': {
                'id': 'test-session',
                'health': '🟢',
                'mode': 'BUILD',
                'scope': 'MEDIUM',
                'task': {
                    'title': 'Test Task',
                    'phase': 'implementation',
                    'progress': 50
                },
                'branch': 'main'
            },
            'active_tasks': [
                {'id': 1, 'title': 'Task 1', 'status': 'in_progress', 'priority': 1}
            ],
            'decisions': [
                {'title': 'Decision 1', 'decision': 'Use Redis', 'impact': 'high'}
            ],
            'events': [
                {'hook_name': 'milestone', 'status': 'success'}
            ],
            'completed_summary': {'total_completed': 5}
        }

        result = _generate_context_summary(session, components)

        self.assertIn('# Session Resume:', result)
        self.assertIn('🟢', result)
        self.assertIn('BUILD', result)
        self.assertIn('Test Task', result)
        self.assertIn('## Active Tasks', result)
        self.assertIn('## Recent Decisions', result)
        self.assertIn('## Key Events', result)
        self.assertIn('## Completed: 5 tasks', result)

    def test_generate_context_summary_empty_components(self):
        """Test summary with empty components"""
        from intelligence.smart_resume import _generate_context_summary

        session = {'id': 'empty-session'}
        components = {
            'session_state': {
                'id': 'empty-session',
                'health': '🟢',
                'mode': 'BUILD',
                'scope': 'SMALL',
                'task': {'title': 'Unknown', 'phase': 'planning', 'progress': 0},
                'branch': 'main'
            },
            'active_tasks': [],
            'decisions': [],
            'events': [],
            'completed_summary': {'total_completed': 0}
        }

        result = _generate_context_summary(session, components)

        self.assertIn('No active tasks', result)
        self.assertIn('No high-impact decisions recorded', result)
        self.assertIn('No critical events', result)


class TestGracefulDegradation(unittest.TestCase):
    """Test graceful degradation scenarios"""

    @patch('intelligence.smart_resume.EventRepository')
    @patch('intelligence.smart_resume.DecisionRepository')
    @patch('intelligence.smart_resume.TaskRepository')
    @patch('intelligence.smart_resume.SessionRepository')
    @patch('intelligence.smart_resume.HAS_REPOS', True)
    def test_repository_exception_handling(
        self, mock_session_repo, mock_task_repo, mock_decision_repo, mock_event_repo
    ):
        """Test handling of repository exceptions"""
        from intelligence.smart_resume import load_session_context

        mock_session_instance = MagicMock()
        mock_session_instance.get.return_value = {
            'id': 'test-session',
            'health_status': '🟢',
            'mode': 'BUILD',
            'scope': 'MEDIUM'
        }
        mock_session_repo.return_value = mock_session_instance

        mock_task_instance = MagicMock()
        mock_task_instance.list.side_effect = Exception("Database connection failed")
        mock_task_repo.return_value = mock_task_instance

        with self.assertRaises(Exception):
            load_session_context('test-session')


class TestPerformanceBenchmarks(unittest.TestCase):
    """Performance benchmark tests"""

    @patch('intelligence.smart_resume.EventRepository')
    @patch('intelligence.smart_resume.DecisionRepository')
    @patch('intelligence.smart_resume.TaskRepository')
    @patch('intelligence.smart_resume.SessionRepository')
    @patch('intelligence.smart_resume.HAS_REPOS', True)
    def test_load_context_benchmark(
        self, mock_session_repo, mock_task_repo, mock_decision_repo, mock_event_repo
    ):
        """Benchmark load_session_context performance"""
        from intelligence.smart_resume import load_session_context

        mock_session_instance = MagicMock()
        mock_session_instance.get.return_value = {
            'id': 'bench-session',
            'health_status': '🟢',
            'mode': 'BUILD',
            'scope': 'LARGE'
        }
        mock_session_repo.return_value = mock_session_instance

        for mock_repo in [mock_task_repo, mock_decision_repo, mock_event_repo]:
            mock_instance = MagicMock()
            mock_instance.list.return_value = [
                {'id': i, 'title': f'Item {i}', 'status': 'pending', 'priority': 2,
                 'hook_name': 'test', 'timestamp': '2026-01-27T10:00:00',
                 'impact': 'high', 'decision': 'Test', 'decided_at': '2026-01-27T10:00:00'}
                for i in range(20)
            ]
            mock_repo.return_value = mock_instance

        iterations = 10
        times = []

        for _ in range(iterations):
            start = time.perf_counter()
            load_session_context('bench-session')
            elapsed = (time.perf_counter() - start) * 1000
            times.append(elapsed)

        avg_time = sum(times) / len(times)
        max_time = max(times)

        print(f"\n  Benchmark: avg={avg_time:.2f}ms, max={max_time:.2f}ms")
        self.assertLess(avg_time, 100, f"Average load time {avg_time:.2f}ms exceeded 100ms target")


if __name__ == '__main__':
    print("\n✅ Running Smart Resume Test Suite\n")
    unittest.main(verbosity=2)
