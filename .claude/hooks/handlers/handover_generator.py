#!/usr/bin/env python3
"""Generate handover documents from session state"""

from pathlib import Path
from datetime import datetime
from typing import Dict, Any
import sys
import yaml
import subprocess


def generate_handover() -> Dict[str, Any]:
    """Generate handover document from current session state"""

    # Load session state (with fallback to empty dict)
    session_file = Path('.claude/session/current-session.yaml')
    session_data = {}

    if session_file.exists():
        try:
            with open(session_file) as f:
                session_data = yaml.safe_load(f) or {}
        except Exception as e:
            # Continue with empty session data rather than failing
            print(f"Warning: Could not load session file: {e}", file=sys.stderr)
            session_data = {}

    # Use fallback structure if session file missing or incomplete
    if not session_data:
        session_data = {
            'session': {},
            'task': {},
            'todos': {},
            'context': {}
        }

    # Load message count
    counter_file = Path('.claude/session/.message_count')
    message_count = int(counter_file.read_text().strip()) if counter_file.exists() else 0

    # Get git status
    try:
        branch = subprocess.check_output(['git', 'branch', '--show-current'],
                                        text=True).strip()
        git_status = subprocess.check_output(['git', 'status', '--short'],
                                             text=True).strip()
        recent_commits = subprocess.check_output(['git', 'log', '--oneline', '-5'],
                                                 text=True).strip()
    except:
        branch = 'unknown'
        git_status = 'unavailable'
        recent_commits = 'unavailable'

    # Load template
    template_file = Path('.claude/templates/handover-template.md')
    if not template_file.exists():
        return {'status': 'error', 'error': 'Handover template not found'}

    template = template_file.read_text()

    # Replace placeholders
    timestamp = datetime.now().strftime('%Y-%m-%d-%H-%M-%S')
    session_id = session_data.get('session', {}).get('id', 'unknown')

    # Calculate health based on message count
    if message_count >= 46:
        health = '🔴'
    elif message_count >= 31:
        health = '🟡'
    else:
        health = '🟢'

    # Get task info (with fallbacks)
    task_info = session_data.get('task', {})
    task_title = task_info.get('title', 'Auto-handover (no active task tracked)')
    task_progress = task_info.get('progress', 0)
    current_phase = task_info.get('phase', 'Unknown')

    # Get todos (with fallbacks)
    todos = session_data.get('todos', {})
    completed = todos.get('completed', [])
    pending = todos.get('pending', [])
    in_progress = todos.get('in_progress', [])

    # Get context info (with fallbacks)
    context = session_data.get('context', {})
    current_file = context.get('current_file', 'N/A')
    current_mode = session_data.get('session', {}).get('mode', 'BUILD')
    current_scope = session_data.get('session', {}).get('scope', 'MEDIUM')

    # Replace core placeholders
    handover_content = template.replace('{{TIMESTAMP}}', timestamp)
    handover_content = handover_content.replace('{{SESSION_ID}}', session_id)
    handover_content = handover_content.replace('{{HEALTH_STATUS}}', health)
    handover_content = handover_content.replace('{{MESSAGE_COUNT}}', str(message_count))
    handover_content = handover_content.replace('{{GIT_BRANCH}}', branch)
    handover_content = handover_content.replace('{{TASK_TITLE}}', task_title)
    handover_content = handover_content.replace('{{PROGRESS}}', str(task_progress))
    handover_content = handover_content.replace('{{GIT_STATUS}}', git_status or 'No changes')
    handover_content = handover_content.replace('{{CURRENT_MODE}}', current_mode)
    handover_content = handover_content.replace('{{CURRENT_SCOPE}}', current_scope)
    handover_content = handover_content.replace('{{CURRENT_PHASE}}', current_phase)
    handover_content = handover_content.replace('{{CURRENT_FILE}}', current_file)

    # Format todos
    completed_str = '\n'.join(f"- ✅ {todo}" for todo in completed) if completed else '- None'
    pending_str = '\n'.join(f"- ⏸️ {todo}" for todo in pending) if pending else '- None'
    in_progress_str = '\n'.join(f"- 🔄 {todo}" for todo in in_progress) if in_progress else '- None'

    handover_content = handover_content.replace('{{COMPLETED_TODOS}}', completed_str)
    handover_content = handover_content.replace('{{PENDING_TODOS}}', pending_str)
    handover_content = handover_content.replace('{{IN_PROGRESS_TODOS}}', in_progress_str)

    # Replace remaining placeholders with defaults
    handover_content = handover_content.replace('{{HEALTH_RECOMMENDATION}}',
        'Continue work in fresh session' if message_count >= 46 else 'Monitor health status')
    handover_content = handover_content.replace('{{CURRENT_FUNCTION}}', 'N/A')
    handover_content = handover_content.replace('{{LAST_COMMAND}}', 'N/A')
    handover_content = handover_content.replace('{{SESSION_DATE}}', datetime.now().strftime('%Y%m%d'))
    handover_content = handover_content.replace('{{KEY_CHANGES_SUMMARY}}', '- See git log above')
    handover_content = handover_content.replace('{{RESUME_FILE}}', current_file)
    handover_content = handover_content.replace('{{RESUME_TASK}}', task_title)
    handover_content = handover_content.replace('{{NEXT_STEPS}}', pending_str if pending else 'Check backlog')
    handover_content = handover_content.replace('{{SESSION_NOTES}}', 'N/A')
    handover_content = handover_content.replace('{{BLOCKERS_IF_ANY}}', 'None')

    # Write handover file
    handover_dir = Path('.claude/session/handover')
    handover_dir.mkdir(parents=True, exist_ok=True)
    handover_file = handover_dir / f'handover-{timestamp}.md'
    handover_file.write_text(handover_content)

    # Update last-handover pointer
    last_handover = Path('.claude/session/last-handover.md')
    last_handover.write_text(handover_content)

    return {
        'status': 'success',
        'data': {
            'handover_file': str(handover_file),
            'timestamp': timestamp,
            'message_count': message_count,
            'health': health
        }
    }
