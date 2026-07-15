#!/usr/bin/env bash
# Track message count across conversation
# Increments counter and updates session state

set -euo pipefail

SESSION_FILE=".claude/session/current-session.yaml"
COUNTER_FILE=".claude/session/.message_count"

# Initialize counter if doesn't exist
if [[ ! -f "$COUNTER_FILE" ]]; then
  echo "0" > "$COUNTER_FILE"
fi

# Read current count
CURRENT_COUNT=$(cat "$COUNTER_FILE")

# Increment
NEW_COUNT=$((CURRENT_COUNT + 1))

# Save new count
echo "$NEW_COUNT" > "$COUNTER_FILE"

# Update session state
if [[ -f ".claude/hooks/update-session.sh" ]]; then
  bash .claude/hooks/update-session.sh user_prompt "$NEW_COUNT"
fi

# Output for debugging (if needed)
# echo "Message count: $NEW_COUNT" >&2

exit 0
