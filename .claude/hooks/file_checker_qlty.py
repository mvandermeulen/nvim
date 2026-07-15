"""QLTY file checker hook - checks edited file for linting issues."""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

RED = "\033[0;31m"
GREEN = "\033[0;32m"
NC = "\033[0m"


def find_git_root() -> Path | None:
    """Find git repository root."""
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode == 0:
            return Path(result.stdout.strip())
    except Exception:
        pass
    return None


def get_edited_file_from_stdin() -> Path | None:
    """Get the edited file path from PostToolUse hook stdin."""
    try:
        import select

        if select.select([sys.stdin], [], [], 0)[0]:
            data = json.load(sys.stdin)
            tool_input = data.get("tool_input", {})
            file_path = tool_input.get("file_path")
            if file_path:
                return Path(file_path)
    except Exception:
        pass
    return None


def find_qlty_bin() -> str | None:
    """Find QLTY binary."""

    try:
        result = subprocess.run(["which", "qlty"], capture_output=True, text=True, check=False)
        if result.returncode == 0:
            return "qlty"
    except Exception:
        pass

    qlty_path = Path.home() / ".qlty" / "bin" / "qlty"
    if qlty_path.exists() and os.access(qlty_path, os.X_OK):
        return str(qlty_path)

    return None


def main() -> int:
    """Main entry point."""

    git_root = find_git_root()
    if git_root:
        os.chdir(git_root)

    target_file = get_edited_file_from_stdin()
    if not target_file or not target_file.exists():
        return 0

    if git_root:
        try:
            target_file.resolve().relative_to(git_root)
        except ValueError:
            return 0

    if target_file.suffix == ".py":
        return 0

    if "test" in target_file.name or "spec" in target_file.name:
        return 0

    qlty_bin = find_qlty_bin()
    if not qlty_bin or not Path(".qlty").exists():
        return 0

    try:
        result = subprocess.run(
            [qlty_bin, "check", "--no-formatters", str(target_file)],
            capture_output=True,
            text=True,
            check=False,
        )
        check_output = result.stdout + result.stderr
        check_exit_code = result.returncode
    except Exception:
        return 0

    if "No issues" in check_output and check_exit_code == 0:
        print("", file=sys.stderr)
        print(f"{GREEN}✅ QLTY: No issues{NC}", file=sys.stderr)
        return 2

    issue_lines = []
    for line in check_output.splitlines():
        if any(x in line for x in [r"^\s*[0-9]+:[0-9]+\s+", "high", "medium", "low"]):
            issue_lines.append(line)

    remaining_issues = sum(1 for line in check_output.splitlines() if any(x in line for x in ["high", "medium", "low"]))

    print("", file=sys.stderr)
    try:
        display_path = target_file.relative_to(Path.cwd())
    except ValueError:
        display_path = target_file
    print(
        f"{RED}🛑 QLTY Issues found in: {display_path}{NC}",
        file=sys.stderr,
    )
    print(f"{RED}Issues: {remaining_issues}{NC}", file=sys.stderr)
    print("", file=sys.stderr)

    if issue_lines:
        for line in issue_lines[:5]:
            print(line, file=sys.stderr)
        if remaining_issues > 5:
            print(f"... and {remaining_issues - 5} more issues", file=sys.stderr)
    else:
        for line in check_output.splitlines()[:5]:
            print(line, file=sys.stderr)

    print("", file=sys.stderr)
    print(f"{RED}Fix QLTY issues above before continuing{NC}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main())
