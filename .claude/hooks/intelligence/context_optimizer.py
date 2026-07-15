#!/usr/bin/env python3
"""
Context Optimizer - Prioritize essential context for token efficiency

Implements progressive context loading strategy:
1. Essential: Always load (session state, active tasks)
2. High Priority: Load if tokens available (recent decisions, critical events)
3. Medium Priority: Load if tokens available (completed summary, patterns)
4. Low Priority: Skip for resume, load on-demand (historical data)

Target: 40% token reduction compared to loading full context

Usage:
    from intelligence.context_optimizer import prioritize_context

    # Get prioritized context within token budget
    context = prioritize_context(
        session_id='2026-01-24_session_318',
        max_tokens=4000,
        priorities=['essential', 'high']
    )
"""

from typing import Any, Optional
import sys
from pathlib import Path
import importlib

hooks_dir = Path(__file__).parent.parent
if str(hooks_dir) not in sys.path:
    sys.path.insert(0, str(hooks_dir))

directories = importlib.import_module('directories')

D: directories.Directories = directories.DIRECTORIES  # Alias for easier access



# Smart resume module
try:
    from .smart_resume import (
        _load_session_state,
        _load_active_tasks,
        _load_recent_decisions,
        _load_key_events,
        _load_completed_summary,
        _estimate_tokens,
    )
    from repositories.session import SessionRepository
    from repositories.task import TaskRepository
    from repositories.decision import DecisionRepository
    from repositories.event import EventRepository
    HAS_DEPENDENCIES = True
except ImportError:
    HAS_DEPENDENCIES = False


# Priority levels
PRIORITY_ESSENTIAL = 'essential'
PRIORITY_HIGH = 'high'
PRIORITY_MEDIUM = 'medium'
PRIORITY_LOW = 'low'

# Token allocation percentages
TOKEN_ALLOCATION = {
    PRIORITY_ESSENTIAL: 0.40,  # 40% - Session state + active tasks
    PRIORITY_HIGH: 0.30,        # 30% - Recent decisions + key events
    PRIORITY_MEDIUM: 0.20,      # 20% - Completed summary + patterns
    PRIORITY_LOW: 0.10,         # 10% - Historical data (optional)
}


def prioritize_context(
    session_id: str,
    max_tokens: int = 4000,
    priorities: Optional[list[str]] = None
) -> dict[str, Any]:
    """
    Load context progressively based on priority and token budget

    Args:
        session_id: Session identifier
        max_tokens: Maximum tokens to use (default: 4000)
        priorities: Priority levels to load (default: ['essential', 'high'])
                   Options: 'essential', 'high', 'medium', 'low'

    Returns:
        Dictionary with prioritized context components and token usage

    Example:
        # Load only essential context (minimal)
        context = prioritize_context(
            session_id='2026-01-24_session_318',
            max_tokens=2000,
            priorities=['essential']
        )

        # Load essential + high priority (recommended for resume)
        context = prioritize_context(
            session_id='2026-01-24_session_318',
            max_tokens=4000,
            priorities=['essential', 'high']
        )

        # Load everything within budget
        context = prioritize_context(
            session_id='2026-01-24_session_318',
            max_tokens=6000,
            priorities=['essential', 'high', 'medium', 'low']
        )
    """
    if not HAS_DEPENDENCIES:
        raise RuntimeError('Dependencies not available. Cannot optimize context.')

    # Default priorities: essential + high
    if priorities is None:
        priorities = [PRIORITY_ESSENTIAL, PRIORITY_HIGH]

    # Initialize repositories
    session_repo = SessionRepository(D.db_path)
    task_repo = TaskRepository(D.db_path)
    decision_repo = DecisionRepository(D.db_path)
    event_repo = EventRepository(D.db_path)

    # Load session
    session = session_repo.get(session_id)
    if not session:
        raise ValueError(f'Session {session_id} not found')

    # Calculate token budgets per priority level
    budgets = {
        priority: int(max_tokens * TOKEN_ALLOCATION[priority])
        for priority in priorities
    }

    # Load context by priority
    context_components = {}
    tokens_used = 0

    # Essential priority (always load)
    if PRIORITY_ESSENTIAL in priorities:
        essential_budget = budgets[PRIORITY_ESSENTIAL]

        # Session state (~200 tokens)
        state = _load_session_state(session, essential_budget // 2)
        context_components['session_state'] = state
        tokens_used += _estimate_tokens(str(state))

        # Active tasks (~400 tokens)
        tasks = _load_active_tasks(session_id, task_repo, essential_budget // 2)
        context_components['active_tasks'] = tasks
        tokens_used += _estimate_tokens(str(tasks))

    # High priority (load if requested and tokens available)
    if PRIORITY_HIGH in priorities and tokens_used < max_tokens:
        high_budget = budgets[PRIORITY_HIGH]

        # Recent decisions (~300 tokens)
        decisions = _load_recent_decisions(session_id, decision_repo, high_budget // 2)
        context_components['decisions'] = decisions
        tokens_used += _estimate_tokens(str(decisions))

        # Key events (~300 tokens)
        events = _load_key_events(session_id, event_repo, high_budget // 2)
        context_components['events'] = events
        tokens_used += _estimate_tokens(str(events))

    # Medium priority (load if requested and tokens available)
    if PRIORITY_MEDIUM in priorities and tokens_used < max_tokens:
        medium_budget = budgets[PRIORITY_MEDIUM]

        # Completed summary (~200 tokens)
        completed = _load_completed_summary(session_id, task_repo, medium_budget)
        context_components['completed_summary'] = completed
        tokens_used += _estimate_tokens(str(completed))

        # Pattern insights (~400 tokens)
        try:
            from .pattern_recognition import find_similar_sessions
            similar = find_similar_sessions(session_id, limit=3)
            context_components['similar_sessions'] = similar[:3]
            tokens_used += _estimate_tokens(str(similar[:3]))
        except ImportError:
            context_components['similar_sessions'] = []

    # Low priority (historical data - usually skipped for resume)
    if PRIORITY_LOW in priorities and tokens_used < max_tokens:
        # Placeholder: Could load full task history, all decisions, etc.
        context_components['historical_data'] = {
            'note': 'Historical data available on demand'
        }

    return {
        'session_id': session_id,
        'components': context_components,
        'tokens_used': tokens_used,
        'tokens_budget': max_tokens,
        'token_efficiency': 1.0 - (tokens_used / max_tokens),  # Unused tokens
        'priorities_loaded': priorities,
    }


def get_minimal_context(session_id: str) -> dict[str, Any]:
    """
    Get absolute minimum context for quick resume (essential only)

    Args:
        session_id: Session identifier

    Returns:
        Essential context only (~600 tokens)

    Example:
        context = get_minimal_context('2026-01-24_session_318')
        # Returns: session state + active tasks only
    """
    return prioritize_context(
        session_id=session_id,
        max_tokens=1000,
        priorities=[PRIORITY_ESSENTIAL]
    )


def get_recommended_context(session_id: str) -> dict[str, Any]:
    """
    Get recommended context for typical resume (essential + high)

    Args:
        session_id: Session identifier

    Returns:
        Essential + high priority context (~2800 tokens)

    Example:
        context = get_recommended_context('2026-01-24_session_318')
        # Returns: session state + active tasks + decisions + events
    """
    return prioritize_context(
        session_id=session_id,
        max_tokens=4000,
        priorities=[PRIORITY_ESSENTIAL, PRIORITY_HIGH]
    )


def get_comprehensive_context(session_id: str) -> dict[str, Any]:
    """
    Get comprehensive context (all priorities)

    Args:
        session_id: Session identifier

    Returns:
        All priority levels (~5600 tokens)

    Example:
        context = get_comprehensive_context('2026-01-24_session_318')
        # Returns: Everything available
    """
    return prioritize_context(
        session_id=session_id,
        max_tokens=6000,
        priorities=[PRIORITY_ESSENTIAL, PRIORITY_HIGH, PRIORITY_MEDIUM, PRIORITY_LOW]
    )


def calculate_token_savings(
    full_context_tokens: int,
    optimized_tokens: int
) -> dict[str, Any]:
    """
    Calculate token savings from optimization

    Args:
        full_context_tokens: Token count for full unoptimized context
        optimized_tokens: Token count for optimized context

    Returns:
        Dictionary with:
        - tokens_saved: Number of tokens saved
        - percent_reduction: Percentage reduction
        - efficiency_gain: Efficiency gain (0.0-1.0)

    Example:
        savings = calculate_token_savings(
            full_context_tokens=10000,
            optimized_tokens=6000
        )
        print(f"Saved {savings['tokens_saved']} tokens ({savings['percent_reduction']}% reduction)")
    """
    tokens_saved = full_context_tokens - optimized_tokens
    percent_reduction = (tokens_saved / full_context_tokens * 100) if full_context_tokens > 0 else 0
    efficiency_gain = tokens_saved / full_context_tokens if full_context_tokens > 0 else 0

    return {
        'tokens_saved': tokens_saved,
        'percent_reduction': round(percent_reduction, 1),
        'efficiency_gain': round(efficiency_gain, 2),
        'full_context_tokens': full_context_tokens,
        'optimized_tokens': optimized_tokens,
    }


# CLI interface for testing
if __name__ == '__main__':
    import sys

    if len(sys.argv) < 2:
        print('Usage:')
        print('  python context_optimizer.py minimal <session_id>')
        print('  python context_optimizer.py recommended <session_id>')
        print('  python context_optimizer.py comprehensive <session_id>')
        print('  python context_optimizer.py custom <session_id> <max_tokens> <priorities>')
        sys.exit(1)

    command = sys.argv[1]

    if command == 'minimal' and len(sys.argv) >= 3:
        session_id = sys.argv[2]
        context = get_minimal_context(session_id)
        print(f"Minimal context for {session_id}:")
        print(f"  Tokens used: {context['tokens_used']}")
        print(f"  Components: {', '.join(context['components'].keys())}")

    elif command == 'recommended' and len(sys.argv) >= 3:
        session_id = sys.argv[2]
        context = get_recommended_context(session_id)
        print(f"Recommended context for {session_id}:")
        print(f"  Tokens used: {context['tokens_used']}")
        print(f"  Token efficiency: {context['token_efficiency']:.1%}")
        print(f"  Components: {', '.join(context['components'].keys())}")

    elif command == 'comprehensive' and len(sys.argv) >= 3:
        session_id = sys.argv[2]
        context = get_comprehensive_context(session_id)
        print(f"Comprehensive context for {session_id}:")
        print(f"  Tokens used: {context['tokens_used']}")
        print(f"  Components: {', '.join(context['components'].keys())}")

    elif command == 'custom' and len(sys.argv) >= 5:
        session_id = sys.argv[2]
        max_tokens = int(sys.argv[3])
        priorities = sys.argv[4].split(',')
        context = prioritize_context(session_id, max_tokens, priorities)
        print(f"Custom context for {session_id}:")
        print(f"  Tokens used: {context['tokens_used']} / {max_tokens}")
        print(f"  Token efficiency: {context['token_efficiency']:.1%}")
        print(f"  Priorities: {', '.join(priorities)}")

    else:
        print(f"Unknown command or missing arguments")
        sys.exit(1)
