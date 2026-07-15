#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "python-dotenv",
# ]
# ///

import argparse
import json
import os
import sys
import subprocess
from pathlib import Path
from datetime import datetime
from time import time
from typing import Any

try:
  from dotenv import load_dotenv

  load_dotenv()
except ImportError:
  pass  # dotenv is optional





def tts_dir_in_path(_path: Path) -> tuple[bool, Path]:
  """
  Check if the path contains a 'tts' directory, indicating presence of TTS utilities.
  """
  if _path.joinpath('tts').exists():
    return True, _path
  return False, _path


def find_tts_directory() -> Path | None:
  """
  Search for 'tts' directory in the current directory and parents.
  """
  start_dir = Path(__file__).parent
  found = False
  while found is False and start_dir != start_dir.parent:
    found, tts_dir = tts_dir_in_path(start_dir)
    if found:
      return tts_dir
    start_dir = start_dir.parent
  return None





def get_claude_directory() -> Path:
  """
  Find the .claude directory in the path hierarchy
  """
  home_dir = Path.home()
  claude_dir = Path(__file__).parent
  while claude_dir.name != '.claude':
    if claude_dir == home_dir:
      raise RuntimeError("Could not find .claude directory in path hierarchy")
    claude_dir = claude_dir.parent
  return claude_dir


def get_claude_and_repo_directories() -> tuple[Path, Path]:
  """
  Find the repository root directory and .claude directory
  """
  claude_dir = get_claude_directory()
  repo_dir = claude_dir.parent
  if not repo_dir.joinpath('.git').exists():
    raise RuntimeError("Could not find .git directory in root!")
  return repo_dir, claude_dir


def get_log_file_name(suffix: str | None = None) -> str:
  """
  Get the log file name based on the script name
  """
  if not suffix:
    suffix = 'json'
  script_name = Path(__file__).stem
  return f"{script_name}.{suffix}"


def get_log_path(input_data: dict[str, Any]) -> tuple[Path, Path, Path]:
  """
  Determine log file path based on input data
  """
  id = input_data.get('cwd', os.getenv('CLAUDE_PROJECT_DIR'))
  if not id:
    if 'session_id' in input_data:
      id = input_data['session_id']
    else:
      id = f"unknown_{int(time())}"
  else:
    id = Path(id).name

  repo_dir, claude_dir = get_claude_and_repo_directories()
  rhino_share_dir = repo_dir.joinpath('.rhino', 'share')
  rhino_logs_dir = rhino_share_dir.joinpath('logs')
  rhino_logs_dir.mkdir(parents=True, exist_ok=True)
  log_path = rhino_logs_dir.joinpath(id, get_log_file_name())
  log_path.parent.mkdir(parents=True, exist_ok=True)
  return rhino_share_dir, rhino_logs_dir, log_path



def log_session_start(log_file: Path, input_data: dict[str, Any]):
  """
  Log session start event to logs directory
  """
  # Read existing log data or initialize empty list
  if log_file.exists():
    with open(log_file, "r") as f:
      try:
        log_data = json.load(f)
      except (json.JSONDecodeError, ValueError):
        log_data = []
  else:
    log_data = []

  # Append the entire input data
  log_data.append(input_data)

  # Write back to file with formatting
  with open(log_file, "w") as f:
    json.dump(log_data, f, indent=2)


def get_git_status():
  """Get current git status information."""
  try:
    # Get current branch
    branch_result = subprocess.run(
      ["git", "rev-parse", "--abbrev-ref", "HEAD"],
      capture_output=True,
      text=True,
      timeout=5,
    )
    current_branch = (
      branch_result.stdout.strip() if branch_result.returncode == 0 else "unknown"
    )

    # Get uncommitted changes count
    status_result = subprocess.run(
      ["git", "status", "--porcelain"], capture_output=True, text=True, timeout=5
    )
    if status_result.returncode == 0:
      changes = (
        status_result.stdout.strip().split("\n")
        if status_result.stdout.strip()
        else []
      )
      uncommitted_count = len(changes)
    else:
      uncommitted_count = 0

    return current_branch, uncommitted_count
  except Exception:
    return None, None


def get_recent_issues():
  """Get recent GitHub issues if gh CLI is available."""
  try:
    # Check if gh is available
    gh_check = subprocess.run(["which", "gh"], capture_output=True)
    if gh_check.returncode != 0:
      return None

    # Get recent open issues
    result = subprocess.run(
      ["gh", "issue", "list", "--limit", "5", "--state", "open"],
      capture_output=True,
      text=True,
      timeout=10,
    )
    if result.returncode == 0 and result.stdout.strip():
      return result.stdout.strip()
  except Exception:
    pass
  return None


def load_development_context(source):
  """Load relevant development context based on session source."""
  context_parts = []

  # Add timestamp
  context_parts.append(
    f"Session started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
  )
  context_parts.append(f"Session source: {source}")

  # Add git information
  branch, changes = get_git_status()
  if branch:
    context_parts.append(f"Git branch: {branch}")
    if changes > 0:
      context_parts.append(f"Uncommitted changes: {changes} files")

  # Load project-specific context files if they exist
  context_files = [
    ".claude/CLAUDE.md",
    ".claude/TODO.md",
    "TODO.md",
    ".github/ISSUE_TEMPLATE.md",
  ]

  for file_path in context_files:
    if Path(file_path).exists():
      try:
        with open(file_path, "r") as f:
          content = f.read().strip()
          if content:
            context_parts.append(f"\n--- Content from {file_path} ---")
            context_parts.append(
              content[:1000]
            )  # Limit to first 1000 chars
      except Exception:
        pass

  # Add recent issues if available
  issues = get_recent_issues()
  if issues:
    context_parts.append("\n--- Recent GitHub Issues ---")
    context_parts.append(issues)

  return "\n".join(context_parts)


def main():
  try:
    # Parse command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument(
      "--load-context",
      action="store_true",
      help="Load development context at session start",
    )
    parser.add_argument(
      "--announce", action="store_true", help="Announce session start via TTS"
    )
    parser.add_argument(
      "--git-status",
      action="store_true",
      help="Run git status and display current repository state",
    )
    args = parser.parse_args()

    # Read JSON input from stdin
    input_data = json.loads(sys.stdin.read())

    # Extract fields
    session_id = input_data.get("session_id", "unknown")
    source = input_data.get("source", "unknown")  # "startup", "resume", or "clear"
    share_dir, logs_dir, log_path = get_log_path(input_data)

    # Log the session start event
    log_session_start(log_path, input_data)

    # Run git status if requested
    if args.git_status:
      git_status_info = []
      try:
        # Run git status --porcelain for machine-readable output
        status_result = subprocess.run(
          ["git", "status", "--porcelain", "--branch"],
          capture_output=True,
          text=True,
          timeout=10,
        )

        if status_result.returncode == 0:
          git_output = status_result.stdout.strip()
          if git_output:
            git_status_info.append(f"Git Status:\n{git_output}")

          # Also run a more detailed status for human readability
          detailed_result = subprocess.run(
            ["git", "status", "--short"],
            capture_output=True,
            text=True,
            timeout=10,
          )

          if (
            detailed_result.returncode == 0
            and detailed_result.stdout.strip()
          ):
            git_status_info.append(
              f"Changes Summary:\n{detailed_result.stdout.strip()}"
            )
        else:
          git_status_info.append(
            "Git status unavailable (not a git repository or git not found)"
          )

      except Exception as e:
        git_status_info.append(f"Failed to run git status: {e}")

      # If we have git status info, output it as additional context
      if git_status_info:
        output = {
          "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": "\n\n".join(git_status_info),
          }
        }
        print(json.dumps(output))
        sys.exit(0)

    # Load development context if requested
    if args.load_context:
      context = load_development_context(source)
      if context:
        # Using JSON output to add context
        output = {
          "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": context,
          }
        }
        print(json.dumps(output))
        sys.exit(0)

    # Announce session start if requested
    if args.announce:
      try:
        # Try to use TTS to announce session start
        tts_path = find_tts_directory()
        if tts_path is not None:
          tts_script = tts_path.joinpath("elevenlabs_tts.py")
          if tts_script.exists():
            messages = {
              "startup": "Claude Code session started",
              "resume": "Resuming previous session",
              "clear": "Starting fresh session",
            }
            message = messages.get(source, "Session started")

            subprocess.run(
              ["uv", "run", str(tts_script), message],
              capture_output=True,
              timeout=5,
            )
      except Exception:
        pass

    # Success
    sys.exit(0)

  except json.JSONDecodeError:
    # Handle JSON decode errors gracefully
    sys.exit(0)
  except Exception:
    # Handle Any other errors gracefully
    sys.exit(0)


if __name__ == "__main__":
  main()
