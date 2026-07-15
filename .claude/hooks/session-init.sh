#!/usr/bin/env bash
# Initialize session state on session start
# Resets message counter, generates smart resume context, updates session metadata

set -euo pipefail

SESSION_FILE=".claude/session/current-session.yaml"
COUNTER_FILE=".claude/session/.message_count"
CONTEXT_FILE=".claude/session/resume-context.md"

# Reset message counter
echo "0" > "$COUNTER_FILE"

# Generate smart resume context (writes to resume-context.md for CLAUDE.md inclusion)
if [[ -f ".claude/hooks/intelligence/smart_resume.py" ]]; then
  cd "$(dirname "$0")/.."
  python3 -c "
import sys
sys.path.insert(0, 'hooks')
try:
    from intelligence.smart_resume import load_session_context
    from pathlib import Path
    import yaml

    # Get current session ID
    session_file = Path('session/current-session.yaml')
    if session_file.exists():
        with open(session_file) as f:
            session = yaml.safe_load(f)
        session_id = session.get('session', {}).get('id')

        if session_id:
            context = load_session_context(session_id, max_tokens=4000)

            # Write context to file for CLAUDE.md inclusion
            context_file = Path('session/resume-context.md')
            with open(context_file, 'w') as f:
                f.write('# Auto-Generated Session Context\\n\\n')
                f.write(context.get('summary', 'No context available'))
                f.write(f\"\\n\\n---\\n_Token usage: {context.get('token_count', 0)}/4000 | Load time: {context.get('load_time_ms', 0)}ms_\\n\")
            print('Smart resume context written to resume-context.md')
except Exception as e:
    print(f'Smart resume skipped: {e}', file=sys.stderr)
" 2>/dev/null || true
  cd - > /dev/null
fi

# Update session state
if [[ -f ".claude/hooks/update-session.sh" ]]; then
  bash .claude/hooks/update-session.sh session_start 0
fi

exit 0
