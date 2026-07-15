"""
Base Repository - Abstract CRUD operations

Provides common interface for all repositories with:
- CRUD operations (create, read, update, delete)
- Connection management (context managers)
- Transaction support
- Error handling

All concrete repositories inherit from BaseRepository.
"""

from abc import ABC, abstractmethod
from contextlib import contextmanager
from typing import Dict, Any, List, Optional, Generator
import sqlite3
from pathlib import Path

from .exceptions import RepositoryError, ConnectionError as RepoConnectionError


class BaseRepository(ABC):
    """
    Abstract base repository for data access

    Subclasses must implement:
    - _table_name: Name of database table
    - create(): Insert new record
    - get(): Retrieve single record by ID
    - update(): Modify existing record
    - delete(): Remove record
    - list(): Query multiple records
    """

    def __init__(self, db_path: str | Path):
        """
        Initialize repository

        Args:
            db_path: Path to SQLite database file
        """
        self.db_path = Path(db_path)
        self._ensure_db_exists()

    def _ensure_db_exists(self):
        """Ensure database file and directory exist"""
        self.db_path.parent.mkdir(parents=True, exist_ok=True)

    @property
    @abstractmethod
    def _table_name(self) -> str:
        """Return table name for this repository"""
        pass

    @contextmanager
    def _connection(self) -> Generator[sqlite3.Connection, None, None]:
        """
        Context manager for database connections

        Yields:
            sqlite3.Connection with row_factory configured

        Raises:
            RepoConnectionError: If connection fails
        """
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row  # Access columns by name
            conn.execute("PRAGMA foreign_keys = ON")  # Enable FK constraints
            try:
                yield conn
            finally:
                conn.close()
        except sqlite3.Error as e:
            raise RepoConnectionError(
                db_path=str(self.db_path),
                reason=str(e),
                details={'error_type': type(e).__name__}
            )

    @contextmanager
    def _transaction(self) -> Generator[sqlite3.Connection, None, None]:
        """
        Context manager for transactions

        Automatically commits on success, rolls back on error.

        Yields:
            sqlite3.Connection within transaction

        Example:
            with repo._transaction() as conn:
                conn.execute("INSERT ...")
                conn.execute("UPDATE ...")
            # Auto-committed if no exceptions
        """
        with self._connection() as conn:
            try:
                yield conn
                conn.commit()
            except Exception:
                conn.rollback()
                raise

    def _row_to_dict(self, row: sqlite3.Row) -> Dict[str, Any]:
        """
        Convert SQLite Row to dictionary

        Args:
            row: sqlite3.Row from query

        Returns:
            Dictionary with column names as keys
        """
        return dict(row) if row else {}

    def _rows_to_dicts(self, rows: List[sqlite3.Row]) -> List[Dict[str, Any]]:
        """
        Convert list of SQLite Rows to list of dictionaries

        Args:
            rows: List of sqlite3.Row from query

        Returns:
            List of dictionaries
        """
        return [self._row_to_dict(row) for row in rows]

    # Abstract methods (must be implemented by subclasses)

    @abstractmethod
    def create(self, data: Dict[str, Any]) -> str:
        """
        Create new record

        Args:
            data: Record data (dict)

        Returns:
            ID of created record

        Raises:
            ValidationError: If data invalid
            IntegrityError: If constraint violated
        """
        pass

    @abstractmethod
    def get(self, record_id: str) -> Optional[Dict[str, Any]]:
        """
        Get single record by ID

        Args:
            record_id: Record identifier

        Returns:
            Record data (dict) or None if not found

        Raises:
            RepositoryError: If query fails
        """
        pass

    @abstractmethod
    def update(self, record_id: str, data: Dict[str, Any]) -> bool:
        """
        Update existing record

        Args:
            record_id: Record identifier
            data: Fields to update (dict)

        Returns:
            True if updated, False if not found

        Raises:
            ValidationError: If data invalid
            RepositoryError: If update fails
        """
        pass

    @abstractmethod
    def delete(self, record_id: str) -> bool:
        """
        Delete record by ID

        Args:
            record_id: Record identifier

        Returns:
            True if deleted, False if not found

        Raises:
            RepositoryError: If delete fails
        """
        pass

    @abstractmethod
    def list(self, filters: Optional[Dict[str, Any]] = None, limit: int = 100) -> List[Dict[str, Any]]:
        """
        List records with optional filters

        Args:
            filters: Query filters (dict)
            limit: Maximum records to return

        Returns:
            List of record dictionaries

        Raises:
            RepositoryError: If query fails
        """
        pass

    # Optional methods (with default implementations)

    def exists(self, record_id: str) -> bool:
        """
        Check if record exists

        Args:
            record_id: Record identifier

        Returns:
            True if exists, False otherwise
        """
        return self.get(record_id) is not None

    def count(self, filters: Optional[Dict[str, Any]] = None) -> int:
        """
        Count records matching filters

        Args:
            filters: Query filters (dict)

        Returns:
            Number of matching records
        """
        with self._connection() as conn:
            query = f"SELECT COUNT(*) as count FROM {self._table_name}"
            if filters:
                # Build WHERE clause from filters
                where_parts = [f"{k} = ?" for k in filters.keys()]
                query += " WHERE " + " AND ".join(where_parts)
                cursor = conn.execute(query, tuple(filters.values()))
            else:
                cursor = conn.execute(query)

            row = cursor.fetchone()
            return row['count'] if row else 0
