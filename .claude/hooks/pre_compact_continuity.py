#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""PreCompact Continuity Hook (Python port).

Parses transcript and generates auto-handoff before context compaction.
2s faster than TypeScript version.

Input: JSON with trigger ('manual'|'auto'), session_id, transcript_path
Output: JSON with continue: true, systemMessage
"""

from __future__ import annotations

import json
import os
import re
import sys
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


@dataclass
class TodoItem:
    """A todo item from TodoWrite."""
    id: str
    content: str
    status: str  # 'pending' | 'in_progress' | 'completed'


@dataclass
class ToolCall:
    """A tool call from the transcript."""
    name: str
    timestamp: str | None = None
    input: dict[str, Any] | None = None
    success: bool = True


@dataclass
class TranscriptSummary:
    """Summary extracted from a transcript."""
    last_todos: list[TodoItem] = field(default_factory=list)
    recent_tool_calls: list[ToolCall] = field(default_factory=list)
    last_assistant_message: str = ""
    files_modified: list[str] = field(default_factory=list)
    errors_encountered: list[str] = field(default_factory=list)


def parse_transcript(transcript_path: Path) -> TranscriptSummary:
    """Parse a JSONL transcript file and extract high-signal data."""
    summary = TranscriptSummary()

    if not transcript_path.exists():
        return summary

    all_tool_calls: list[ToolCall] = []
    modified_files: set[str] = set()
    errors: list[str] = []
    last_todo_state: list[TodoItem] = []
    last_assistant = ""

    try:
        content = transcript_path.read_text()
    except Exception:
        return summary

    for line in content.split('\n'):
        line = line.strip()
        if not line:
            continue

        try:
            entry = json.loads(line)
        except json.JSONDecodeError:
            continue

        # Extract last assistant message
        if entry.get("role") == "assistant" and isinstance(entry.get("content"), str):
            last_assistant = entry["content"]
        elif entry.get("type") == "assistant" and isinstance(entry.get("content"), str):
            last_assistant = entry["content"]

        # Extract tool calls
        tool_name = entry.get("tool_name") or (entry.get("name") if entry.get("type") == "tool_use" else None)
        if tool_name:
            tool_call = ToolCall(
                name=tool_name,
                timestamp=entry.get("timestamp"),
                input=entry.get("tool_input"),
                success=True
            )

            # Check for TodoWrite to capture state
            if tool_name.lower() == "todowrite":
                tool_input = entry.get("tool_input", {})
                todos = tool_input.get("todos", [])
                last_todo_state = [
                    TodoItem(
                        id=t.get("id", f"todo-{i}"),
                        content=t.get("content", ""),
                        status=t.get("status", "pending")
                    )
                    for i, t in enumerate(todos)
                ]

            # Track file modifications
            if tool_name.lower() in ("edit", "write"):
                tool_input = entry.get("tool_input", {})
                file_path = tool_input.get("file_path") or tool_input.get("path")
                if file_path and isinstance(file_path, str):
                    modified_files.add(file_path)

            # Track Bash commands
            if tool_name.lower() == "bash":
                tool_input = entry.get("tool_input", {})
                if tool_input.get("command"):
                    tool_call.input = {"command": tool_input["command"]}

            all_tool_calls.append(tool_call)

        # Extract tool results and check for failures
        if entry.get("type") == "tool_result" or entry.get("tool_result") is not None:
            result = entry.get("tool_result", {})

            if isinstance(result, dict):
                exit_code = result.get("exit_code") or result.get("exitCode")
                if exit_code is not None and exit_code != 0:
                    if all_tool_calls:
                        all_tool_calls[-1].success = False

                    error_msg = result.get("stderr") or result.get("error") or "Command failed"
                    last_tool = all_tool_calls[-1] if all_tool_calls else None
                    command = (last_tool.input or {}).get("command", "unknown") if last_tool else "unknown"
                    errors.append(f"{command}: {error_msg[:200]}")

            if entry.get("error"):
                errors.append(entry["error"][:200])
                if all_tool_calls:
                    all_tool_calls[-1].success = False

    # Populate summary
    summary.last_todos = last_todo_state
    summary.recent_tool_calls = all_tool_calls[-5:]  # Last 5
    summary.last_assistant_message = last_assistant[:500]
    summary.files_modified = list(modified_files)
    summary.errors_encountered = errors[-5:]  # Last 5

    return summary


def generate_auto_handoff(summary: TranscriptSummary, session_name: str) -> str:
    """Generate a markdown auto-handoff document from a transcript summary."""
    timestamp = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    lines: list[str] = []

    # YAML frontmatter
    lines.append("---")
    lines.append(f"date: {timestamp}")
    lines.append("type: auto-handoff")
    lines.append("trigger: pre-compact-auto")
    lines.append(f"session: {session_name}")
    lines.append("---")
    lines.append("")

    # Header
    lines.append("# Auto-Handoff (PreCompact)")
    lines.append("")
    lines.append("This handoff was automatically generated before context compaction.")
    lines.append("")

    # In Progress section
    lines.append("## In Progress")
    lines.append("")
    if summary.last_todos:
        in_progress = [t for t in summary.last_todos if t.status == "in_progress"]
        pending = [t for t in summary.last_todos if t.status == "pending"]
        completed = [t for t in summary.last_todos if t.status == "completed"]

        if in_progress:
            lines.append("**Active:**")
            for t in in_progress:
                lines.append(f"- [>] {t.content}")
            lines.append("")

        if pending:
            lines.append("**Pending:**")
            for t in pending:
                lines.append(f"- [ ] {t.content}")
            lines.append("")

        if completed:
            lines.append("**Completed this session:**")
            for t in completed:
                lines.append(f"- [x] {t.content}")
            lines.append("")
    else:
        lines.append("No TodoWrite state captured.")
        lines.append("")

    # Recent Actions
    lines.append("## Recent Actions")
    lines.append("")
    if summary.recent_tool_calls:
        for tc in summary.recent_tool_calls:
            status = "OK" if tc.success else "FAILED"
            input_summary = ""
            if tc.input:
                input_summary = f" - {json.dumps(tc.input)[:80]}..."
            lines.append(f"- {tc.name} [{status}]{input_summary}")
    else:
        lines.append("No tool calls recorded.")
    lines.append("")

    # Files Modified
    lines.append("## Files Modified")
    lines.append("")
    if summary.files_modified:
        for f in summary.files_modified:
            lines.append(f"- {f}")
    else:
        lines.append("No files modified.")
    lines.append("")

    # Errors
    if summary.errors_encountered:
        lines.append("## Errors Encountered")
        lines.append("")
        for e in summary.errors_encountered:
            lines.append("```")
            lines.append(e)
            lines.append("```")
        lines.append("")

    # Last Context
    lines.append("## Last Context")
    lines.append("")
    if summary.last_assistant_message:
        lines.append("```")
        lines.append(summary.last_assistant_message)
        if len(summary.last_assistant_message) >= 500:
            lines.append("[... truncated]")
        lines.append("```")
    else:
        lines.append("No assistant message captured.")
    lines.append("")

    # Suggested Next Steps
    lines.append("## Suggested Next Steps")
    lines.append("")
    lines.append('1. Review the "In Progress" section for current task state')
    lines.append('2. Check "Errors Encountered" if debugging issues')
    lines.append("3. Read modified files to understand recent changes")
    lines.append("4. Continue from where session left off")
    lines.append("")

    return '\n'.join(lines)


def generate_auto_summary(project_dir: Path, session_id: str) -> str | None:
    """Generate brief auto-summary from caches."""
    timestamp = datetime.now(timezone.utc).isoformat()
    lines: list[str] = []

    # Read edited files from PostToolUse cache
    cache_dir = project_dir / ".claude" / "tsc-cache" / (session_id or "default")
    edited_files_path = cache_dir / "edited-files.log"

    edited_files: list[str] = []
    if edited_files_path.exists():
        try:
            content = edited_files_path.read_text()
            seen: set[str] = set()
            for line in content.split('\n'):
                if line.strip():
                    parts = line.split(':')
                    if len(parts) > 1:
                        filepath = parts[1].replace(str(project_dir) + '/', '')
                        if filepath and filepath not in seen:
                            seen.add(filepath)
                            edited_files.append(filepath)
        except Exception:
            pass

    # Read build attempts
    git_claude_dir = project_dir / ".git" / "claude" / "branches"
    build_passed = 0
    build_failed = 0

    if git_claude_dir.exists():
        try:
            for branch in git_claude_dir.iterdir():
                attempts_file = branch / "attempts.jsonl"
                if attempts_file.exists():
                    for line in attempts_file.read_text().split('\n'):
                        if line.strip():
                            try:
                                attempt = json.loads(line)
                                if attempt.get("type") == "build_pass":
                                    build_passed += 1
                                if attempt.get("type") == "build_fail":
                                    build_failed += 1
                            except Exception:
                                pass
        except Exception:
            pass

    # Only generate if we have something
    if not edited_files and build_passed == 0 and build_failed == 0:
        return None

    lines.append(f"\n## Session Auto-Summary ({timestamp})")

    if edited_files:
        preview = ', '.join(edited_files[:10])
        if len(edited_files) > 10:
            preview += f" (+{len(edited_files) - 10} more)"
        lines.append(f"- Files changed: {preview}")

    if build_passed > 0 or build_failed > 0:
        lines.append(f"- Build/test: {build_passed} passed, {build_failed} failed")

    return '\n'.join(lines)


def append_to_ledger(ledger_path: Path, summary: str) -> None:
    """Append summary to ledger file."""
    try:
        content = ledger_path.read_text()

        # Find ## State and insert before "Now:"
        now_match = re.search(r'(\n-\s*Now:)', content)
        if now_match and now_match.start():
            content = content[:now_match.start()] + summary + content[now_match.start():]
        else:
            # Find next ## section after State
            state_idx = content.find('## State')
            if state_idx > 0:
                next_section = content.find('\n## ', state_idx + 1)
                if next_section > 0:
                    content = content[:next_section] + summary + '\n' + content[next_section:]
                else:
                    content += summary
            else:
                content += summary

        ledger_path.write_text(content)
    except Exception:
        pass


def get_project_dir() -> Path:
    """Get project directory."""
    return Path(os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd()))


def main() -> None:
    """Main hook entry point."""
    input_data = json.load(sys.stdin)
    project_dir = get_project_dir()

    trigger = input_data.get("trigger", "auto")
    session_id = input_data.get("session_id", "")
    transcript_path_str = input_data.get("transcript_path", "")

    # Find existing ledger
    ledger_dir = project_dir / "thoughts" / "ledgers"
    if not ledger_dir.exists():
        output = {
            "continue": True,
            "systemMessage": "[PreCompact] No ledger found. Create one? /continuity_ledger"
        }
        print(json.dumps(output))
        return

    ledger_files = sorted(
        [f for f in ledger_dir.iterdir()
         if f.name.startswith("CONTINUITY_CLAUDE-") and f.suffix == ".md"],
        key=lambda f: f.stat().st_mtime,
        reverse=True
    )

    if not ledger_files:
        output = {
            "continue": True,
            "systemMessage": "[PreCompact] No ledger found. Create one? /continuity_ledger"
        }
        print(json.dumps(output))
        return

    ledger_path = ledger_files[0]
    session_name = ledger_path.stem.replace("CONTINUITY_CLAUDE-", "")

    if trigger == "auto":
        handoff_file = ""

        if transcript_path_str and Path(transcript_path_str).exists():
            # Parse transcript and generate handoff
            summary = parse_transcript(Path(transcript_path_str))
            handoff_content = generate_auto_handoff(summary, session_name)

            # Ensure handoff directory exists
            handoff_dir = project_dir / "thoughts" / "shared" / "handoffs" / session_name
            handoff_dir.mkdir(parents=True, exist_ok=True)

            # Write handoff with timestamp
            timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H-%M-%S")
            handoff_file = f"auto-handoff-{timestamp}.md"
            handoff_path = handoff_dir / handoff_file
            handoff_path.write_text(handoff_content)

            # Also append brief summary to ledger
            brief_summary = generate_auto_summary(project_dir, session_id)
            if brief_summary:
                append_to_ledger(ledger_path, brief_summary)
        else:
            # Fallback: no transcript
            brief_summary = generate_auto_summary(project_dir, session_id)
            if brief_summary:
                append_to_ledger(ledger_path, brief_summary)

        message = (
            f"[PreCompact:auto] Created {handoff_file} in thoughts/shared/handoffs/{session_name}/"
            if handoff_file
            else f"[PreCompact:auto] Session summary auto-appended to {ledger_path.name}"
        )

        output = {"continue": True, "systemMessage": message}
        print(json.dumps(output))
    else:
        # Manual compact: just inform
        output = {
            "continue": True,
            "systemMessage": f"[PreCompact] Consider updating ledger before compacting: /continuity_ledger\nLedger: {ledger_path.name}"
        }
        print(json.dumps(output))


if __name__ == "__main__":
    main()
