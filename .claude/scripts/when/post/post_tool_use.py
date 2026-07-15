#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# ///

import json
import sys
from pathlib import Path
import os
from time import time
from typing import Any


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


def main():
  try:
    # Read JSON input from stdin
    input_data = json.load(sys.stdin)
    share_dir, logs_dir, log_path = get_log_path(input_data)

    # Read existing log data or initialize empty list
    if log_path.exists():
      with open(log_path, "r") as f:
        try:
          log_data = json.load(f)
        except (json.JSONDecodeError, ValueError):
          log_data = []
    else:
      log_data = []

    # Append new data
    log_data.append(input_data)

    # Write back to file with formatting
    with open(log_path, "w") as f:
      json.dump(log_data, f, indent=2)

    sys.exit(0)

  except json.JSONDecodeError:
    # Handle JSON decode errors gracefully
    sys.exit(0)
  except Exception:
    # Exit cleanly on Any other error
    sys.exit(0)


if __name__ == "__main__":
  main()
