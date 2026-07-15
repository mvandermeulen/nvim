#!/usr/bin/env python3
"""
Task Manager - Todo/Task persistence and synchronization

Bridges TodoWrite tool with dual storage:
1. Markdown files (primary, human-readable, git-friendly)
2. SQLite database (query layer for analytics and smart resume)

Dual-write strategy ensures:
- Markdown remains source of truth for human review
- Database enables pattern recognition and intelligence queries

Functions:
- create_task(): Create new task (markdown + database)
- update_task_status(): Update task progress
- get_active_tasks(): Query active tasks
- sync_from_markdown(): Backfill from existing markdown files
"""

# import json
# from datetime import datetime
from typing import Any
from pathlib import Path
import importlib

hooks_dir = Path(__file__).parent
if str(hooks_dir) not in sys.path:
    sys.path.insert(0, str(hooks_dir))

directories = importlib.import_module('directories')

D: directories.Directories = directories.DIRECTORIES  # Alias for easier access




# TaskRepository (optional)
try:
    from repositories.task import TaskRepository  # type: ignore
    HAS_TASK_REPO = True
except ImportError:
    TaskRepository = None  # type: ignore
    HAS_TASK_REPO = False




def create_task(task_data: dict[str, Any]) -> int | None:
    """
    Create new task in both markdown and database

    Args:
        task_data: Task information
            - title: Task title (required)
            - description: Detailed description
            - status: pending | in_progress | completed
            - priority: 0-3 (0=urgent, 3=low)
            - parent_task_id: Parent task ID for subtasks
            - session_id: Current session ID
            - markdown_file: Path to markdown task file

    Returns:
        Task ID from database, or None if database unavailable
    """
    # Always write to markdown first (source of truth)
    _write_to_markdown(task_data)

    # Then sync to database (query layer)
    if not HAS_TASK_REPO or not TaskRepository:
        return None

    try:
        task_repo = TaskRepository(D.db_path)

        # Prepare database record
        db_task = {
            'title': task_data['title'],
            'description': task_data.get('description', ''),
            'status': task_data.get('status', 'pending'),
            'priority': task_data.get('priority', 2),
            'parent_task_id': task_data.get('parent_task_id'),
            'session_id': task_data.get('session_id'),
            'markdown_file': task_data.get('markdown_file'),
        }

        task_id = task_repo.create(db_task)
        return task_id

    except Exception as e:
        print(f"⚠️  Failed to create task in database: {e}")
        return None


def update_task_status(task_id: int, status: str, notes: str | None = None) -> bool:
    """
    Update task status in database

    Args:
        task_id: Database task ID
        status: New status (pending | in_progress | completed)
        notes: Optional notes about status change

    Returns:
        True if updated successfully
    """
    if not HAS_TASK_REPO or not TaskRepository:
        return False

    try:
        task_repo = TaskRepository(D.db_path)

        update_data = {'status': status}

        # SQL triggers automatically update started_at/completed_at
        if notes:
            update_data['notes'] = notes

        return task_repo.update(task_id, update_data)

    except Exception as e:
        print(f"⚠️  Failed to update task status: {e}")
        return False


def get_active_tasks(session_id: str | None = None) -> list[dict[str, Any]]:
    """
    Get active tasks (pending or in_progress)

    Args:
        session_id: Optional session ID filter

    Returns:
        List of active tasks
    """
    if not HAS_TASK_REPO or not TaskRepository:
        return []

    try:
        task_repo = TaskRepository(D.db_path)

        filters = {'status': ['pending', 'in_progress']}
        if session_id:
            filters['session_id'] = session_id

        return task_repo.list(**filters)

    except Exception as e:
        print(f"⚠️  Failed to get active tasks: {e}")
        return []


def get_task_by_id(task_id: int) -> Optional[dict[str, Any]]:
    """Get single task by ID"""
    if not HAS_TASK_REPO or not TaskRepository:
        return None

    try:
        task_repo = TaskRepository(D.db_path)
        return task_repo.get(task_id)
    except Exception as e:
        print(f"⚠️  Failed to get task: {e}")
        return None


def _write_to_markdown(task_data: dict[str, Any]) -> None:
    """
    Write/update task in markdown file

    This is the primary storage - markdown files are source of truth.
    """
    markdown_file = task_data.get('markdown_file')
    if not markdown_file:
        return

    file_path = Path(markdown_file)
    if not file_path.exists():
        print(f"⚠️  Markdown file not found: {file_path}")
        return

    try:
        # Read existing content
        content = file_path.read_text()

        # Add task to checklist (simple append for now)
        # Future: Parse markdown and insert in correct location
        task_line = _format_task_line(task_data)

        # Append to file (or insert in correct section)
        with file_path.open('a') as f:
            f.write(f"\n{task_line}\n")

    except Exception as e:
        print(f"⚠️  Failed to write task to markdown: {e}")


def _format_task_line(task_data: dict[str, Any]) -> str:
    """Format task as markdown checklist item"""
    status_symbol = {
        'pending': '[ ]',
        'in_progress': '[>]',
        'completed': '[x]',
    }.get(task_data.get('status', 'pending'), '[ ]')

    title = task_data['title']
    return f"- {status_symbol} {title}"


def sync_from_markdown(markdown_file: Path, session_id: str | None = None) -> int:
    """
    Backfill database from existing markdown task file

    Parses markdown checklist and creates database records.

    Args:
        markdown_file: Path to markdown file with tasks
        session_id: Optional session ID to associate tasks with

    Returns:
        Number of tasks synchronized
    """
    if not HAS_TASK_REPO or not TaskRepository:
        return 0

    if not markdown_file.exists():
        print(f"⚠️  File not found: {markdown_file}")
        return 0

    try:
        content = markdown_file.read_text()
        tasks = _parse_markdown_tasks(content)

        task_repo = TaskRepository(D.db_path)
        synced_count = 0

        for task_data in tasks:
            try:
                # Add metadata
                task_data['session_id'] = session_id
                task_data['markdown_file'] = str(markdown_file)

                task_repo.create(task_data)
                synced_count += 1
            except Exception as e:
                print(f"⚠️  Failed to sync task '{task_data.get('title')}': {e}")

        return synced_count

    except Exception as e:
        print(f"⚠️  Failed to sync from markdown: {e}")
        return 0


def _parse_markdown_tasks(content: str) -> list[dict[str, Any]]:
    """
    Parse tasks from markdown content

    Looks for patterns like:
    - [ ] Task title
    - [x] Completed task
    - [>] In progress task

    Returns:
        List of task dictionaries
    """
    import re

    tasks = []

    # Pattern: - [x] | [ ] | [>] Task title
    pattern = r'^- \[([ x>])\] (.+)$'

    for line in content.splitlines():
        match = re.match(pattern, line.strip())
        if match:
            status_char = match.group(1)
            title = match.group(2).strip()

            # Map checkbox to status
            status_map = {
                ' ': 'pending',
                '>': 'in_progress',
                'x': 'completed',
                'X': 'completed',
            }
            status = status_map.get(status_char, 'pending')

            tasks.append({
                'title': title,
                'description': '',
                'status': status,
                'priority': 2,  # Default normal priority
            })

    return tasks


# Example usage / testing
if __name__ == '__main__':
    print("\n✅ Task Manager Test\n")

    # Test task creation
    test_task = {
        'title': 'Test Task for Phase 2.6',
        'description': 'Verify task manager integration',
        'status': 'in_progress',
        'priority': 1,
        'session_id': 'test-session-001',
        'markdown_file': '.claude/docs/plans/0004-DEV-012426-AGENT-ORCHESTRATION-PLATFORM.md'
    }

    task_id = create_task(test_task)
    if task_id:
        print(f"✅ Task created: ID={task_id}")

        # Update status
        success = update_task_status(task_id, 'completed', 'Test completed successfully')
        print(f"✅ Task updated: {success}")

        # Get task
        task = get_task_by_id(task_id)
        if task:
            print(f"✅ Task retrieved: {task['title']} ({task['status']})")

    # Test markdown parsing
    test_md = """
# Test Tasks

- [ ] Pending task
- [x] Completed task
- [>] In progress task
"""
    tasks = _parse_markdown_tasks(test_md)
    print(f"\n✅ Parsed {len(tasks)} tasks from markdown:")
    for t in tasks:
        print(f"  - {t['title']} ({t['status']})")
