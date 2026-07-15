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
from pathlib import Path
from datetime import datetime
from time import time
from typing import Any

try:
  from dotenv import load_dotenv

  load_dotenv()
except ImportError:
  pass  # dotenv is optional


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



def log_pre_compact(input_data, log_file: Path):
  """
  Log pre-compact event to logs directory
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


def backup_transcript(backup_dir: Path, transcript_path: str, trigger):
  """
  Create a backup of the transcript before compaction
  """

  try:
    _tp = Path(transcript_path)
    if not _tp.exists() or not _tp.is_file():
      return

    # Create backup directory
    backup_dir.mkdir(parents=True, exist_ok=True)

    # Generate backup filename with timestamp and trigger type
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    session_name = Path(transcript_path).stem
    backup_name = f"{session_name}_pre_compact_{trigger}_{timestamp}.jsonl"
    backup_path = backup_dir / backup_name

    # Copy transcript to backup
    import shutil

    shutil.copy2(transcript_path, backup_path)

    return str(backup_path)
  except Exception:
    return None


def main():
  try:
    # Parse command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument(
      "--backup",
      action="store_true",
      help="Create backup of transcript before compaction",
    )
    parser.add_argument(
      "--verbose", action="store_true", help="Print verbose output"
    )
    parser.add_argument(
      "--handover",
      action="store_true",
      help="Trigger /handover command before compaction",
    )
    args = parser.parse_args()

    # Read JSON input from stdin
    input_data = json.loads(sys.stdin.read())
    share_dir, logs_dir, log_file = get_log_path(input_data)

    # Extract fields
    session_id = input_data.get("session_id", "unknown")
    transcript_path = input_data.get("transcript_path", "")
    trigger = input_data.get("trigger", "unknown")  # "manual" or "auto"
    custom_instructions = input_data.get("custom_instructions", "")

    # Log the pre-compact event
    log_pre_compact(input_data, log_file)

    # Trigger handover command if requested
    if args.handover:
      # Output JSON to add context that will trigger handover
      output = {
        "hookSpecificOutput": {
          "hookEventName": "PreCompact",
          "additionalContext": "Please execute the /handover command to create a handover document before compaction proceeds.",
        }
      }
      print(json.dumps(output))
      sys.exit(0)

    # Create backup if requested
    _backup_path = log_file.parent.joinpath('backup')
    if args.backup and transcript_path:
      backup_path = backup_transcript(_backup_path, transcript_path, trigger)

    # Provide feedback based on trigger type
    if args.verbose:
      if trigger == "manual":
        message = (
          f"Preparing for manual compaction (session: {session_id[:8]}...)"
        )
        if custom_instructions:
          message += f"\nCustom instructions: {custom_instructions[:100]}..."
      else:  # auto
        message = f"Auto-compaction triggered due to full context window (session: {session_id[:8]}...)"

      if backup_path:
        message += f"\nTranscript backed up to: {backup_path}"

      print(message)

    # Success - compaction will proceed
    sys.exit(0)

  except json.JSONDecodeError:
    # Handle JSON decode errors gracefully
    sys.exit(0)
  except Exception:
    # Handle Any other errors gracefully
    sys.exit(0)


if __name__ == "__main__":
  main()
