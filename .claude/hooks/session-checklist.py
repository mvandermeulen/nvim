#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "pyyaml>=6.0",
# ]
# ///
"""
Session Start Checklist Enforcer

Runs as a synchronous UserPromptSubmit hook. On the first few messages of a
session, checks whether the required planning files have been created and
populated. If not, outputs a structured reminder to Claude's context.

Checks performed (message 1-3 only):
  1. current-session.yaml has a non-empty task.title
  2. SESSION_STATE.md has been updated (no template placeholders)
  3. At least one plan doc exists in .claude/docs/plans/

Always exits 0 — never blocks the user prompt.
"""

import sys
import json
from pathlib import Path
import importlib

hooks_dir = Path(__file__).parent
if str(hooks_dir) not in sys.path:
    sys.path.insert(0, str(hooks_dir))

directories = importlib.import_module('directories')

D: directories.Directories = directories.DIRECTORIES  # Alias for easier access


ENFORCE_UNTIL_MESSAGE = 3

SESSION_STATE_TEMPLATE_MARKERS = [
    "[Current task being worked on]",
    "[Timestamp]",
    "[Specific next step]",
]


def _message_count() -> int:
    try:
        import yaml
        with open(D.current_session_file) as f:
            state = yaml.safe_load(f)
        return state.get("session", {}).get("message_count", 0)
    except Exception:
        return 0


def _check_session_yaml() -> tuple[bool, str]:
    if not D.current_session_file.exists():
        return False, "current-session.yaml not found"
    try:
        import yaml
        with open(D.current_session_file) as f:
            state = yaml.safe_load(f)
        title = state.get("task", {}).get("title", "").strip()
        if not title:
            return False, "task.title is empty in current-session.yaml"
        return True, f"task set: {title}"
    except Exception as e:
        return False, f"could not parse current-session.yaml: {e}"


def _check_session_state() -> tuple[bool, str]:
    if not D.session_state_file.exists():
        return False, "SESSION_STATE.md not found"
    content = D.session_state_file.read_text()
    for marker in SESSION_STATE_TEMPLATE_MARKERS:
        if marker in content:
            return False, "SESSION_STATE.md still contains template placeholders"
    return True, "SESSION_STATE.md populated"


def _check_plan_doc_exists() -> tuple[bool, str]:
    if not D.plans.exists():
        return False, ".claude/docs/plans/ directory not found"
    plans = sorted(D.plans.glob("[0-9][0-9][0-9][0-9]-*.md"))
    if not plans:
        return False, "no numbered plan doc found in .claude/docs/plans/"
    return True, f"plan doc present: {plans[-1].name}"


def main() -> None:
    count = _message_count()
    if count > ENFORCE_UNTIL_MESSAGE:
        sys.exit(0)

    failures: list[str] = []

    ok, msg = _check_session_yaml()
    if not ok:
        failures.append(f"• session yaml: {msg}")

    ok, msg = _check_session_state()
    if not ok:
        failures.append(f"• SESSION_STATE.md: {msg}")

    ok, msg = _check_plan_doc_exists()
    if not ok:
        failures.append(f"• plan doc: {msg}")

    if not failures:
        sys.exit(0)

    print(
        "⚠️  SESSION START CHECKLIST INCOMPLETE\n"
        "Before proceeding with any task, complete the following:\n"
        "\n"
        + "\n".join(failures)
        + "\n\n"
        "Required actions:\n"
        "  1. Update .claude/session/current-session.yaml with task title and scope\n"
        "  2. Create .claude/docs/plans/####-PHASE-MMDDYY-DESCRIPTION.md\n"
        "  3. Create .claude/docs/specs/<task>.md\n"
        "  4. Trigger project-manager agent to update SESSION_STATE.md and DAILY_BACKLOG.md\n"
        "\n"
        "See .claude/docs/SESSION_START_CHECKLIST.md for full requirements.",
        flush=True,
    )
    sys.exit(0)


if __name__ == "__main__":
    main()
