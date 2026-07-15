#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# ///

import json
import sys
import re
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



def is_dangerous_rm_command(command):
  """
  Comprehensive detection of dangerous rm commands.
  Matches various forms of rm -rf and similar destructive patterns.
  """
  # Normalize command by removing extra spaces and converting to lowercase
  normalized = " ".join(command.lower().split())

  # Pattern 1: Standard rm -rf variations
  patterns = [
    r"\brm\s+.*-[a-z]*r[a-z]*f",  # rm -rf, rm -fr, rm -Rf, etc.
    r"\brm\s+.*-[a-z]*f[a-z]*r",  # rm -fr variations
    r"\brm\s+--recursive\s+--force",  # rm --recursive --force
    r"\brm\s+--force\s+--recursive",  # rm --force --recursive
    r"\brm\s+-r\s+.*-f",  # rm -r ... -f
    r"\brm\s+-f\s+.*-r",  # rm -f ... -r
  ]

  # Check for dangerous patterns
  for pattern in patterns:
    if re.search(pattern, normalized):
      return True

  # Pattern 2: Check for rm with recursive flag targeting dangerous paths
  dangerous_paths = [
    r"/",  # Root directory
    r"/\*",  # Root with wildcard
    r"~",  # Home directory
    r"~/",  # Home directory path
    r"\$HOME",  # Home environment variable
    r"\.\.",  # Parent directory references
    r"\*",  # Wildcards in general rm -rf context
    r"\.",  # Current directory
    r"\.\s*$",  # Current directory at end of command
  ]

  if re.search(r"\brm\s+.*-[a-z]*r", normalized):  # If rm has recursive flag
    for path in dangerous_paths:
      if re.search(path, normalized):
        return True

  return False


def is_env_file_access(tool_name, tool_input):
  """
  Check if Any tool is trying to access .env files containing sensitive data.
  """
  if tool_name in ["Read", "Edit", "MultiEdit", "Write", "Bash"]:
    # Check file paths for file-based tools
    if tool_name in ["Read", "Edit", "MultiEdit", "Write"]:
      file_path = tool_input.get("file_path", "")
      if ".env" in file_path and not file_path.endswith(".env.sample"):
        return True

    # Check bash commands for .env file access
    elif tool_name == "Bash":
      command = tool_input.get("command", "")
      # Pattern to detect .env file access (but allow .env.sample)
      env_patterns = [
        r"\b\.env\b(?!\.sample)",  # .env but not .env.sample
        r"cat\s+.*\.env\b(?!\.sample)",  # cat .env
        r"echo\s+.*>\s*\.env\b(?!\.sample)",  # echo > .env
        r"touch\s+.*\.env\b(?!\.sample)",  # touch .env
        r"cp\s+.*\.env\b(?!\.sample)",  # cp .env
        r"mv\s+.*\.env\b(?!\.sample)",  # mv .env
      ]

      for pattern in env_patterns:
        if re.search(pattern, command):
          return True

  return False


def main():
  try:
    # Read JSON input from stdin
    input_data = json.load(sys.stdin)

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})

    # Check for .env file access (blocks access to sensitive environment files)
    if is_env_file_access(tool_name, tool_input):
      print(
        "BLOCKED: Access to .env files containing sensitive data is prohibited",
        file=sys.stderr,
      )
      print("Use .env.sample for template files instead", file=sys.stderr)
      sys.exit(2)  # Exit code 2 blocks tool call and shows error to Claude

    # Check for dangerous rm -rf commands
    if tool_name == "Bash":
      command = tool_input.get("command", "")

      # Block rm -rf commands with comprehensive pattern matching
      if is_dangerous_rm_command(command):
        print(
          "BLOCKED: Dangerous rm command detected and prevented",
          file=sys.stderr,
        )
        sys.exit(2)  # Exit code 2 blocks tool call and shows error to Claude

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
    # Gracefully handle JSON decode errors
    sys.exit(0)
  except Exception:
    # Handle Any other errors gracefully
    sys.exit(0)


if __name__ == "__main__":
  main()
