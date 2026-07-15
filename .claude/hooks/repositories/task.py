"""
Task Repository - Todo tracking and progress management

Provides CRUD operations for tasks table:
- create(): Add new task
- get(): Retrieve task by ID
- update(): Modify task (status, hours, etc.)
- list(): Query tasks with filters
- get_active(): Get in-progress tasks
- update_status(): Change task status (triggers started_at/completed_at)
- get_by_session(): Get all tasks for a session
- get_subtasks(): Get child tasks
"""

from typing import Dict, Any, List, Optional
from datetime import datetime

from .base import BaseRepository
from .exceptions import ValidationError, NotFoundError, IntegrityError
import sqlite3


class TaskRepository(BaseRepository):
    """
    Repository for task management

    Table: tasks
    Primary operations:
    - Create tasks from plan files or TodoWrite tool
    - Update status (pending → in_progress → completed)
    - Track time (estimated vs actual hours)
    - Query tasks by status, session, priority
    - Manage subtasks (parent_task_id)
    """

    @property
    def _table_name(self) -> str:
        return "tasks"

    def create(self, data: Dict[str, Any]) -> str:
        """
        Create new task

        Required fields:
        - id: Task identifier (UUID or sequential)
        - description: Task description

        Optional fields:
        - session_id: Session where task created
        - parent_task_id: Parent task (for subtasks)
        - status: pending | in_progress | completed | blocked (default: pending)
        - estimated_hours, actual_hours: Time tracking
        - markdown_file, markdown_section: Documentation
        - priority: Integer (higher = more important)
        - blockers: JSON array of blocker descriptions

        Args:
            data: Task data

        Returns:
            Task ID

        Raises:
            ValidationError: If required fields missing
            IntegrityError: If task ID exists or parent_task_id invalid
        """
        # Validate required fields
        if 'id' not in data:
            raise ValidationError('id', None, 'Task ID required', data)
        if 'description' not in data:
            raise ValidationError('description', None, 'Task description required', data)

        # Set defaults
        defaults = {
            'status': 'pending',
            'priority': 0,
        }
        task_data = {**defaults, **data}

        # Insert task
        try:
            with self._transaction() as conn:
                placeholders = ', '.join(['?' for _ in task_data])
                columns = ', '.join(task_data.keys())
                query = f"INSERT INTO {self._table_name} ({columns}) VALUES ({placeholders})"
                conn.execute(query, tuple(task_data.values()))

            return data['id']

        except sqlite3.IntegrityError as e:
            raise IntegrityError(
                constraint='PRIMARY KEY or FOREIGN KEY',
                reason=str(e),
                details={'task_id': data['id']}
            )

    def get(self, record_id: str) -> Optional[Dict[str, Any]]:
        """
        Get task by ID

        Args:
            record_id: Task ID

        Returns:
            Task data (dict) or None if not found
        """
        with self._connection() as conn:
            query = f"SELECT * FROM {self._table_name} WHERE id = ?"
            cursor = conn.execute(query, (record_id,))
            row = cursor.fetchone()
            return self._row_to_dict(row) if row else None

    def update(self, record_id: str, data: Dict[str, Any]) -> bool:
        """
        Update task

        Common updates:
        - status: Change task status
        - actual_hours: Record time spent
        - priority: Change priority
        - blockers: Add/remove blockers

        Args:
            record_id: Task ID
            data: Fields to update

        Returns:
            True if updated, False if task not found

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
        Delete task

        WARNING: Cascades to subtasks (ON DELETE CASCADE)

        Args:
            record_id: Task ID

        Returns:
            True if deleted, False if not found
        """
        with self._transaction() as conn:
            query = f"DELETE FROM {self._table_name} WHERE id = ?"
            cursor = conn.execute(query, (record_id,))
            return cursor.rowcount > 0

    def list(self, filters: Optional[Dict[str, Any]] = None, limit: int = 100) -> List[Dict[str, Any]]:
        """
        List tasks with optional filters

        Filters:
        - status: Filter by status
        - session_id: Filter by session
        - parent_task_id: Filter by parent (or NULL for top-level)
        - priority_gte: Minimum priority

        Args:
            filters: Query filters
            limit: Max tasks to return

        Returns:
            List of task dicts (by priority DESC, then created_at)
        """
        with self._connection() as conn:
            query = f"SELECT * FROM {self._table_name}"
            where_parts = []
            values = []

            if filters:
                for key, value in filters.items():
                    if key == 'priority_gte':
                        where_parts.append("priority >= ?")
                        values.append(value)
                    elif key == 'parent_task_id' and value is None:
                        where_parts.append("parent_task_id IS NULL")
                    else:
                        where_parts.append(f"{key} = ?")
                        values.append(value)

            if where_parts:
                query += " WHERE " + " AND ".join(where_parts)

            query += " ORDER BY priority DESC, created_at ASC LIMIT ?"
            values.append(limit)

            cursor = conn.execute(query, tuple(values))
            rows = cursor.fetchall()
            return self._rows_to_dicts(rows)

    # Task-specific methods

    def get_active(self, session_id: Optional[str] = None) -> List[Dict[str, Any]]:
        """
        Get in-progress tasks

        Args:
            session_id: Optional filter by session

        Returns:
            List of in-progress tasks
        """
        filters = {'status': 'in_progress'}
        if session_id:
            filters['session_id'] = session_id

        return self.list(filters=filters)

    def update_status(self, task_id: str, new_status: str) -> bool:
        """
        Update task status

        Triggers:
        - pending → in_progress: Sets started_at
        - * → completed: Sets completed_at

        Args:
            task_id: Task ID
            new_status: New status (pending | in_progress | completed | blocked)

        Returns:
            True if updated, False if task not found

        Raises:
            ValidationError: If status invalid
        """
        valid_statuses = ['pending', 'in_progress', 'completed', 'blocked']
        if new_status not in valid_statuses:
            raise ValidationError(
                'status',
                new_status,
                f'Must be one of: {", ".join(valid_statuses)}'
            )

        # Update triggers in schema will set started_at/completed_at
        return self.update(task_id, {'status': new_status})

    def get_by_session(self, session_id: str) -> List[Dict[str, Any]]:
        """
        Get all tasks for a session

        Args:
            session_id: Session ID

        Returns:
            List of tasks (ordered by priority)
        """
        return self.list(filters={'session_id': session_id})

    def get_subtasks(self, parent_task_id: str) -> List[Dict[str, Any]]:
        """
        Get child tasks (subtasks)

        Args:
            parent_task_id: Parent task ID

        Returns:
            List of subtasks (ordered by priority)
        """
        return self.list(filters={'parent_task_id': parent_task_id})

    def get_top_level(self, session_id: Optional[str] = None) -> List[Dict[str, Any]]:
        """
        Get top-level tasks (no parent)

        Args:
            session_id: Optional filter by session

        Returns:
            List of top-level tasks
        """
        filters = {'parent_task_id': None}
        if session_id:
            filters['session_id'] = session_id

        return self.list(filters=filters)

    def get_pending(self, session_id: Optional[str] = None, min_priority: int = 0) -> List[Dict[str, Any]]:
        """
        Get pending tasks ready to start

        Args:
            session_id: Optional filter by session
            min_priority: Minimum priority threshold

        Returns:
            List of pending tasks (ordered by priority DESC)
        """
        filters = {'status': 'pending'}
        if session_id:
            filters['session_id'] = session_id
        if min_priority > 0:
            filters['priority_gte'] = min_priority

        return self.list(filters=filters)
