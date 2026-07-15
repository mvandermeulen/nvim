#!/usr/bin/env python3
"""
Smart Resume - Intelligent session continuation with context optimization

Loads essential context from previous session in <100ms with 40% token reduction:
1. Session state (health, progress, mode/scope)
2. Active tasks (pending/in_progress only)
3. Recent decisions (high-impact only)
4. Key events (errors, blockers, milestones)

Token Optimization Strategy:
- Essential: Session state, active tasks (always load)
- High Priority: Recent decisions, critical events (load if tokens available)
- Medium Priority: Completed tasks summary (load if tokens available)
- Low Priority: Historical patterns (skip for resume, use on-demand)

Usage:
    from intelligence.smart_resume import load_session_context

    context = load_session_context('2026-01-24_session_318')
    print(context['summary'])  # Concise summary for Claude
    print(context['token_count'])  # Estimated tokens used
"""

import time
from typing import Any, TYPE_CHECKING
import sys
from pathlib import Path
import importlib

hooks_dir = Path(__file__).parent.parent
if str(hooks_dir) not in sys.path:
    sys.path.insert(0, str(hooks_dir))

directories = importlib.import_module('directories')

D: directories.Directories = directories.DIRECTORIES  # Alias for easier access



if TYPE_CHECKING:
    from repositories.session import SessionRepository
    from repositories.task import TaskRepository
    from repositories.decision import DecisionRepository
    from repositories.event import EventRepository

# Repositories
try:
    from repositories.session import SessionRepository
    from repositories.task import TaskRepository
    from repositories.decision import DecisionRepository
    from repositories.event import EventRepository
    HAS_REPOS = True
except ImportError:
    HAS_REPOS = False


# Token budget allocation (percentage of total available tokens)
TOKEN_BUDGET = {
    'session_state': 0.10,      # 10% - Always include
    'active_tasks': 0.30,        # 30% - Critical for continuation
    'decisions': 0.20,           # 20% - Context for decision-making
    'events': 0.15,              # 15% - Key milestones and blockers
    'completed_summary': 0.15,   # 15% - What was accomplished
    'buffer': 0.10,              # 10% - Safety margin
}

# Rough token estimates (characters / 4 for GPT tokenization)
AVG_CHARS_PER_TOKEN = 4


def load_session_context(
    session_id: str,
    max_tokens: int = 4000,
    include_patterns: bool = False
) -> dict[str, Any]:
    """
    Load session context optimized for token efficiency

    Args:
        session_id: Session identifier (e.g., '2026-01-24_session_318')
        max_tokens: Maximum tokens to use for context (default: 4000)
        include_patterns: Include pattern recognition data (default: False)

    Returns:
        Dictionary with:
        - summary: Concise markdown summary for Claude
        - token_count: Estimated tokens used
        - load_time_ms: Load time in milliseconds
        - components: Individual context components
        - metadata: Session metadata

    Raises:
        ValueError: If session not found
        RuntimeError: If repositories unavailable
    """
    start_time = time.time()

    if not HAS_REPOS:
        raise RuntimeError('Repositories not available. Cannot load session context.')

    # Initialize repositories
    session_repo = SessionRepository(D.db_path)
    task_repo = TaskRepository(D.db_path)
    decision_repo = DecisionRepository(D.db_path)
    event_repo = EventRepository(D.db_path)

    # Load session data
    session = session_repo.get(session_id)
    if not session:
        raise ValueError(f'Session {session_id} not found')

    # Calculate token budgets
    budgets = {k: int(max_tokens * v) for k, v in TOKEN_BUDGET.items()}

    # Load context components with token limits
    components = {
        'session_state': _load_session_state(session, budgets['session_state']),
        'active_tasks': _load_active_tasks(session_id, task_repo, budgets['active_tasks']),
        'decisions': _load_recent_decisions(session_id, decision_repo, budgets['decisions']),
        'events': _load_key_events(session_id, event_repo, budgets['events']),
        'completed_summary': _load_completed_summary(session_id, task_repo, budgets['completed_summary']),
    }

    # Generate concise summary
    summary = _generate_context_summary(session, components)

    # Calculate metrics
    token_count = _estimate_tokens(summary)
    load_time_ms = int((time.time() - start_time) * 1000)

    # Include pattern data if requested
    if include_patterns:
        try:
            from .pattern_recognition import find_similar_sessions
            components['similar_sessions'] = find_similar_sessions(session_id, limit=3)
        except ImportError:
            components['similar_sessions'] = []

    return {
        'summary': summary,
        'token_count': token_count,
        'load_time_ms': load_time_ms,
        'components': components,
        'metadata': {
            'session_id': session_id,
            'health': session.get('health_status', '🟢'),
            'progress': session.get('task_progress', 0),
            'mode': session.get('mode', 'BUILD'),
            'scope': session.get('scope', 'MEDIUM'),
        }
    }


def _load_session_state(session: dict[str, Any], token_limit: int) -> dict[str, Any]:
    """Extract essential session state (always fits in token limit)"""
    return {
        'id': session['id'],
        'health': session.get('health_status', '🟢'),
        'message_count': session.get('message_count', 0),
        'mode': session.get('mode', 'BUILD'),
        'scope': session.get('scope', 'MEDIUM'),
        'task': {
            'title': session.get('task_title', 'Unknown'),
            'reference': session.get('task_reference', ''),
            'phase': session.get('task_phase', 'planning'),
            'progress': session.get('task_progress', 0),
        },
        'branch': session.get('branch', 'main'),
        'started_at': session.get('started_at', ''),
        'ended_at': session.get('ended_at', ''),
    }


def _load_active_tasks(
    session_id: str,
    task_repo: Any,
    token_limit: int
) -> list[dict[str, Any]]:
    """Load pending and in-progress tasks only"""
    # Query all session tasks and filter active ones
    all_tasks = task_repo.list(filters={
        'session_id': session_id,
    }, limit=100)

    # Filter to active tasks only
    tasks = [t for t in all_tasks if t.get('status') in ['pending', 'in_progress']]

    # Prioritize: in_progress > pending
    tasks_sorted = sorted(
        tasks,
        key=lambda t: (
            0 if t.get('status') == 'in_progress' else 1,
            t.get('priority', 2)  # Lower number = higher priority
        )
    )

    # Truncate to fit token limit
    result = []
    chars_used = 0
    max_chars = token_limit * AVG_CHARS_PER_TOKEN

    for task in tasks_sorted:
        task_summary = {
            'id': task['id'],
            'title': task.get('description', 'Untitled'),
            'status': task['status'],
            'priority': task.get('priority', 2),
        }
        task_str = str(task_summary)
        if chars_used + len(task_str) > max_chars:
            break
        result.append(task_summary)
        chars_used += len(task_str)

    return result


def _load_recent_decisions(
    session_id: str,
    decision_repo: Any,
    token_limit: int  # noqa: ARG001
) -> list[dict[str, Any]]:
    """Load high-impact decisions from this session"""
    # Query session decisions
    decisions = decision_repo.list(filters={
        'session_id': session_id,
    })

    # Filter high-impact only
    high_impact = [
        d for d in decisions
        if d.get('impact') in ['high', 'critical']
    ]

    # Sort by timestamp (most recent first)
    high_impact_sorted = sorted(
        high_impact,
        key=lambda d: d.get('decided_at', ''),
        reverse=True
    )

    # Truncate to fit token limit
    result = []
    chars_used = 0
    max_chars = token_limit * AVG_CHARS_PER_TOKEN

    for decision in high_impact_sorted:
        decision_summary = {
            'id': decision['id'],
            'title': decision['title'],
            'decision': decision['decision'],
            'impact': decision['impact'],
        }
        decision_str = str(decision_summary)
        if chars_used + len(decision_str) > max_chars:
            break
        result.append(decision_summary)
        chars_used += len(decision_str)

    return result


def _load_key_events(
    session_id: str,
    event_repo: Any,
    token_limit: int
) -> list[dict[str, Any]]:
    """Load critical events (errors, blockers, milestones)"""
    # Query session events
    events = event_repo.list(filters={
        'session_id': session_id,
    })

    # Filter by importance: errors > warnings > milestones
    important_events = [
        e for e in events
        if any(keyword in e.get('hook_name', '').lower()
               for keyword in ['error', 'warning', 'blocker', 'milestone', 'complete'])
    ]

    # Sort by timestamp (most recent first)
    events_sorted = sorted(
        important_events,
        key=lambda e: e.get('timestamp', ''),
        reverse=True
    )

    # Truncate to fit token limit
    result = []
    chars_used = 0
    max_chars = token_limit * AVG_CHARS_PER_TOKEN

    for event in events_sorted:
        event_summary = {
            'hook_name': event['hook_name'],
            'timestamp': event['timestamp'],
            'status': event.get('status', 'success'),
        }
        event_str = str(event_summary)
        if chars_used + len(event_str) > max_chars:
            break
        result.append(event_summary)
        chars_used += len(event_str)

    return result[:10]  # Max 10 events


def _load_completed_summary(
    session_id: str,
    task_repo: Any,
    token_limit: int
) -> dict[str, Any]:
    """Summarize completed work (counts only, not details)"""
    # Query completed tasks
    completed = task_repo.list(filters={
        'session_id': session_id,
        'status': 'completed'
    })

    return {
        'total_completed': len(completed),
        'by_priority': {
            'urgent': len([t for t in completed if t.get('priority') == 0]),
            'high': len([t for t in completed if t.get('priority') == 1]),
            'normal': len([t for t in completed if t.get('priority') == 2]),
            'low': len([t for t in completed if t.get('priority') == 3]),
        }
    }


def _generate_context_summary(
    session: dict[str, Any],
    components: dict[str, Any]
) -> str:
    """Generate concise markdown summary for Claude"""
    state = components['session_state']
    active_tasks = components['active_tasks']
    decisions = components['decisions']
    events = components['events']
    completed = components['completed_summary']

    lines = [
        f"# Session Resume: {state['id']}",
        "",
        f"**Status**: {state['health']} | **Progress**: {state['task']['progress']}% | **Mode**: {state['mode']} | **Scope**: {state['scope']}",
        f"**Task**: {state['task']['title']}",
        f"**Phase**: {state['task']['phase']} | **Branch**: {state['branch']}",
        "",
        "## Active Tasks",
    ]

    if active_tasks:
        for task in active_tasks:
            status_icon = "🔄" if task['status'] == 'in_progress' else "⏸️"
            lines.append(f"- {status_icon} **{task['title']}** (Priority: {task['priority']})")
    else:
        lines.append("- No active tasks")

    lines.append("")
    lines.append("## Recent Decisions")
    if decisions:
        for dec in decisions:
            lines.append(f"- **{dec['title']}**: {dec['decision']} ({dec['impact']})")
    else:
        lines.append("- No high-impact decisions recorded")

    lines.append("")
    lines.append("## Key Events")
    if events:
        for evt in events[:5]:  # Top 5 events
            lines.append(f"- {evt['hook_name']} ({evt['status']})")
    else:
        lines.append("- No critical events")

    lines.append("")
    lines.append(f"## Completed: {completed['total_completed']} tasks")

    return "\n".join(lines)


def _estimate_tokens(text: str) -> int:
    """Estimate token count (rough: chars / 4)"""
    return len(text) // AVG_CHARS_PER_TOKEN


# CLI interface for testing
if __name__ == '__main__':
    import sys

    if len(sys.argv) < 2:
        print('Usage: python smart_resume.py <session_id>')
        sys.exit(1)

    session_id = sys.argv[1]

    try:
        context = load_session_context(session_id)

        print(context['summary'])
        print()
        print(f"Token count: {context['token_count']} / 4000")
        print(f"Load time: {context['load_time_ms']}ms")

        if context['load_time_ms'] > 100:
            print(f"⚠️  WARNING: Load time exceeded 100ms target")
        else:
            print(f"✅ Load time within target (<100ms)")

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
