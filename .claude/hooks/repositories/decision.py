"""
Decision Repository - Architectural decisions tracking

Provides CRUD operations for decisions table:
- create(): Record new decision
- get(): Retrieve decision by ID
- update(): Modify decision (rare - decisions usually immutable)
- list(): Query decisions with filters
- search(): Full-text search in context/decision/rationale
- get_by_session(): Get all decisions for a session
- get_by_category(): Get decisions by category
- get_high_impact(): Get critical/high-impact decisions
"""

from typing import Dict, Any, List, Optional

from .base import BaseRepository
from .exceptions import ValidationError, IntegrityError
import sqlite3


class DecisionRepository(BaseRepository):
    """
    Repository for decision management

    Table: decisions
    Primary operations:
    - Record architectural decisions with context
    - Track rationale and impact
    - Query decisions by category, impact, session
    - Search decision context and rationale
    """

    @property
    def _table_name(self) -> str:
        return "decisions"

    def create(self, data: Dict[str, Any]) -> str:
        """
        Create new decision

        Required fields:
        - id: Decision identifier (UUID or sequential)
        - session_id: Session where decision made
        - title: Decision title
        - decision: What was decided

        Optional fields:
        - context: Why decision was needed
        - rationale: Why this decision was made
        - markdown_file: DECISIONS.md or journal entry
        - category: architecture | design | implementation | process
        - impact: low | medium | high | critical

        Args:
            data: Decision data

        Returns:
            Decision ID

        Raises:
            ValidationError: If required fields missing
            IntegrityError: If decision ID exists or session_id invalid
        """
        # Validate required fields
        if 'id' not in data:
            raise ValidationError('id', None, 'Decision ID required', data)
        if 'session_id' not in data:
            raise ValidationError('session_id', None, 'Session ID required', data)
        if 'title' not in data:
            raise ValidationError('title', None, 'Decision title required', data)
        if 'decision' not in data:
            raise ValidationError('decision', None, 'Decision content required', data)

        # Validate enums if provided
        if 'category' in data:
            valid_categories = ['architecture', 'design', 'implementation', 'process']
            if data['category'] not in valid_categories:
                raise ValidationError(
                    'category',
                    data['category'],
                    f'Must be one of: {", ".join(valid_categories)}'
                )

        if 'impact' in data:
            valid_impacts = ['low', 'medium', 'high', 'critical']
            if data['impact'] not in valid_impacts:
                raise ValidationError(
                    'impact',
                    data['impact'],
                    f'Must be one of: {", ".join(valid_impacts)}'
                )

        # Insert decision
        try:
            with self._transaction() as conn:
                placeholders = ', '.join(['?' for _ in data])
                columns = ', '.join(data.keys())
                query = f"INSERT INTO {self._table_name} ({columns}) VALUES ({placeholders})"
                conn.execute(query, tuple(data.values()))

            return data['id']

        except sqlite3.IntegrityError as e:
            raise IntegrityError(
                constraint='PRIMARY KEY or FOREIGN KEY',
                reason=str(e),
                details={'decision_id': data['id']}
            )

    def get(self, record_id: str) -> Optional[Dict[str, Any]]:
        """
        Get decision by ID

        Args:
            record_id: Decision ID

        Returns:
            Decision data (dict) or None if not found
        """
        with self._connection() as conn:
            query = f"SELECT * FROM {self._table_name} WHERE id = ?"
            cursor = conn.execute(query, (record_id,))
            row = cursor.fetchone()
            return self._row_to_dict(row) if row else None

    def update(self, record_id: str, data: Dict[str, Any]) -> bool:
        """
        Update decision

        NOTE: Decisions are usually immutable once recorded.
        Common updates:
        - markdown_file: Link to documentation
        - impact: Upgrade/downgrade impact level

        Args:
            record_id: Decision ID
            data: Fields to update

        Returns:
            True if updated, False if decision not found
        """
        if not data:
            return False

        # Build UPDATE query
        set_parts = [f"{k} = ?" for k in data.keys()]
        query = f"UPDATE {self._table_name} SET {', '.join(set_parts)} WHERE id = ?"
        values = tuple(list(data.values()) + [record_id])

        with self._transaction() as conn:
            cursor = conn.execute(query, values)
            return cursor.rowcount > 0

    def delete(self, record_id: str) -> bool:
        """
        Delete decision

        WARNING: Decisions should rarely be deleted (audit trail)

        Args:
            record_id: Decision ID

        Returns:
            True if deleted, False if not found
        """
        with self._transaction() as conn:
            query = f"DELETE FROM {self._table_name} WHERE id = ?"
            cursor = conn.execute(query, (record_id,))
            return cursor.rowcount > 0

    def list(self, filters: Optional[Dict[str, Any]] = None, limit: int = 100) -> List[Dict[str, Any]]:
        """
        List decisions with optional filters

        Filters:
        - session_id: Filter by session
        - category: Filter by category
        - impact: Filter by impact
        - impact_gte: Minimum impact (medium, high, critical)

        Args:
            filters: Query filters
            limit: Max decisions to return

        Returns:
            List of decision dicts (most recent first)
        """
        with self._connection() as conn:
            query = f"SELECT * FROM {self._table_name}"
            where_parts = []
            values = []

            if filters:
                for key, value in filters.items():
                    if key == 'impact_gte':
                        # Map impact to numeric for comparison
                        impact_order = {'low': 1, 'medium': 2, 'high': 3, 'critical': 4}
                        threshold = impact_order.get(value, 0)
                        where_parts.append(
                            "impact IN ('medium', 'high', 'critical')" if threshold >= 2 else
                            "impact IN ('high', 'critical')" if threshold >= 3 else
                            "impact = 'critical'"
                        )
                    else:
                        where_parts.append(f"{key} = ?")
                        values.append(value)

            if where_parts:
                query += " WHERE " + " AND ".join(where_parts)

            query += " ORDER BY created_at DESC LIMIT ?"
            values.append(limit)

            cursor = conn.execute(query, tuple(values))
            rows = cursor.fetchall()
            return self._rows_to_dicts(rows)

    # Decision-specific methods

    def get_by_session(self, session_id: str) -> List[Dict[str, Any]]:
        """
        Get all decisions for a session

        Args:
            session_id: Session ID

        Returns:
            List of decisions (most recent first)
        """
        return self.list(filters={'session_id': session_id})

    def get_by_category(self, category: str) -> List[Dict[str, Any]]:
        """
        Get decisions by category

        Args:
            category: architecture | design | implementation | process

        Returns:
            List of decisions in category
        """
        return self.list(filters={'category': category})

    def get_high_impact(self) -> List[Dict[str, Any]]:
        """
        Get high-impact and critical decisions

        Returns:
            List of high/critical impact decisions
        """
        return self.list(filters={'impact_gte': 'high'})

    def search(self, search_term: str, limit: int = 50) -> List[Dict[str, Any]]:
        """
        Search decisions by keyword

        Searches in: title, context, decision, rationale

        Args:
            search_term: Search keyword
            limit: Max results

        Returns:
            List of matching decisions
        """
        with self._connection() as conn:
            query = f"""
                SELECT * FROM {self._table_name}
                WHERE title LIKE ?
                   OR context LIKE ?
                   OR decision LIKE ?
                   OR rationale LIKE ?
                ORDER BY created_at DESC
                LIMIT ?
            """
            pattern = f"%{search_term}%"
            cursor = conn.execute(query, (pattern, pattern, pattern, pattern, limit))
            rows = cursor.fetchall()
            return self._rows_to_dicts(rows)

    def get_recent(self, days: int = 7, limit: int = 20) -> List[Dict[str, Any]]:
        """
        Get recent decisions

        Args:
            days: Number of days back
            limit: Max decisions

        Returns:
            List of recent decisions
        """
        with self._connection() as conn:
            query = f"""
                SELECT * FROM {self._table_name}
                WHERE created_at >= datetime('now', '-{days} days')
                ORDER BY created_at DESC
                LIMIT ?
            """
            cursor = conn.execute(query, (limit,))
            rows = cursor.fetchall()
            return self._rows_to_dicts(rows)
