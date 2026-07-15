#!/usr/bin/env bash
# Health check for session state
# Outputs health status and recommendations

set -euo pipefail

SESSION_FILE=".claude/session/current-session.yaml"

# Check if session file exists
if [[ ! -f "$SESSION_FILE" ]]; then
  echo "⚠️  Session file not found. Run session initialization." >&2
  exit 1
fi

# Extract message count and health status
MESSAGE_COUNT=$(grep "message_count:" "$SESSION_FILE" | awk '{print $2}')
HEALTH=$(grep "health:" "$SESSION_FILE" | awk '{print $2}' | tr -d '"')
TASK_TITLE=$(grep "title:" "$SESSION_FILE" | head -1 | sed 's/.*title: "\(.*\)"/\1/')

# Output health status
echo "Session Health: $HEALTH (Message count: $MESSAGE_COUNT)"

if [[ -n "$TASK_TITLE" ]]; then
  echo "Current Task: $TASK_TITLE"
fi

# Recommendations based on health
if [[ "$MESSAGE_COUNT" -ge 46 ]]; then
  echo ""
  echo "⚠️  RECOMMENDATION: Handover Required"
  echo "   - Complete current logical unit"
  echo "   - Update todo list"
  echo "   - Run <Handover01> command"
elif [[ "$MESSAGE_COUNT" -ge 31 ]]; then
  echo ""
  echo "⚠️  RECOMMENDATION: Approaching handover limit"
  echo "   - Plan natural breakpoint"
  echo "   - Consider completing current task"
fi

exit 0
