"""
Event Repository - Hook execution audit trail

Provides CRUD operations for hook_events table:
- create(): Log hook execution
- get(): Retrieve event by ID
- list(): Query events with filters
- get_by_session(): Get all events for a session
- get_by_hook(): Get events by hook type
- get_errors(): Get failed hook executions
- get_stats(): Calculate success rate, avg execution time
"""

from typing import Dict, Any, List, Optional

from .base import BaseRepository
from .exceptions import ValidationError, IntegrityError
import sqlite3


class EventRepository(BaseRepository):
    """
    Repository for hook event management

    Table: hook_events
    Primary operations:
    - Log all hook executions (audit trail)
    - Track handler results and errors
    - Query events by session, hook type, status
    - Calculate execution statistics
    """

    @property
    def _table_name(self) -> str:
        return "hook_events"

    def create(self, data: Dict[str, Any]) -> int:
        """
        Create new hook event

        Required fields:
        - hook_name: session-start | user-prompt-submit | pre-tool-use | post-tool-use | session-end

        Optional fields:
        - session_id: Session ID (FK to sessions)
        - event_data: JSON payload from Claude Code
        - handler_results: JSON array of handler results
        - status: success | error | skipped | no_handlers (default: success)
        - error_message: Error details if status=error
        - handlers_executed: Count of handlers run
        - execution_time_ms: Performance metric

        Args:
            data: Hook event data

        Returns:
            Event ID (auto-increment)

        Raises:
            ValidationError: If required fields missing or invalid
            IntegrityError: If session_id invalid
        """
        # Validate required fields
        if 'hook_name' not in data:
            raise ValidationError('hook_name', None, 'Hook name required', data)

        valid_hooks = ['session-start', 'user-prompt-submit', 'pre-tool-use', 'post-tool-use', 'session-end', 'notification', 'stop', 'subagent-stop']
        if data['hook_name'] not in valid_hooks:
            raise ValidationError(
                'hook_name',
                data['hook_name'],
                f'Must be one of: {", ".join(valid_hooks)}'
            )

        # Validate status if provided
        if 'status' in data:
            valid_statuses = ['success', 'error', 'skipped', 'no_handlers']
            if data['status'] not in valid_statuses:
                raise ValidationError(
                    'status',
                    data['status'],
                    f'Must be one of: {", ".join(valid_statuses)}'
                )

        # Set defaults
        defaults = {
            'status': 'success',
            'handlers_executed': 0,
        }
        event_data = {**defaults, **data}

        # Insert event (id auto-increments)
        try:
            with self._transaction() as conn:
                # Remove 'id' if present (auto-increment)
                event_data.pop('id', None)

                placeholders = ', '.join(['?' for _ in event_data])
                columns = ', '.join(event_data.keys())
                query = f"INSERT INTO {self._table_name} ({columns}) VALUES ({placeholders})"
                cursor = conn.execute(query, tuple(event_data.values()))

            return cursor.lastrowid

        except sqlite3.IntegrityError as e:
            raise IntegrityError(
                constraint='FOREIGN KEY',
                reason=str(e),
                details={'session_id': data.get('session_id')}
            )

    def get(self, record_id: int) -> Optional[Dict[str, Any]]:
        """
        Get hook event by ID

        Args:
            record_id: Event ID

        Returns:
            Event data (dict) or None if not found
        """
        with self._connection() as conn:
            query = f"SELECT * FROM {self._table_name} WHERE id = ?"
            cursor = conn.execute(query, (record_id,))
            row = cursor.fetchone()
            return self._row_to_dict(row) if row else None

    def update(self, record_id: int, data: Dict[str, Any]) -> bool:
        """
        Update hook event

        NOTE: Events are usually immutable (audit trail)
        Rare updates: Fix malformed event_data or handler_results

        Args:
            record_id: Event ID
            data: Fields to update

        Returns:
            True if updated, False if event not found
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

    def delete(self, record_id: int) -> bool:
        """
        Delete hook event

        WARNING: Events should NOT be deleted (audit trail)

        Args:
            record_id: Event ID

        Returns:
            True if deleted, False if not found
        """
        with self._transaction() as conn:
            query = f"DELETE FROM {self._table_name} WHERE id = ?"
            cursor = conn.execute(query, (record_id,))
            return cursor.rowcount > 0

    def list(self, filters: Optional[Dict[str, Any]] = None, limit: int = 100) -> List[Dict[str, Any]]:
        """
        List hook events with optional filters

        Filters:
        - session_id: Filter by session
        - hook_name: Filter by hook type
        - status: Filter by status

        Args:
            filters: Query filters
            limit: Max events to return

        Returns:
            List of event dicts (most recent first)
        """
        with self._connection() as conn:
            query = f"SELECT * FROM {self._table_name}"
            where_parts = []
            values = []

            if filters:
                for key, value in filters.items():
                    where_parts.append(f"{key} = ?")
                    values.append(value)

            if where_parts:
                query += " WHERE " + " AND ".join(where_parts)

            query += " ORDER BY event_timestamp DESC LIMIT ?"
            values.append(limit)

            cursor = conn.execute(query, tuple(values))
            rows = cursor.fetchall()
            return self._rows_to_dicts(rows)

    # Event-specific methods

    def get_by_session(self, session_id: str, limit: int = 100) -> List[Dict[str, Any]]:
        """
        Get all events for a session

        Args:
            session_id: Session ID
            limit: Max events

        Returns:
            List of events (chronological order)
        """
        return self.list(filters={'session_id': session_id}, limit=limit)

    def get_by_hook(self, hook_name: str, limit: int = 100) -> List[Dict[str, Any]]:
        """
        Get events by hook type

        Args:
            hook_name: Hook name
            limit: Max events

        Returns:
            List of events for this hook
        """
        return self.list(filters={'hook_name': hook_name}, limit=limit)

    def get_errors(self, session_id: Optional[str] = None, limit: int = 50) -> List[Dict[str, Any]]:
        """
        Get failed hook executions

        Args:
            session_id: Optional filter by session
            limit: Max errors

        Returns:
            List of error events
        """
        filters = {'status': 'error'}
        if session_id:
            filters['session_id'] = session_id

        return self.list(filters=filters, limit=limit)

    def get_stats(self, session_id: Optional[str] = None, hook_name: Optional[str] = None) -> Dict[str, Any]:
        """
        Calculate hook execution statistics

        Args:
            session_id: Optional filter by session
            hook_name: Optional filter by hook

        Returns:
            Dict with:
            - total_events: Total event count
            - success_count: Successful executions
            - error_count: Failed executions
            - success_rate: Percentage (0-100)
            - avg_execution_time_ms: Average execution time
        """
        with self._connection() as conn:
            # Build WHERE clause
            where_parts = []
            values = []

            if session_id:
                where_parts.append("session_id = ?")
                values.append(session_id)

            if hook_name:
                where_parts.append("hook_name = ?")
                values.append(hook_name)

            where_clause = " WHERE " + " AND ".join(where_parts) if where_parts else ""

            # Calculate stats
            query = f"""
                SELECT
                    COUNT(*) as total_events,
                    SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as success_count,
                    SUM(CASE WHEN status = 'error' THEN 1 ELSE 0 END) as error_count,
                    AVG(execution_time_ms) as avg_execution_time_ms
                FROM {self._table_name}
                {where_clause}
            """

            cursor = conn.execute(query, tuple(values))
            row = cursor.fetchone()

            total = row['total_events'] or 0
            success = row['success_count'] or 0
            error = row['error_count'] or 0
            avg_time = row['avg_execution_time_ms'] or 0

            return {
                'total_events': total,
                'success_count': success,
                'error_count': error,
                'success_rate': (success / total * 100) if total > 0 else 0,
                'avg_execution_time_ms': round(avg_time, 2),
            }

    def get_recent(self, minutes: int = 60, limit: int = 50) -> List[Dict[str, Any]]:
        """
        Get recent hook events

        Args:
            minutes: Number of minutes back
            limit: Max events

        Returns:
            List of recent events
        """
        with self._connection() as conn:
            query = f"""
                SELECT * FROM {self._table_name}
                WHERE event_timestamp >= datetime('now', '-{minutes} minutes')
                ORDER BY event_timestamp DESC
                LIMIT ?
            """
            cursor = conn.execute(query, (limit,))
            rows = cursor.fetchall()
            return self._rows_to_dicts(rows)
