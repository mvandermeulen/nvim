"""
Session Repository - Session lifecycle and health tracking

Provides CRUD operations for sessions table:
- create(): Start new session
- get(): Retrieve session by ID
- update(): Update session state (health, progress, etc.)
- list(): Query sessions with filters
- get_active(): Get currently active session
- finalize(): Mark session as ended
"""

from typing import Dict, Any, List, Optional
from datetime import datetime

from .base import BaseRepository
from .exceptions import ValidationError, NotFoundError, IntegrityError
import sqlite3


class SessionRepository(BaseRepository):
    """
    Repository for session management

    Table: sessions
    Primary operations:
    - Create session on session-start hook
    - Update health/progress during session
    - Finalize session on session-end hook
    - Query historical sessions
    """

    @property
    def _table_name(self) -> str:
        return "sessions"

    def create(self, data: Dict[str, Any]) -> str:
        """
        Create new session

        Required fields:
        - id: Session identifier (YYYY-MM-DD_session_XXX)
        - started_at: Session start timestamp

        Optional fields:
        - health_status: 🟢 | 🟡 | 🔴 (default: 🟢)
        - message_count: Integer (default: 0)
        - mode: DEBUG | BUILD | REVIEW | LEARN | RAPID (default: BUILD)
        - scope: MICRO | SMALL | MEDIUM | LARGE | EPIC (default: MEDIUM)
        - task_title, task_reference, task_phase, task_progress
        - current_file, current_function, branch, last_command
        - markdown_file, notes

        Args:
            data: Session data

        Returns:
            Session ID

        Raises:
            ValidationError: If required fields missing or invalid
            IntegrityError: If session ID already exists
        """
        # Validate required fields
        if 'id' not in data:
            raise ValidationError('id', None, 'Session ID required', data)
        if 'started_at' not in data:
            raise ValidationError('started_at', None, 'Session start time required', data)

        # Set defaults
        defaults = {
            'health_status': '🟢',
            'message_count': 0,
            'mode': 'BUILD',
            'scope': 'MEDIUM',
            'task_progress': 0,
            'branch': 'main',
        }
        session_data = {**defaults, **data}

        # Insert session
        try:
            with self._transaction() as conn:
                placeholders = ', '.join(['?' for _ in session_data])
                columns = ', '.join(session_data.keys())
                query = f"INSERT INTO {self._table_name} ({columns}) VALUES ({placeholders})"
                conn.execute(query, tuple(session_data.values()))

            return data['id']

        except sqlite3.IntegrityError as e:
            raise IntegrityError(
                constraint='PRIMARY KEY or CHECK',
                reason=str(e),
                details={'session_id': data['id']}
            )

    def get(self, record_id: str) -> Optional[Dict[str, Any]]:
        """
        Get session by ID

        Args:
            record_id: Session ID

        Returns:
            Session data (dict) or None if not found
        """
        with self._connection() as conn:
            query = f"SELECT * FROM {self._table_name} WHERE id = ?"
            cursor = conn.execute(query, (record_id,))
            row = cursor.fetchone()
            return self._row_to_dict(row) if row else None

    def update(self, record_id: str, data: Dict[str, Any]) -> bool:
        """
        Update session

        Common updates:
        - health_status, message_count (on user-prompt-submit)
        - task_progress (on milestone completion)
        - current_file, current_function (on tool use)
        - notes (append session notes)

        Args:
            record_id: Session ID
            data: Fields to update

        Returns:
            True if updated, False if session not found

        Raises:
            ValidationError: If data invalid
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
        Delete session

        WARNING: Cascades to hook_events and decisions (ON DELETE CASCADE)
        Sets task.session_id to NULL (ON DELETE SET NULL)

        Args:
            record_id: Session ID

        Returns:
            True if deleted, False if not found
        """
        with self._transaction() as conn:
            query = f"DELETE FROM {self._table_name} WHERE id = ?"
            cursor = conn.execute(query, (record_id,))
            return cursor.rowcount > 0

    def list(self, filters: Optional[Dict[str, Any]] = None, limit: int = 100) -> List[Dict[str, Any]]:
        """
        List sessions with optional filters

        Filters:
        - health_status: Filter by health
        - mode: Filter by mode
        - scope: Filter by scope
        - active: True for ended_at IS NULL

        Args:
            filters: Query filters
            limit: Max sessions to return

        Returns:
            List of session dicts (most recent first)
        """
        with self._connection() as conn:
            query = f"SELECT * FROM {self._table_name}"
            where_parts = []
            values = []

            if filters:
                for key, value in filters.items():
                    if key == 'active' and value:
                        where_parts.append("ended_at IS NULL")
                    else:
                        where_parts.append(f"{key} = ?")
                        values.append(value)

            if where_parts:
                query += " WHERE " + " AND ".join(where_parts)

            query += " ORDER BY started_at DESC LIMIT ?"
            values.append(limit)

            cursor = conn.execute(query, tuple(values))
            rows = cursor.fetchall()
            return self._rows_to_dicts(rows)

    # Session-specific methods

    def get_active(self) -> Optional[Dict[str, Any]]:
        """
        Get currently active session (ended_at IS NULL)

        Returns:
            Active session data or None
        """
        sessions = self.list(filters={'active': True}, limit=1)
        return sessions[0] if sessions else None

    def finalize(self, session_id: str, ended_at: Optional[str] = None) -> bool:
        """
        Mark session as ended

        Args:
            session_id: Session ID
            ended_at: End timestamp (default: now)

        Returns:
            True if finalized, False if session not found
        """
        if ended_at is None:
            ended_at = datetime.now().isoformat()

        return self.update(session_id, {'ended_at': ended_at})

    def increment_message_count(self, session_id: str) -> int:
        """
        Increment message count for session

        Args:
            session_id: Session ID

        Returns:
            New message count

        Raises:
            NotFoundError: If session not found
        """
        session = self.get(session_id)
        if not session:
            raise NotFoundError('session', session_id)

        new_count = session.get('message_count', 0) + 1
        self.update(session_id, {'message_count': new_count})
        return new_count

    def update_health(self, session_id: str, message_count: int) -> str:
        """
        Update session health based on message count

        Health thresholds:
        - 🟢 (0-30 messages): Healthy
        - 🟡 (31-45 messages): Approaching limit
        - 🔴 (46+ messages): Handover needed

        Args:
            session_id: Session ID
            message_count: Current message count

        Returns:
            New health status

        Raises:
            NotFoundError: If session not found
        """
        if message_count <= 30:
            health = '🟢'
        elif message_count <= 45:
            health = '🟡'
        else:
            health = '🔴'

        self.update(session_id, {
            'health_status': health,
            'message_count': message_count
        })

        return health
