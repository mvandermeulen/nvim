#!/usr/bin/env python3
"""
Pattern Recognition - Historical pattern analysis

Analyzes historical data to identify patterns:
1. Similar sessions: Find past sessions with similar characteristics
2. Task duration estimation: Predict effort based on historical data
3. Common blockers: Identify frequent blockers and their resolutions

Usage:
    from intelligence.pattern_recognition import (
        find_similar_sessions,
        estimate_task_duration,
        get_common_blockers
    )

    # Find similar past sessions
    similar = find_similar_sessions('2026-01-24_session_318', limit=5)

    # Estimate task duration
    estimate = estimate_task_duration(
        title='Implement Redis coordination',
        scope='LARGE',
        complexity='medium'
    )

    # Identify common blockers
    blockers = get_common_blockers(task_pattern='Redis', limit=10)
"""

from typing import Any, Optional
from datetime import datetime, timedelta
import sys
from pathlib import Path
import importlib

hooks_dir = Path(__file__).parent.parent
if str(hooks_dir) not in sys.path:
    sys.path.insert(0, str(hooks_dir))

directories = importlib.import_module('directories')

D: directories.Directories = directories.DIRECTORIES  # Alias for easier access



# Repositories
try:
    from repositories.session import SessionRepository
    from repositories.task import TaskRepository
    from repositories.event import EventRepository
    HAS_REPOS = True
except ImportError:
    SessionRepository = None  # type: ignore
    TaskRepository = None  # type: ignore
    EventRepository = None  # type: ignore
    HAS_REPOS = False


def find_similar_sessions(
    session_id: str,
    limit: int = 5,
    min_similarity: float = 0.3
) -> list[dict[str, Any]]:
    """
    Find past sessions with similar characteristics

    Similarity based on:
    - Task title keywords
    - Scope (EPIC > LARGE > MEDIUM > SMALL > MICRO)
    - Mode (BUILD, DEBUG, etc.)
    - Health patterns

    Args:
        session_id: Reference session ID
        limit: Maximum number of results (default: 5)
        min_similarity: Minimum similarity score 0.0-1.0 (default: 0.3)

    Returns:
        List of similar sessions sorted by relevance score

    Example:
        similar = find_similar_sessions('2026-01-24_session_318', limit=5)
        for session in similar:
            print(f"{session['id']}: {session['task_title']} (score: {session['similarity_score']})")
    """
    if not HAS_REPOS or not SessionRepository:
        return []

    session_repo = SessionRepository(D.db_path)

    # Get reference session
    ref_session = session_repo.get(session_id)
    if not ref_session:
        return []

    # Get all other sessions
    all_sessions = session_repo.list(filters={})

    # Calculate similarity scores
    scored_sessions = []
    for session in all_sessions:
        if session['id'] == session_id:
            continue  # Skip self

        similarity = _calculate_session_similarity(ref_session, session)

        if similarity >= min_similarity:
            scored_sessions.append({
                **session,
                'similarity_score': similarity,
            })

    # Sort by similarity
    scored_sessions.sort(key=lambda x: x['similarity_score'], reverse=True)

    return scored_sessions[:limit]


def estimate_task_duration(
    title: str,
    scope: str = 'MEDIUM',
    complexity: str = 'medium',
    historical_lookback_days: int = 90
) -> dict[str, Any]:
    """
    Estimate task duration based on historical data

    Args:
        title: Task title
        scope: MICRO | SMALL | MEDIUM | LARGE | EPIC
        complexity: low | medium | high
        historical_lookback_days: Days of history to analyze (default: 90)

    Returns:
        Dictionary with:
        - estimated_minutes: Median time estimate
        - confidence: low | medium | high (based on sample size)
        - similar_tasks_count: Number of historical tasks used
        - min_minutes: Minimum observed duration
        - max_minutes: Maximum observed duration
        - p50_minutes: 50th percentile (median)
        - p90_minutes: 90th percentile (pessimistic)

    Example:
        estimate = estimate_task_duration(
            title='Implement Redis coordination',
            scope='LARGE',
            complexity='high'
        )
        print(f"Estimated: {estimate['estimated_minutes']} minutes")
        print(f"Confidence: {estimate['confidence']}")
    """
    if not HAS_REPOS or not TaskRepository:
        return {
            'estimated_minutes': _default_estimate_by_scope(scope),
            'confidence': 'low',
            'similar_tasks_count': 0,
        }

    task_repo = TaskRepository(D.db_path)

    # Query completed tasks (limit by count since date filter not supported)
    tasks = task_repo.list(filters={
        'status': 'completed',
    }, limit=200)

    # Filter by keyword similarity
    title_keywords = set(_extract_keywords(title.lower()))
    similar_tasks = []

    for task in tasks:
        task_title = task.get('title', '').lower()
        task_keywords = set(_extract_keywords(task_title))

        # Calculate keyword overlap
        if len(title_keywords.union(task_keywords)) == 0:
            continue

        overlap = len(title_keywords.intersection(task_keywords)) / \
                 len(title_keywords.union(task_keywords))

        if overlap > 0.2:  # At least 20% keyword overlap
            # Calculate duration if timestamps available
            created = task.get('created_at')
            completed = task.get('completed_at')

            if created and completed:
                try:
                    duration_minutes = _calculate_duration_minutes(created, completed)
                    if duration_minutes > 0 and duration_minutes < 10080:  # < 1 week
                        similar_tasks.append(duration_minutes)
                except:
                    pass

    # Calculate statistics
    if not similar_tasks:
        return {
            'estimated_minutes': _default_estimate_by_scope(scope),
            'confidence': 'low',
            'similar_tasks_count': 0,
        }

    similar_tasks.sort()
    count = len(similar_tasks)

    return {
        'estimated_minutes': _percentile(similar_tasks, 50),
        'confidence': 'high' if count >= 10 else 'medium' if count >= 3 else 'low',
        'similar_tasks_count': count,
        'min_minutes': min(similar_tasks),
        'max_minutes': max(similar_tasks),
        'p50_minutes': _percentile(similar_tasks, 50),
        'p90_minutes': _percentile(similar_tasks, 90),
    }


def get_common_blockers(
    task_pattern: Optional[str] = None,
    limit: int = 10,
    lookback_days: int = 90
) -> list[dict[str, Any]]:
    """
    Identify frequent blockers and their resolutions

    Args:
        task_pattern: Filter by task keyword (optional)
        limit: Maximum number of blockers (default: 10)
        lookback_days: Days of history to analyze (default: 90)

    Returns:
        List of common blockers with:
        - blocker_type: Type of blocker
        - frequency: How often it occurs
        - avg_resolution_minutes: Average time to resolve
        - common_resolutions: List of common resolution patterns

    Example:
        blockers = get_common_blockers(task_pattern='Redis')
        for blocker in blockers:
            print(f"{blocker['blocker_type']}: {blocker['frequency']} occurrences")
            print(f"  Avg resolution: {blocker['avg_resolution_minutes']} minutes")
    """
    if not HAS_REPOS or not EventRepository:
        return []

    event_repo = EventRepository(D.db_path)

    # Query recent events (limit by count since timestamp filter not supported)
    events = event_repo.get_recent(minutes=lookback_days * 24 * 60, limit=500)

    # Filter blocker events
    blocker_events = [
        e for e in events
        if 'blocker' in e.get('hook_name', '').lower() or
           'error' in e.get('hook_name', '').lower() or
           e.get('status') == 'error'
    ]

    # If task_pattern specified, filter by task context
    if task_pattern:
        pattern_keywords = set(_extract_keywords(task_pattern.lower()))
        blocker_events = [
            e for e in blocker_events
            if any(keyword in str(e.get('event_data', '')).lower()
                  for keyword in pattern_keywords)
        ]

    # Group by blocker type
    blocker_groups: dict[str, list[dict[str, Any]]] = {}
    for event in blocker_events:
        blocker_type = _classify_blocker(event)
        if blocker_type not in blocker_groups:
            blocker_groups[blocker_type] = []
        blocker_groups[blocker_type].append(event)

    # Calculate statistics
    blocker_stats = []
    for blocker_type, events_list in blocker_groups.items():
        # Calculate resolution times (if available)
        resolution_times = []
        for event in events_list:
            resolution_time = event.get('execution_time_ms', 0) / 1000 / 60  # Convert to minutes
            if resolution_time > 0:
                resolution_times.append(resolution_time)

        blocker_stats.append({
            'blocker_type': blocker_type,
            'frequency': len(events_list),
            'avg_resolution_minutes': sum(resolution_times) / len(resolution_times) if resolution_times else 0,
            'common_resolutions': _extract_resolutions(events_list),
        })

    # Sort by frequency
    blocker_stats.sort(key=lambda x: x['frequency'], reverse=True)

    return blocker_stats[:limit]


# Helper functions

def _calculate_session_similarity(session1: dict[str, Any], session2: dict[str, Any]) -> float:
    """Calculate similarity score between two sessions"""
    score = 0.0

    # Task title similarity (40% weight)
    title1_keywords = set(_extract_keywords(session1.get('task_title', '').lower()))
    title2_keywords = set(_extract_keywords(session2.get('task_title', '').lower()))
    if title1_keywords and title2_keywords:
        title_sim = len(title1_keywords.intersection(title2_keywords)) / \
                    len(title1_keywords.union(title2_keywords))
        score += title_sim * 0.4

    # Scope similarity (30% weight)
    scope_values = {'MICRO': 1, 'SMALL': 2, 'MEDIUM': 3, 'LARGE': 4, 'EPIC': 5}
    scope1 = scope_values.get(session1.get('scope', 'MEDIUM'), 3)
    scope2 = scope_values.get(session2.get('scope', 'MEDIUM'), 3)
    scope_sim = 1.0 - (abs(scope1 - scope2) / 4.0)
    score += scope_sim * 0.3

    # Mode match (20% weight)
    if session1.get('mode') == session2.get('mode'):
        score += 0.2

    # Health pattern (10% weight)
    if session1.get('health_status') == session2.get('health_status'):
        score += 0.1

    return score


def _extract_keywords(text: str) -> list[str]:
    """Extract meaningful keywords from text"""
    import re
    words = re.findall(r'\w+', text.lower())

    stop_words = {
        'a', 'an', 'the', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
        'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'should',
        'could', 'may', 'might', 'must', 'can', 'of', 'at', 'by', 'for', 'with',
        'from', 'to', 'in', 'on', 'or', 'and', 'but', 'not', 'it', 'this', 'that',
    }

    return [w for w in words if w not in stop_words and len(w) > 2]


def _default_estimate_by_scope(scope: str) -> int:
    """Default time estimates by scope (in minutes)"""
    defaults = {
        'MICRO': 15,
        'SMALL': 45,
        'MEDIUM': 120,
        'LARGE': 240,
        'EPIC': 480,
    }
    return defaults.get(scope, 120)


def _calculate_duration_minutes(start_iso: str, end_iso: str) -> int:
    """Calculate duration in minutes between two ISO timestamps"""
    try:
        start = datetime.fromisoformat(start_iso.replace('Z', '+00:00'))
        end = datetime.fromisoformat(end_iso.replace('Z', '+00:00'))
        delta = end - start
        return int(delta.total_seconds() / 60)
    except:
        return 0


def _percentile(values: list[float], percentile: int) -> int:
    """Calculate percentile of values"""
    if not values:
        return 0
    sorted_values = sorted(values)
    index = int((percentile / 100.0) * len(sorted_values))
    index = min(index, len(sorted_values) - 1)
    return int(sorted_values[index])


def _classify_blocker(event: dict[str, Any]) -> str:
    """Classify blocker type from event"""
    hook_name = event.get('hook_name', '').lower()
    event_data = str(event.get('event_data', '')).lower()

    if 'dependency' in hook_name or 'dependency' in event_data:
        return 'dependency_issue'
    elif 'permission' in hook_name or 'permission' in event_data:
        return 'permission_error'
    elif 'network' in hook_name or 'network' in event_data:
        return 'network_issue'
    elif 'database' in hook_name or 'database' in event_data:
        return 'database_error'
    elif 'timeout' in hook_name or 'timeout' in event_data:
        return 'timeout'
    elif 'syntax' in hook_name or 'syntax' in event_data:
        return 'syntax_error'
    else:
        return 'unknown_blocker'


def _extract_resolutions(events: list[dict[str, Any]]) -> list[str]:
    """Extract common resolution patterns from events"""
    # Placeholder: Could analyze event data for resolution patterns
    return ['manual_intervention', 'retry', 'config_change']


# CLI interface for testing
if __name__ == '__main__':
    import sys

    if len(sys.argv) < 2:
        print('Usage:')
        print('  python pattern_recognition.py similar <session_id>')
        print('  python pattern_recognition.py estimate <task_title> [scope]')
        print('  python pattern_recognition.py blockers [task_pattern]')
        sys.exit(1)

    command = sys.argv[1]

    if command == 'similar':
        session_id = sys.argv[2]
        similar = find_similar_sessions(session_id, limit=5)
        print(f"Similar sessions to {session_id}:")
        for session in similar:
            print(f"  - {session['id']}: {session.get('task_title', 'N/A')} (score: {session['similarity_score']:.2f})")

    elif command == 'estimate':
        title = sys.argv[2]
        scope = sys.argv[3] if len(sys.argv) > 3 else 'MEDIUM'
        estimate = estimate_task_duration(title, scope=scope)
        print(f"Estimate for '{title}' ({scope}):")
        print(f"  Estimated: {estimate['estimated_minutes']} minutes")
        print(f"  Confidence: {estimate['confidence']}")
        print(f"  Based on: {estimate['similar_tasks_count']} similar tasks")

    elif command == 'blockers':
        pattern = sys.argv[2] if len(sys.argv) > 2 else None
        blockers = get_common_blockers(task_pattern=pattern)
        print(f"Common blockers{' for ' + pattern if pattern else ''}:")
        for blocker in blockers:
            print(f"  - {blocker['blocker_type']}: {blocker['frequency']} occurrences")
            print(f"    Avg resolution: {blocker['avg_resolution_minutes']:.1f} minutes")

    else:
        print(f"Unknown command: {command}")
        sys.exit(1)
