#!/usr/bin/env python3
"""
Decision Manager - Architectural decision tracking

Bridges decision recording with dual storage:
1. Markdown files (primary: DECISIONS.md, ADR files)
2. SQLite database (query layer for decision learning)

Dual-write strategy:
- Markdown remains source of truth for human review
- Database enables pattern recognition and similarity queries

Functions:
- record_decision(): Log architectural decision
- detect_decision(): Auto-detect decisions from file changes
- get_similar_decisions(): Find past decisions with similar context
- get_decision_chain(): Trace decision sequence
"""

import json
from datetime import datetime
import hashlib
import sys
from typing import Any, Optional
from pathlib import Path
import importlib

hooks_dir = Path(__file__).parent
if str(hooks_dir) not in sys.path:
    sys.path.insert(0, str(hooks_dir))

directories = importlib.import_module('directories')

D: directories.Directories = directories.DIRECTORIES  # Alias for easier access




# DecisionRepository (optional)
try:
    from repositories.decision import DecisionRepository  # type: ignore
    HAS_DECISION_REPO = True
except ImportError:
    DecisionRepository = None  # type: ignore
    HAS_DECISION_REPO = False

# Redis coordinator (optional, for broadcasting)
try:
    from redis_coordinator import get_coordinator  # type: ignore
    HAS_REDIS = True
except ImportError:
    get_coordinator = None  # type: ignore
    HAS_REDIS = False




def record_decision(decision_data: dict[str, Any], broadcast: bool = True) -> Optional[int]:
    """
    Record architectural decision in both markdown and database

    Args:
        decision_data: Decision information
            - title: Decision title (required)
            - context: Why this decision was needed
            - decision: What was decided
            - rationale: Why this decision was made
            - consequences: Impact and trade-offs
            - alternatives_considered: Other options explored
            - tags: List of tags for categorization
            - session_id: Current session
            - impact_level: low | medium | high | critical
        broadcast: Whether to broadcast to Redis

    Returns:
        Decision ID from database, or None if unavailable
    """
    # Write to markdown first (source of truth)
    _write_to_decisions_md(decision_data)

    # Sync to database (query layer)
    if not HAS_DECISION_REPO or not DecisionRepository:
        return None

    try:
        decision_repo = DecisionRepository(D.db_path)

        # Prepare database record
        db_decision = {
            'title': decision_data['title'],
            'context': decision_data.get('context', ''),
            'decision': decision_data.get('decision', ''),
            'rationale': decision_data.get('rationale', ''),
            'consequences': decision_data.get('consequences', ''),
            'alternatives_considered': decision_data.get('alternatives_considered', ''),
            'tags': json.dumps(decision_data.get('tags', [])),
            'session_id': decision_data.get('session_id'),
            'impact_level': decision_data.get('impact_level', 'medium'),
        }

        decision_id = decision_repo.create(db_decision)

        # Broadcast high-impact decisions
        if broadcast and decision_data.get('impact_level') in ('high', 'critical'):
            _broadcast_decision(decision_data)

        return decision_id

    except Exception as e:
        print(f"⚠️  Failed to record decision in database: {e}")
        return None


def detect_decision(file_path: str, content_change: Optional[str] = None) -> Optional[dict[str, Any]]:
    """
    Auto-detect architectural decisions from file changes

    Looks for:
    - DECISIONS.md updates
    - ADR file creation
    - Design document changes with decision markers

    Args:
        file_path: File that was modified
        content_change: Optional diff/content of change

    Returns:
        Decision data if detected, None otherwise
    """
    path = Path(file_path)

    # Check for DECISIONS.md update
    if path.name == 'DECISIONS.md':
        return _parse_decisions_md(path)

    # Check for ADR files
    if path.parent.name == 'adrs' and path.suffix == '.md':
        return _parse_adr_file(path)

    # Check for decision markers in design docs
    if content_change and '# Decision:' in content_change:
        return _parse_inline_decision(content_change)

    return None


def get_similar_decisions(
    context: str,
    limit: int = 5,
    min_similarity: float = 0.7
) -> list[dict[str, Any]]:
    """
    Find similar past decisions based on context

    Args:
        context: Current decision context
        limit: Maximum number of results
        min_similarity: Minimum similarity score (0.0-1.0)

    Returns:
        List of similar decisions with similarity scores
    """
    if not HAS_DECISION_REPO or not DecisionRepository:
        return []

    try:
        decision_repo = DecisionRepository(D.db_path)

        # Get all decisions
        all_decisions = decision_repo.list()

        # Calculate similarity scores
        results = []
        context_hash = _text_hash(context)

        for decision in all_decisions:
            decision_context = decision.get('context', '')
            decision_hash = _text_hash(decision_context)

            # Simple similarity based on shared terms
            similarity = _calculate_similarity(context, decision_context)

            if similarity >= min_similarity:
                results.append({
                    **decision,
                    'similarity_score': similarity
                })

        # Sort by similarity
        results.sort(key=lambda x: x['similarity_score'], reverse=True)

        return results[:limit]

    except Exception as e:
        print(f"⚠️  Failed to find similar decisions: {e}")
        return []


def get_decision_chain(decision_id: int, depth: int = 3) -> list[dict[str, Any]]:
    """
    Get decision chain leading to current state

    Args:
        decision_id: Starting decision ID
        depth: Maximum depth to traverse

    Returns:
        List of related decisions in chronological order
    """
    if not HAS_DECISION_REPO or not DecisionRepository:
        return []

    try:
        decision_repo = DecisionRepository(D.db_path)

        # Get the starting decision
        decision = decision_repo.get(decision_id)
        if not decision:
            return []

        chain = [decision]

        # Traverse related decisions (simplified - by tags)
        tags = json.loads(decision.get('tags', '[]'))
        if tags:
            # Find other decisions with same tags
            for tag in tags[:depth]:
                related = decision_repo.list(filters={'tags': tag}, limit=depth)
                for rel_dec in related:
                    if rel_dec['id'] != decision_id and rel_dec not in chain:
                        chain.append(rel_dec)

        # Sort chronologically
        chain.sort(key=lambda x: x.get('created_at', ''))

        return chain

    except Exception as e:
        print(f"⚠️  Failed to get decision chain: {e}")
        return []


def _write_to_decisions_md(decision_data: dict[str, Any]) -> None:
    """Append decision to DECISIONS.md file"""
    D.decisions_file.parent.mkdir(parents=True, exist_ok=True)

    try:
        # Prepare markdown entry
        entry = f"""
---

## {decision_data['title']}

**Date**: {datetime.now().strftime('%Y-%m-%d')}
**Impact**: {decision_data.get('impact_level', 'medium').title()}
**Session**: {decision_data.get('session_id', 'unknown')}

### Context
{decision_data.get('context', 'N/A')}

### Decision
{decision_data.get('decision', 'N/A')}

### Rationale
{decision_data.get('rationale', 'N/A')}

### Consequences
{decision_data.get('consequences', 'N/A')}

### Alternatives Considered
{decision_data.get('alternatives_considered', 'N/A')}

### Tags
{', '.join(decision_data.get('tags', []))}

---
"""

        # Append to file
        with D.decisions_file.open('a') as f:
            f.write(entry)

    except Exception as e:
        print(f"⚠️  Failed to write to DECISIONS.md: {e}")


def _broadcast_decision(decision_data: dict[str, Any]) -> None:
    """Broadcast high-impact decision to Redis"""
    if not HAS_REDIS or not get_coordinator:
        return

    try:
        coordinator = get_coordinator()
        if not coordinator.is_available():
            return

        coordinator.broadcast_decision({
            'title': decision_data['title'],
            'impact_level': decision_data.get('impact_level'),
            'session_id': decision_data.get('session_id'),
            'tags': decision_data.get('tags', []),
        })

    except Exception as e:
        print(f"⚠️  Failed to broadcast decision: {e}")


def _parse_decisions_md(file_path: Path) -> Optional[dict[str, Any]]:
    """Parse decision from DECISIONS.md update"""
    # Simplified: Return indication that decision was made
    return {
        'title': 'Decision updated in DECISIONS.md',
        'context': f'File modified: {file_path}',
        'decision': 'See DECISIONS.md for details',
        'impact_level': 'medium',
    }


def _parse_adr_file(file_path: Path) -> Optional[dict[str, Any]]:
    """Parse ADR file for decision data"""
    try:
        content = file_path.read_text()

        # Extract title from # heading
        title = 'Unknown Decision'
        for line in content.splitlines():
            if line.startswith('# '):
                title = line[2:].strip()
                break

        return {
            'title': f'ADR: {title}',
            'context': f'ADR file: {file_path.name}',
            'decision': 'See ADR file for details',
            'impact_level': 'high',  # ADRs are typically high-impact
        }

    except Exception as e:
        print(f"⚠️  Failed to parse ADR: {e}")
        return None


def _parse_inline_decision(content: str) -> Optional[dict[str, Any]]:
    """Parse inline decision markers in content"""
    # Look for # Decision: pattern
    import re
    match = re.search(r'# Decision:\s*(.+)', content)
    if match:
        return {
            'title': match.group(1).strip(),
            'context': 'Inline decision marker',
            'decision': 'See document for details',
            'impact_level': 'medium',
        }
    return None


def _text_hash(text: str) -> str:
    """Generate hash of text for similarity comparison"""
    return hashlib.sha256(text.lower().encode()).hexdigest()[:16]


def _calculate_similarity(text1: str, text2: str) -> float:
    """
    Calculate simple similarity between two texts

    Uses set intersection of words (Jaccard similarity)
    """
    if not text1 or not text2:
        return 0.0

    # Tokenize and normalize
    words1 = set(text1.lower().split())
    words2 = set(text2.lower().split())

    # Jaccard similarity
    intersection = len(words1 & words2)
    union = len(words1 | words2)

    return intersection / union if union > 0 else 0.0


# Example usage / testing
if __name__ == '__main__':
    print("\n✅ Decision Manager Test\n")

    # Test decision recording
    test_decision = {
        'title': 'Use Redis for agent coordination',
        'context': 'Need multi-agent coordination for parallel execution',
        'decision': 'Implement Redis pub-sub for event broadcasting and work queues',
        'rationale': 'Redis provides proven distributed coordination patterns',
        'consequences': 'Adds Redis dependency, but with graceful degradation',
        'alternatives_considered': 'ZeroMQ, RabbitMQ, file-based coordination',
        'tags': ['coordination', 'redis', 'architecture'],
        'impact_level': 'high',
        'session_id': 'test-session-001'
    }

    decision_id = record_decision(test_decision, broadcast=False)
    if decision_id:
        print(f"✅ Decision recorded: ID={decision_id}")

        # Test similarity search
        similar = get_similar_decisions('agent coordination patterns', limit=3)
        print(f"\n✅ Found {len(similar)} similar decisions")

        # Test decision chain
        chain = get_decision_chain(decision_id)
        print(f"✅ Decision chain length: {len(chain)}")

    print("\n✅ Test complete")
