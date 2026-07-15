#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""
UserPromptSubmit hook: Suggest premortem when user references plan files.

Behavior:
- Detects plan file references in user prompt
- Checks if plan already has "Risk Mitigations (Pre-Mortem)" section
- If not, suggests running /premortem deep <file>
- Non-blocking (suggestive only)

Cross-platform:
- All platforms: Called via `uv run` through hook_launcher.py
- Fallback: If uv not available, uses python3 (or python on Windows)

Uses only standard library - no dependencies.
"""

import json
import re
import sys
from pathlib import Path


# Patterns that suggest implementation intent
IMPLEMENTATION_SIGNALS = [
    r"implement(?:ing)?\s+(?:the\s+)?plan",
    r"start\s+(?:the\s+)?build",
    r"begin\s+implementation",
    r"let'?s\s+build",
    r"execute\s+(?:the\s+)?plan",
    r"work\s+on\s+(?:the\s+)?plan",
    r"follow\s+(?:the\s+)?plan",
]

# Plan file pattern
PLAN_FILE_PATTERN = r"thoughts/shared/plans/[\w\-]+\.md"


def find_plan_files(prompt: str) -> list[str]:
    """Extract plan file paths from prompt."""
    return re.findall(PLAN_FILE_PATTERN, prompt)


def has_implementation_intent(prompt: str) -> bool:
    """Check if prompt suggests implementation intent."""
    prompt_lower = prompt.lower()
    for pattern in IMPLEMENTATION_SIGNALS:
        if re.search(pattern, prompt_lower):
            return True
    return False


def plan_has_premortem(plan_path: str, cwd: str) -> bool:
    """Check if plan file already has premortem section."""
    full_path = Path(cwd) / plan_path
    if not full_path.exists():
        return False

    try:
        content = full_path.read_text()
        # Check for premortem section markers
        return "Risk Mitigations (Pre-Mortem)" in content or "## Pre-Mortem" in content
    except Exception:
        return False


def generate_suggestion(plan_files: list[str]) -> str:
    """Generate premortem suggestion output."""
    output = []
    output.append("━" * 45)
    output.append("💡 PRE-MORTEM SUGGESTION")
    output.append("━" * 45)
    output.append("")
    output.append("Detected: Implementation from plan file(s)")

    for plan in plan_files:
        output.append(f"  • {plan}")

    output.append("")
    output.append("Consider running before implementation:")

    if len(plan_files) == 1:
        output.append(f"  /premortem deep {plan_files[0]}")
    else:
        output.append("  /premortem deep <plan-file>")

    output.append("")
    output.append("This identifies risks BEFORE implementation starts.")
    output.append("━" * 45)

    return "\n".join(output)


def main():
    try:
        input_data = json.load(sys.stdin)
        prompt = input_data.get("prompt", "")
        cwd = input_data.get("cwd", ".")

        # Find plan files in prompt
        plan_files = find_plan_files(prompt)

        if not plan_files:
            # No plan files mentioned - silent exit
            print("")
            return

        # Check if any plan lacks premortem
        plans_needing_premortem = [
            p for p in plan_files
            if not plan_has_premortem(p, cwd)
        ]

        if not plans_needing_premortem:
            # All plans already have premortem - silent exit
            print("")
            return

        # Check for implementation intent (optional - be more helpful)
        has_intent = has_implementation_intent(prompt)

        # Generate suggestion
        suggestion = generate_suggestion(plans_needing_premortem)

        if has_intent:
            # Stronger suggestion when clear implementation intent
            suggestion = suggestion.replace(
                "Consider running",
                "RECOMMENDED: Run"
            )

        print(suggestion)

    except json.JSONDecodeError:
        # Silent fail - don't break the session
        print("")
    except Exception as e:
        # Log to stderr for debugging, but don't break session
        print(f"premortem-suggest hook error: {e}", file=sys.stderr)
        print("")


if __name__ == "__main__":
    main()
