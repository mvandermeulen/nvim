#!/usr/bin/env python3
"""
State Manager Utility

Manages research workflow state for tracking phases, quality gates,
and agent assignments across sessions.

Architecture:
- logs/state/current.json: Current state (currentSkill, currentResearch) - tiny, never grows
- logs/session_*_state.json: Historical data per session (skillHistory, sessions)
"""

import json
import sys
from datetime import datetime
from typing import Any, Optional
from pathlib import Path
import importlib

hooks_dir = Path(__file__).parent
if str(hooks_dir) not in sys.path:
    sys.path.insert(0, str(hooks_dir))

directories = importlib.import_module('directories')

D: directories.Directories = directories.DIRECTORIES  # Alias for easier access
HOOKS_DIR = D.hooks  # Directory for hook modules
REPO_DIR = D.repo  # Root directory of the repository
CLAUDE_DIR = D.claude  # Root directory for Claude session files
RHINO_SHARE_DIR = D.rhino['share']  # Shared directory for Rhino agent
RHINO_LOGS_DIR = D.rhino['logs']  # Directory for Rhino logs
RHINO_STATE_DIR = D.rhino['state']  # Directory for persistent state files
CLAUDE_DOCS_DIR = D.docs  # Directory for documentation files
CLAUDE_SESSION_DIR = D.session  # Directory for session files
CLAUDE_PLANNING_DIR = D.planning  # Directory for planning files
CURRENT_STATE_FILE = D.state_files['current']  # Path to current state JSON file
LEGACY_STATE_FILE = D.state_files['legacy']  # Path to legacy state JSON file
DECISIONS_FILE = D.decisions_file  # Path to DECISIONS.md
ADR_DIR = D.adrs  # Directory for Architectural Decision Records (ADRs)
PLANS_DIR = D.plans  # Directory for plan documents
CURRENT_SESSION_FILE = D.current_session_file  # Path to current session YAML file
HANDOVER_DIR = D.handover  # Directory for handover files






# Redis coordinator (optional)
try:
    from redis_coordinator import get_coordinator  # type: ignore
    HAS_REDIS = True
except ImportError:
    get_coordinator = None  # type: ignore
    HAS_REDIS = False

# SessionRepository (optional)
try:
    from repositories.session import SessionRepository  # type: ignore
    HAS_SESSION_REPO = True
except ImportError:
    SessionRepository = None  # type: ignore
    HAS_SESSION_REPO = False



def load_state() -> dict[str, Any]:
    """
    Load current state from current.json (for backwards compatibility).

    Returns state with both current fields and empty arrays for historical data.
    Historical data should be read from session files when needed.
    """
    current = load_current_state()

    # Return format compatible with existing code (includes empty historical arrays)
    return {
        'version': current.get('version', '1.0'),
        'currentSkill': current.get('currentSkill'),
        'currentResearch': current.get('currentResearch'),
        'skillHistory': [],  # Historical data lives in session files
        'sessions': []       # Historical data lives in session files
    }


def save_state(state: dict[str, Any]) -> None:
    """
    Save current state to current.json (for backwards compatibility).

    Only saves current fields (currentSkill, currentResearch).
    Historical data (skillHistory, sessions) should be written to session files.
    """
    current_state = {
        'version': state.get('version', '1.0'),
        'currentSkill': state.get('currentSkill'),
        'currentResearch': state.get('currentResearch')
    }
    save_current_state(current_state)


def load_current_state() -> dict[str, Any]:
    """Load current state from current.json (tiny file, never grows)"""
    if not D.state_files['current'].exists():
        return create_initial_current_state()

    try:
        with D.state_files['current'].open('r', encoding='utf-8') as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError) as e:
        print(f"Error loading current state: {e}", flush=True)
        return create_initial_current_state()


def save_current_state(current_state: dict[str, Any]) -> None:
    """Save current state to current.json and publish to Redis"""
    D.state_files['current'].parent.mkdir(parents=True, exist_ok=True)

    try:
        with D.state_files['current'].open('w', encoding='utf-8') as f:
            json.dump(current_state, f, indent=2)

        # Publish state change to Redis (optional, graceful degradation)
        _publish_state_change(current_state)
    except IOError as e:
        print(f"Error saving current state: {e}", flush=True)


def _publish_state_change(current_state: dict[str, Any]) -> None:
    """Publish state change to Redis for agent awareness"""
    if not HAS_REDIS or not get_coordinator:
        return

    try:
        coordinator = get_coordinator()
        if not coordinator.is_available():
            return

        # Publish to session:state channel
        coordinator._publish('session:state', {
            'event': 'state_updated',
            'current_skill': current_state.get('currentSkill'),
            'current_research': current_state.get('currentResearch'),
            'timestamp': datetime.now().isoformat()
        })
    except Exception as e:
        # Graceful degradation: don't let Redis failures break state management
        print(f"⚠️  Redis state publish failed: {e}", flush=True)


def sync_session_to_database(session_data: dict[str, Any]) -> None:
    """
    Synchronize session state to SQLite database

    Triple-write strategy:
    1. YAML file (primary, git-friendly)
    2. Markdown files (human-readable)
    3. SQLite database (query layer for analytics)

    Args:
        session_data: Session state from current-session.yaml
    """
    if not HAS_SESSION_REPO or not SessionRepository:
        return

    try:
        session_repo = SessionRepository(D.db_path)

        # Extract session ID (from YAML or generate)
        session_id = session_data.get('session_id')
        if not session_id:
            # Generate from date if not present
            session_id = f"session-{datetime.now().strftime('%Y-%m-%d-%H%M%S')}"

        # Try to get existing session
        existing = session_repo.get(session_id)

        if existing:
            # Update existing session
            session_repo.update(session_id, {
                'health_status': session_data.get('health_status', '🟢'),
                'message_count': session_data.get('message_count', 0),
                'mode': session_data.get('mode', 'BUILD'),
                'scope': session_data.get('scope', 'MEDIUM'),
                'task_title': session_data.get('task_title'),
                'task_progress': session_data.get('task_progress', 0),
                'current_file': session_data.get('current_file'),
                'branch': session_data.get('branch', 'main'),
                'notes': session_data.get('notes'),
            })
        else:
            # Create new session
            session_repo.create({
                'id': session_id,
                'started_at': session_data.get('started_at', datetime.now().isoformat()),
                'health_status': session_data.get('health_status', '🟢'),
                'message_count': session_data.get('message_count', 0),
                'mode': session_data.get('mode', 'BUILD'),
                'scope': session_data.get('scope', 'MEDIUM'),
                'task_title': session_data.get('task_title'),
                'task_progress': session_data.get('task_progress', 0),
                'current_file': session_data.get('current_file'),
                'branch': session_data.get('branch', 'main'),
                'notes': session_data.get('notes'),
            })

    except Exception as e:
        # Graceful degradation: don't let database sync break state management
        print(f"⚠️  Session database sync failed: {e}", flush=True)


def create_initial_current_state() -> dict[str, Any]:
    """Create initial current state structure (tiny, never grows)"""
    return {
        'version': '1.0',
        'currentSkill': None,
        'currentResearch': None
    }


def create_initial_state() -> dict[str, Any]:
    """Create initial state structure (for backwards compatibility)"""
    return {
        'version': '1.0.0',
        'sessions': [],
        'currentResearch': None,
        'skillHistory': [],
        'currentSkill': None
    }


def create_session(topic: str, subtopics: list[str]) -> dict[str, Any]:
    """Create new research session"""
    session_id = f"research_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

    return {
        'id': session_id,
        'topic': topic,
        'status': 'in_progress',
        'startedAt': datetime.now().isoformat(),
        'completedAt': None,
        'phases': {
            'decomposition': {
                'status': 'completed',
                'subtopics': subtopics,
                'completedAt': datetime.now().isoformat()
            },
            'research': {
                'status': 'in_progress',
                'parallelInstances': len(subtopics),
                'outputs': [],
                'startedAt': datetime.now().isoformat(),
                'completedAt': None
            },
            'synthesis': {
                'status': 'pending',
                'agent': 'unknown',
                'output': None,
                'startedAt': None,
                'completedAt': None
            },
            'delivery': {
                'status': 'pending',
                'startedAt': None,
                'completedAt': None
            }
        },
        'qualityGates': {
            'research': {
                'status': 'pending',
                'checkedAt': None,
                'expected': len(subtopics),
                'actual': 0
            },
            'synthesis': {
                'status': 'pending',
                'checkedAt': None,
                'expectedAgent': 'report-writer',
                'actualAgent': 'unknown'
            }
        }
    }


def get_current_session(state: dict[str, Any]) -> Optional[dict[str, Any]]:
    """Get current active research session"""
    if not state.get('currentResearch'):
        return None

    sessions = state.get('sessions', [])
    return next((s for s in sessions if s['id'] == state['currentResearch']), None)


def validate_quality_gate(state: dict[str, Any], session_id: str, gate: str) -> bool:
    """Validate quality gate for a session"""
    sessions = state.get('sessions', [])
    session = next((s for s in sessions if s['id'] == session_id), None)

    if not session:
        return False

    if gate == 'research':
        quality_gate = session['qualityGates']['research']
        outputs = session['phases']['research']['outputs']
        expected = quality_gate['expected']
        actual = len(outputs)

        quality_gate['actual'] = actual
        quality_gate['checkedAt'] = datetime.now().isoformat()

        if actual >= expected and expected > 0:
            quality_gate['status'] = 'passed'
            return True
        else:
            quality_gate['status'] = 'failed'
            return False

    elif gate == 'synthesis':
        quality_gate = session['qualityGates']['synthesis']
        expected_agent = quality_gate['expectedAgent']
        actual_agent = session['phases']['synthesis']['agent']

        quality_gate['actualAgent'] = actual_agent
        quality_gate['checkedAt'] = datetime.now().isoformat()

        if actual_agent == expected_agent:
            quality_gate['status'] = 'passed'
            return True
        else:
            quality_gate['status'] = 'failed'
            return False

    return False


# ═══════════════════════════════════════════════════════════════════════════
# SKILL TRACKING (Non-Destructive Extension)
# ═══════════════════════════════════════════════════════════════════════════

def calculate_duration(start_time: str, end_time: str) -> str:
    """Calculate duration between two ISO timestamps"""
    try:
        start = datetime.fromisoformat(start_time.replace('Z', '+00:00'))
        end = datetime.fromisoformat(end_time.replace('Z', '+00:00'))
        delta = end - start

        minutes = int(delta.total_seconds() / 60)
        seconds = int(delta.total_seconds() % 60)

        if minutes > 0:
            return f"{minutes}m {seconds}s"
        else:
            return f"{seconds}s"
    except:
        return "unknown"


def get_current_skill() -> Optional[dict[str, Any]]:
    """Get currently active skill (if any)"""
    state = load_state()
    return state.get('currentSkill')


def set_current_skill(skill_name: str, start_time: str) -> Optional[dict[str, Any]]:
    """
    Start tracking a new skill invocation.
    If same skill already active, ends it first and increments invocation number.

    Args:
        skill_name: Name of the skill (e.g., 'multi-agent-researcher')
        start_time: ISO timestamp when skill started

    Returns:
        The ended skill (if one was active), or None.
        Caller should write this to session state file.
    """
    current_state = load_current_state()
    current = current_state.get('currentSkill')

    ended_skill = None

    # Calculate invocation number
    if current and current.get('name') == skill_name:
        # Same skill re-invoked - end previous, increment counter
        invocation_number = current.get('invocationNumber', 1) + 1

        # End previous invocation if not already ended
        if not current.get('endTime'):
            current['endTime'] = start_time  # End at exact moment new one starts
            current['trigger'] = 'ReInvocation'
            current['duration'] = calculate_duration(
                current['startTime'],
                current['endTime']
            )
            ended_skill = current

    else:
        # Different skill or first invocation
        invocation_number = 1

        # End any active skill first
        if current and not current.get('endTime'):
            current['endTime'] = start_time
            current['trigger'] = 'NewSkill'
            current['duration'] = calculate_duration(
                current['startTime'],
                current['endTime']
            )
            ended_skill = current

    # Set new current skill
    current_state['currentSkill'] = {
        'name': skill_name,
        'startTime': start_time,
        'endTime': None,
        'invocationNumber': invocation_number
    }

    save_current_state(current_state)
    return ended_skill


def end_current_skill(end_time: str, trigger: str) -> Optional[dict[str, Any]]:
    """
    End the currently active skill.

    Args:
        end_time: ISO timestamp when skill ended
        trigger: What caused the end (Stop, SessionEnd, ReInvocation, etc.)

    Returns:
        The ended skill entry (caller should write to session state), or None if no active skill
    """
    current_state = load_current_state()
    current = current_state.get('currentSkill')

    if not current:
        return None

    # Don't override if already ended
    if current.get('endTime'):
        return current

    # End it
    current['endTime'] = end_time
    current['trigger'] = trigger
    current['duration'] = calculate_duration(
        current['startTime'],
        current['endTime']
    )

    # Clear current skill (set to None)
    current_state['currentSkill'] = None
    save_current_state(current_state)

    # Return ended skill (caller writes to session state)
    return current


def get_skill_invocation_count(skill_name: str) -> int:
    """
    Get invocation count for currently active skill.

    Note: Historical counts require reading session state files.
    This function only returns 1 if the specified skill is currently active, 0 otherwise.
    """
    current_state = load_current_state()
    current = current_state.get('currentSkill')

    if current and current.get('name') == skill_name:
        return 1
    return 0
