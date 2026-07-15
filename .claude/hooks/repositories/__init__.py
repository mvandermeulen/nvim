"""
Repository Pattern - Data access abstraction layer

This package provides:
1. Abstract base repository (CRUD operations)
2. Concrete repository interfaces (Session, Task, Decision, Event)
3. Exception hierarchy (custom errors)
4. Connection management (context managers)

Usage:
    from repositories import SessionRepository, TaskRepository

    session_repo = SessionRepository(db_path)
    session_repo.create(session_data)
    session = session_repo.get(session_id)

Pattern:
    Repository → SQLite (concrete) → Redis (caching)
"""

from .base import BaseRepository
from .session import SessionRepository
from .task import TaskRepository
from .decision import DecisionRepository
from .event import EventRepository
from .exceptions import (
    RepositoryError,
    NotFoundError,
    ValidationError,
    ConnectionError,
)

__all__ = [
    'BaseRepository',
    'SessionRepository',
    'TaskRepository',
    'DecisionRepository',
    'EventRepository',
    'RepositoryError',
    'NotFoundError',
    'ValidationError',
    'ConnectionError',
]
