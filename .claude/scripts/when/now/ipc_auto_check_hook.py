#!/usr/bin/env python3
"""
IPC Auto-Check Hook
Triggers auto-processing based on user configuration
"""
import os
import json
import time
import sys

# Create secure directory if needed
os.makedirs("/tmp/claude-ipc-mcp", exist_ok=True)

# Generic paths that work for Any instance
CONFIG_FILE = "/tmp/claude-ipc-mcp/auto_check_config.json"
FLAG_FILE = "/tmp/claude-ipc-mcp/auto_check_trigger"


def should_trigger_auto_check():
  """Check if we should trigger auto-processing"""

  # Check if auto mode is enabled
  if not os.path.exists(CONFIG_FILE):
    return False

  try:
    with open(CONFIG_FILE, "r") as f:
      config = json.load(f)
  except:
    return False

  # Check if enabled
  if not config.get("enabled", False):
    return False

  # Get interval in seconds
  interval_minutes = config.get("interval_minutes", 5)
  interval_seconds = interval_minutes * 60

  # Check last auto-check time
  last_check = config.get("last_check")
  if not last_check:
    # First run, trigger immediately
    return True

  # Parse last check time
  try:
    from datetime import datetime

    last_check_dt = datetime.fromisoformat(last_check)
    current_dt = datetime.now()
    elapsed = (current_dt - last_check_dt).total_seconds()

    # Trigger if enough time has passed
    return elapsed >= interval_seconds
  except:
    # If parsing fails, trigger to be safe
    return True


# Main execution
if should_trigger_auto_check():
  # Create flag file for the AI to notice
  try:
    with open(FLAG_FILE, "w") as f:
      f.write(f"Auto-check triggered at {time.strftime('%Y-%m-%d %H:%M:%S')}")

    # Also update timestamp to prevent immediate re-trigger
    # (The auto_process tool will update this properly, but this prevents double-trigger)
    with open(CONFIG_FILE, "r") as f:
      config = json.load(f)
    config["last_check"] = time.strftime("%Y-%m-%dT%H:%M:%S")
    with open(CONFIG_FILE, "w") as f:
      json.dump(config, f, indent=2)

  except Exception as e:
    # Silent failure - hooks shouldn't interrupt workflow
    pass

# Always exit cleanly
sys.exit(0)
