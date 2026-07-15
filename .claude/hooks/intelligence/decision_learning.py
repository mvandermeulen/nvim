#!/usr/bin/env python3
"""
Decision Learning - Learn from past architectural decisions

Provides pattern-based learning from historical decisions:
1. Decision chains: Trace sequence of related decisions
2. Similarity matching: Find past decisions with similar context
3. Impact lessons: Extract high-impact decisions as lessons

Usage:
    from intelligence.decision_learning import get_decision_chain, find_similar_decisions

    # Get decision sequence
    chain = get_decision_chain(decision_id=42, depth=3)

    # Find similar past decisions
    similar = find_similar_decisions(
        context='Choosing database for caching layer',
        limit=5
    )

    # Get lessons from high-impact decisions
    lessons = get_high_impact_lessons(impact='critical', limit=10)
"""

from pathlib import Path
from typing import Any, Optional
import sys
from pathlib import Path
import importlib

hooks_dir = Path(__file__).parent.parent
if str(hooks_dir) not in sys.path:
    sys.path.insert(0, str(hooks_dir))

directories = importlib.import_module('directories')

D: directories.Directories = directories.DIRECTORIES  # Alias for easier access



# DecisionRepository
try:
    from repositories.decision import DecisionRepository
    HAS_DECISION_REPO = True
except ImportError:
    DecisionRepository = None  # type: ignore
    HAS_DECISION_REPO = False



def get_decision_chain(
    decision_id: int,
    depth: int = 3,
    direction: str = 'forward'
) -> list[dict[str, Any]]:
    """
    Trace decision sequence (forward or backward)

    Args:
        decision_id: Starting decision ID
        depth: How many levels deep to traverse (default: 3)
        direction: 'forward' (consequences) or 'backward' (prerequisites)

    Returns:
        List of decisions in chain order with relationships

    Example:
        # Get decisions that led to this decision
        chain = get_decision_chain(42, depth=3, direction='backward')

        # Get decisions that followed from this decision
        chain = get_decision_chain(42, depth=3, direction='forward')
    """
    if not HAS_DECISION_REPO or not DecisionRepository:
        return []

    decision_repo = DecisionRepository(D.db_path)

    # Get starting decision
    start_decision = decision_repo.get(str(decision_id))
    if not start_decision:
        return []

    chain = [start_decision]

    # Traverse chain
    if direction == 'forward':
        # Find decisions that reference this decision in their context
        current_id = decision_id
        for _ in range(depth):
            related = decision_repo.list(filters={
                'context_contains': f'decision:{current_id}'
            })
            if not related:
                break
            # Take most recent related decision
            next_decision = sorted(related, key=lambda d: d.get('decided_at', ''), reverse=True)[0]
            chain.append(next_decision)
            current_id = next_decision['id']

    elif direction == 'backward':
        # Find decisions referenced in this decision's context
        current_decision = start_decision
        for _ in range(depth):
            context = current_decision.get('context', '')
            # Extract decision IDs from context (e.g., "decision:42")
            import re
            referenced_ids = re.findall(r'decision:(\d+)', context)
            if not referenced_ids:
                break
            # Get most recent referenced decision
            prev_id = referenced_ids[-1]
            prev_decision = decision_repo.get(prev_id)
            if not prev_decision:
                break
            chain.insert(0, prev_decision)  # Insert at beginning
            current_decision = prev_decision

    return chain


def find_similar_decisions(
    context: str,
    limit: int = 5,
    min_similarity: float = 0.3,
    impact_filter: Optional[str] = None
) -> list[dict[str, Any]]:
    """
    Find past decisions with similar context using keyword matching

    Args:
        context: Context string to match against
        limit: Maximum number of results (default: 5)
        min_similarity: Minimum similarity score 0.0-1.0 (default: 0.3)
        impact_filter: Filter by impact level (e.g., 'high', 'critical')

    Returns:
        List of decisions sorted by relevance score

    Example:
        similar = find_similar_decisions(
            context='Choosing Redis vs PostgreSQL for caching',
            limit=5,
            impact_filter='high'
        )
    """
    if not HAS_DECISION_REPO or not DecisionRepository:
        return []

    decision_repo = DecisionRepository(D.db_path)

    # Get all decisions (filtered by impact if specified)
    filters = {}
    if impact_filter:
        filters['impact'] = impact_filter

    all_decisions = decision_repo.list(filters=filters)

    # Calculate similarity scores (simple keyword overlap)
    context_keywords = set(_extract_keywords(context.lower()))

    scored_decisions = []
    for decision in all_decisions:
        decision_context = decision.get('context', '').lower()
        decision_keywords = set(_extract_keywords(decision_context))

        # Jaccard similarity: intersection / union
        if len(context_keywords.union(decision_keywords)) == 0:
            continue

        similarity = len(context_keywords.intersection(decision_keywords)) / \
                    len(context_keywords.union(decision_keywords))

        if similarity >= min_similarity:
            scored_decisions.append({
                'decision': decision,
                'similarity_score': similarity,
            })

    # Sort by similarity score
    scored_decisions.sort(key=lambda x: x['similarity_score'], reverse=True)

    # Return top N
    return [item['decision'] for item in scored_decisions[:limit]]


def get_high_impact_lessons(
    impact: str = 'high',
    limit: int = 10,
    session_id: Optional[str] = None
) -> list[dict[str, Any]]:
    """
    Extract high-impact decisions as lessons

    Args:
        impact: Minimum impact level ('high' or 'critical')
        limit: Maximum number of lessons (default: 10)
        session_id: Filter by session (optional)

    Returns:
        List of decisions formatted as lessons

    Example:
        lessons = get_high_impact_lessons(impact='critical', limit=10)
        for lesson in lessons:
            print(f"Lesson: {lesson['title']}")
            print(f"Decision: {lesson['decision']}")
            print(f"Rationale: {lesson['rationale']}")
    """
    if not HAS_DECISION_REPO or not DecisionRepository:
        return []

    decision_repo = DecisionRepository(D.db_path)

    # Build filters
    filters = {}
    if impact in ['high', 'critical']:
        filters['impact_gte'] = 'high'
    if session_id:
        filters['session_id'] = session_id

    # Get decisions
    decisions = decision_repo.list(filters=filters)

    # Sort by impact (critical > high) then by timestamp
    impact_order = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3}
    decisions_sorted = sorted(
        decisions,
        key=lambda d: (
            impact_order.get(d.get('impact', 'medium'), 2),
            d.get('decided_at', '')
        ),
        reverse=True
    )

    # Format as lessons
    lessons = []
    for decision in decisions_sorted[:limit]:
        lessons.append({
            'id': decision['id'],
            'title': decision['title'],
            'decision': decision['decision'],
            'rationale': decision.get('rationale', ''),
            'consequences': decision.get('consequences', ''),
            'impact': decision['impact'],
            'decided_at': decision.get('decided_at', ''),
            'tags': decision.get('tags', '').split(',') if decision.get('tags') else [],
        })

    return lessons


def _extract_keywords(text: str) -> list[str]:
    """Extract meaningful keywords from text (simple implementation)"""
    import re

    # Remove punctuation, split on whitespace
    words = re.findall(r'\w+', text.lower())

    # Filter out common stop words
    stop_words = {
        'a', 'an', 'the', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
        'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'should',
        'could', 'may', 'might', 'must', 'can', 'of', 'at', 'by', 'for', 'with',
        'from', 'to', 'in', 'on', 'or', 'and', 'but', 'not', 'it', 'this', 'that',
        'as', 'so', 'than', 'we', 'our', 'use', 'using', 'used', 'make', 'made',
    }

    keywords = [w for w in words if w not in stop_words and len(w) > 2]

    return keywords


# CLI interface for testing
if __name__ == '__main__':
    import sys

    if len(sys.argv) < 2:
        print('Usage:')
        print('  python decision_learning.py chain <decision_id> [depth]')
        print('  python decision_learning.py similar <context_string>')
        print('  python decision_learning.py lessons [impact]')
        sys.exit(1)

    command = sys.argv[1]

    if command == 'chain':
        decision_id = int(sys.argv[2])
        depth = int(sys.argv[3]) if len(sys.argv) > 3 else 3
        chain = get_decision_chain(decision_id, depth=depth)
        print(f"Decision chain (depth {depth}):")
        for i, dec in enumerate(chain):
            print(f"  {i+1}. {dec['title']} ({dec.get('decided_at', 'unknown')})")

    elif command == 'similar':
        context = ' '.join(sys.argv[2:])
        similar = find_similar_decisions(context, limit=5)
        print(f"Similar decisions (context: '{context}'):")
        for dec in similar:
            print(f"  - {dec['title']} ({dec['impact']})")

    elif command == 'lessons':
        impact = sys.argv[2] if len(sys.argv) > 2 else 'high'
        lessons = get_high_impact_lessons(impact=impact)
        print(f"High-impact lessons ({impact}+):")
        for lesson in lessons:
            print(f"  - {lesson['title']}")
            print(f"    Decision: {lesson['decision']}")
            print(f"    Impact: {lesson['impact']}")
            print()

    else:
        print(f"Unknown command: {command}")
        sys.exit(1)
