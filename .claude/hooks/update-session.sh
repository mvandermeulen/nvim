#!/usr/bin/env bash
# Update session state on various events
# Usage: update-session.sh <event_type> [message_count]

set -euo pipefail

EVENT_TYPE="${1:-unknown}"
MESSAGE_COUNT="${2:-0}"
SESSION_FILE=".claude/session/current-session.yaml"

# Ensure session file exists
if [[ ! -f "$SESSION_FILE" ]]; then
  echo "Session file not found: $SESSION_FILE" >&2
  exit 1
fi

# Get current timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Function to update YAML field
update_field() {
  local field="$1"
  local value="$2"

  # Use sed to update the field (macOS compatible)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|^  ${field}:.*|  ${field}: ${value}|" "$SESSION_FILE"
  else
    sed -i "s|^  ${field}:.*|  ${field}: ${value}|" "$SESSION_FILE"
  fi
}

# Update message count
if [[ "$MESSAGE_COUNT" -gt 0 ]]; then
  update_field "message_count" "$MESSAGE_COUNT"
fi

# Update timestamp
update_field "last_updated" "\"$TIMESTAMP\""

# Update health status based on message count
if [[ "$MESSAGE_COUNT" -ge 46 ]]; then
  update_field "health" "\"🔴\""
elif [[ "$MESSAGE_COUNT" -ge 31 ]]; then
  update_field "health" "\"🟡\""
else
  update_field "health" "\"🟢\""
fi

# Event-specific updates
case "$EVENT_TYPE" in
  session_start)
    # Generate new session ID
    SESSION_ID="$(date +%Y-%m-%d)_session_$(printf '%03d' $((RANDOM % 1000)))"
    update_field "id" "\"$SESSION_ID\""
    update_field "started_at" "\"$TIMESTAMP\""
    update_field "message_count" "0"
    update_field "health" "\"🟢\""
    ;;

  user_prompt|tool_use)
    # Message count updated above
    ;;

  session_end)
    # Could archive session here
    ;;
esac

exit 0
