#!/usr/bin/env python3
"""
Storage Abstraction Layer - Unified interface for hybrid storage

This module provides:
1. Markdown for human-editable content (plans, journal, docs)
2. JSON for simple current state (session tracking)
3. SQLite for queryable historical data (analytics)
4. Redis for real-time coordination (ephemeral)

Architecture:
- Markdown: Primary interface for human-editable content
- JSON: Current state tracking (git-friendly)
- SQLite: Query layer for analytics and historical data
- Redis: Coordination layer for real-time events

Write Flow:
1. Write to Markdown first (source of truth)
2. Update SQLite index (for queries)
3. Publish event to Redis (for coordination)
4. Git commit (version control)

Read Flow:
1. Check Redis cache (if real-time)
2. If miss, query SQLite (if analytical)
3. If not indexed, read Markdown (always works)
4. Cache in Redis (for next time)

Pattern Source: Comprehensive Claude Code Management System Design - Phase 2
"""

import json
import sqlite3
from pathlib import Path
from typing import Dict, Any, Optional, List
from datetime import datetime
from contextlib import contextmanager


# Storage paths
STORAGE_ROOT = Path('.claude')
PLANNING_DOCS = STORAGE_ROOT / 'docs' / 'planning'
JOURNAL_DIR = STORAGE_ROOT / 'journal'
STATE_DIR = STORAGE_ROOT / 'state'
MEMORY_DB = STORAGE_ROOT / 'memory' / 'sessions.db'


class StorageLayer:
    """
    Hybrid storage abstraction

    Provides unified interface for:
    - Markdown (human-editable)
    - JSON (current state)
    - SQLite (queryable history)
    - Redis (real-time coordination)
    """

    def __init__(self):
        """Initialize storage layer"""
        self._ensure_directories()
        self._init_sqlite()

    def _ensure_directories(self):
        """Ensure all storage directories exist"""
        for directory in [PLANNING_DOCS, JOURNAL_DIR, STATE_DIR, MEMORY_DB.parent]:
            directory.mkdir(parents=True, exist_ok=True)

    def _init_sqlite(self):
        """Initialize SQLite schema"""
        with self._sqlite_connection() as conn:
            cursor = conn.cursor()

            # Sessions table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS sessions (
                    id TEXT PRIMARY KEY,
                    started_at DATETIME,
                    ended_at DATETIME,
                    message_count INTEGER,
                    markdown_file TEXT,
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
                )
            """)

            # Tasks table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS tasks (
                    id TEXT PRIMARY KEY,
                    description TEXT,
                    estimated_hours REAL,
                    actual_hours REAL,
                    status TEXT,
                    markdown_file TEXT,
                    markdown_section TEXT,
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
                )
            """)

            # Decisions table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS decisions (
                    id TEXT PRIMARY KEY,
                    title TEXT,
                    context TEXT,
                    decision TEXT,
                    rationale TEXT,
                    markdown_file TEXT,
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
                )
            """)

            # Patterns table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS patterns (
                    id TEXT PRIMARY KEY,
                    pattern_type TEXT,
                    description TEXT,
                    occurrences INTEGER,
                    confidence REAL,
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
                )
            """)

            # Full-text search for journal entries
            cursor.execute("""
                CREATE VIRTUAL TABLE IF NOT EXISTS journal_fts USING fts5(
                    entry_id,
                    timestamp,
                    entry_type,
                    content,
                    tags,
                    markdown_file
                )
            """)

            conn.commit()

    @contextmanager
    def _sqlite_connection(self):
        """Context manager for SQLite connections"""
        conn = sqlite3.connect(MEMORY_DB)
        conn.row_factory = sqlite3.Row
        try:
            yield conn
        finally:
            conn.close()

    # Markdown Operations

    def read_markdown(self, file_path: str) -> Optional[str]:
        """Read Markdown file"""
        try:
            path = Path(file_path)
            if not path.is_absolute():
                path = STORAGE_ROOT / path

            with path.open('r', encoding='utf-8') as f:
                return f.read()
        except Exception as e:
            print(f"⚠️  Failed to read markdown {file_path}: {e}")
            return None

    def write_markdown(self, file_path: str, content: str, index_in_sqlite: bool = True) -> bool:
        """
        Write Markdown file

        Optionally index in SQLite for queries
        """
        try:
            path = Path(file_path)
            if not path.is_absolute():
                path = STORAGE_ROOT / path

            path.parent.mkdir(parents=True, exist_ok=True)

            with path.open('w', encoding='utf-8') as f:
                f.write(content)

            # Future: Publish event to Redis
            # Future: Index in SQLite if requested

            return True
        except Exception as e:
            print(f"⚠️  Failed to write markdown {file_path}: {e}")
            return False

    # JSON Operations

    def read_json(self, file_path: str) -> Optional[Dict[str, Any]]:
        """Read JSON file"""
        try:
            path = Path(file_path)
            if not path.is_absolute():
                path = STORAGE_ROOT / path

            if not path.exists():
                return None

            with path.open('r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"⚠️  Failed to read JSON {file_path}: {e}")
            return None

    def write_json(self, file_path: str, data: Dict[str, Any]) -> bool:
        """Write JSON file"""
        try:
            path = Path(file_path)
            if not path.is_absolute():
                path = STORAGE_ROOT / path

            path.parent.mkdir(parents=True, exist_ok=True)

            with path.open('w', encoding='utf-8') as f:
                json.dump(data, f, indent=2)

            return True
        except Exception as e:
            print(f"⚠️  Failed to write JSON {file_path}: {e}")
            return False

    # SQLite Operations

    def query_sessions(self, limit: int = 10) -> List[Dict[str, Any]]:
        """Query recent sessions"""
        with self._sqlite_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT * FROM sessions
                ORDER BY started_at DESC
                LIMIT ?
            """, (limit,))

            return [dict(row) for row in cursor.fetchall()]

    def query_tasks(self, status: Optional[str] = None, limit: int = 50) -> List[Dict[str, Any]]:
        """Query tasks"""
        with self._sqlite_connection() as conn:
            cursor = conn.cursor()

            if status:
                cursor.execute("""
                    SELECT * FROM tasks
                    WHERE status = ?
                    ORDER BY created_at DESC
                    LIMIT ?
                """, (status, limit))
            else:
                cursor.execute("""
                    SELECT * FROM tasks
                    ORDER BY created_at DESC
                    LIMIT ?
                """, (limit,))

            return [dict(row) for row in cursor.fetchall()]

    def search_journal(self, query: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Full-text search in journal entries"""
        with self._sqlite_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT * FROM journal_fts
                WHERE journal_fts MATCH ?
                ORDER BY rank
                LIMIT ?
            """, (query, limit))

            return [dict(row) for row in cursor.fetchall()]

    # Session Management

    def save_session(self, session_id: str, data: Dict[str, Any]) -> bool:
        """Save session data (Markdown + SQLite index)"""
        try:
            # Write to Markdown
            markdown_file = f"docs/planning/sessions/session-{session_id}.md"
            self.write_markdown(markdown_file, self._session_to_markdown(data))

            # Index in SQLite
            with self._sqlite_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT OR REPLACE INTO sessions (id, started_at, ended_at, message_count, markdown_file)
                    VALUES (?, ?, ?, ?, ?)
                """, (
                    session_id,
                    data.get('started_at'),
                    data.get('ended_at'),
                    data.get('message_count', 0),
                    markdown_file
                ))
                conn.commit()

            return True
        except Exception as e:
            print(f"⚠️  Failed to save session: {e}")
            return False

    def _session_to_markdown(self, data: Dict[str, Any]) -> str:
        """Convert session data to Markdown"""
        return f"""# Session {data.get('id', 'Unknown')}

**Started**: {data.get('started_at', 'Unknown')}
**Ended**: {data.get('ended_at', 'Ongoing')}
**Messages**: {data.get('message_count', 0)}

## Tasks Completed
{self._format_tasks(data.get('tasks_completed', []))}

## Decisions Made
{self._format_decisions(data.get('decisions', []))}

## Notes
{data.get('notes', 'No notes')}
"""

    def _format_tasks(self, tasks: List[str]) -> str:
        """Format tasks as Markdown list"""
        if not tasks:
            return "No tasks completed"
        return '\n'.join(f"- {task}" for task in tasks)

    def _format_decisions(self, decisions: List[Dict[str, str]]) -> str:
        """Format decisions as Markdown list"""
        if not decisions:
            return "No decisions made"
        return '\n'.join(f"- **{d.get('title', 'Unknown')}**: {d.get('decision', 'N/A')}" for d in decisions)


# Global instance (singleton pattern)
_storage: Optional[StorageLayer] = None


def get_storage() -> StorageLayer:
    """Get global storage layer instance"""
    global _storage
    if _storage is None:
        _storage = StorageLayer()
    return _storage


# Convenience functions

def read_plan(plan_name: str) -> Optional[str]:
    """Read plan file"""
    storage = get_storage()
    return storage.read_markdown(f"docs/specs/{plan_name}.md")


def write_plan(plan_name: str, content: str) -> bool:
    """Write plan file"""
    storage = get_storage()
    return storage.write_markdown(f"docs/specs/{plan_name}.md", content)


def read_session_state() -> Optional[Dict[str, Any]]:
    """Read current session state"""
    storage = get_storage()
    return storage.read_json("state/current.json")


def write_session_state(data: Dict[str, Any]) -> bool:
    """Write current session state"""
    storage = get_storage()
    return storage.write_json("state/current.json", data)


# Example usage
if __name__ == '__main__':
    storage = get_storage()
    print("\n✅ Storage Layer Test\n")

    # Test JSON operations
    test_data = {'foo': 'bar', 'timestamp': datetime.now().isoformat()}
    storage.write_json('test.json', test_data)
    loaded = storage.read_json('test.json')
    print(f"JSON test: {loaded}")

    # Test Markdown operations
    storage.write_markdown('test.md', '# Test\n\nThis is a test.')
    content = storage.read_markdown('test.md')
    print(f"Markdown test: {content[:30]}...")

    # Test SQLite queries
    sessions = storage.query_sessions(limit=5)
    print(f"Recent sessions: {len(sessions)}")

    print("\n✅ Test complete")
