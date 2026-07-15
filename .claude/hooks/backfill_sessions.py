#!/usr/bin/env python3
"""
Backfill Sessions Script

One-time migration script to backfill existing session data into SQLite database.

Reads from:
- .claude/session/current-session.yaml (active session)
- .claude/session/handover/*.md (historical sessions)

Writes to:
- .claude/hooks/data/hooks.db (sessions table)

Usage:
    python3 scripts/backfill_sessions.py
    python3 scripts/backfill_sessions.py --dry-run  # Preview without writing
"""

import yaml
from pathlib import Path
from datetime import datetime
from typing import Any



from repositories.session import SessionRepository  # type: ignore



def load_current_session() -> dict[str, Any]:
    """Load active session from YAML"""
    if not CURRENT_SESSION_FILE.exists():
        print("⚠️  No current session file found")
        return {}

    try:
        with CURRENT_SESSION_FILE.open('r') as f:
            data = yaml.safe_load(f)
            return data or {}
    except Exception as e:
        print(f"⚠️  Failed to load current session: {e}")
        return {}


def load_handover_sessions() -> list[dict[str, Any]]:
    """Load historical sessions from handover files"""
    if not HANDOVER_DIR.exists():
        print("⚠️  No handover directory found")
        return []

    sessions = []

    for handover_file in HANDOVER_DIR.glob('handover-*.md'):
        try:
            session_data = parse_handover_file(handover_file)
            if session_data:
                sessions.append(session_data)
        except Exception as e:
            print(f"⚠️  Failed to parse {handover_file.name}: {e}")

    return sessions


def parse_handover_file(file_path: Path) -> dict[str, Any]:
    """
    Parse handover markdown file for session data

    Extracts:
    - Session date from filename (handover-YYYY-MM-DD-HH-MM-SS.md)
    - Task info from content
    - Progress from content
    """
    # Extract date from filename
    filename = file_path.stem  # handover-2026-01-23-19-20-00
    parts = filename.split('-')

    if len(parts) < 7:
        print(f"⚠️  Invalid handover filename format: {filename}")
        return {}

    try:
        year, month, day = parts[1:4]
        hour, minute, second = parts[4:7]

        session_id = f"session-{year}-{month}-{day}-{hour}{minute}{second}"
        started_at = f"{year}-{month}-{day}T{hour}:{minute}:{second}"

        # Parse content for task info
        content = file_path.read_text()

        # Extract task title (look for ## Current Task or # Task)
        task_title = extract_task_title(content)

        # Extract progress percentage
        task_progress = extract_progress(content)

        # Extract mode and scope if present
        mode = extract_field(content, 'Mode:')
        scope = extract_field(content, 'Scope:')

        return {
            'id': session_id,
            'started_at': started_at,
            'ended_at': started_at,  # Handover marks session end
            'health_status': '🟢',  # Assume healthy if handed over
            'message_count': 0,  # Unknown from handover
            'mode': mode or 'BUILD',
            'scope': scope or 'MEDIUM',
            'task_title': task_title,
            'task_progress': task_progress,
            'markdown_file': str(file_path),
        }

    except Exception as e:
        print(f"⚠️  Failed to parse handover date: {e}")
        return {}


def extract_task_title(content: str) -> str:
    """Extract task title from handover content"""
    import re

    # Look for ## Current Task or # Task
    patterns = [
        r'## Current Task[:\s]+(.+)',
        r'# Task[:\s]+(.+)',
        r'\*\*Task\*\*[:\s]+(.+)',
    ]

    for pattern in patterns:
        match = re.search(pattern, content, re.MULTILINE)
        if match:
            return match.group(1).strip()

    return 'Unknown Task'


def extract_progress(content: str) -> int:
    """Extract progress percentage from content"""
    import re

    # Look for XX% or Progress: XX%
    patterns = [
        r'(\d+)%\s+complete',
        r'Progress[:\s]+(\d+)%',
        r'at (\d+)%',
    ]

    for pattern in patterns:
        match = re.search(pattern, content, re.IGNORECASE)
        if match:
            try:
                return int(match.group(1))
            except ValueError:
                pass

    return 0


def extract_field(content: str, field_name: str) -> str:
    """Extract field value from content"""
    import re

    pattern = rf'{re.escape(field_name)}\s+(.+)'
    match = re.search(pattern, content, re.MULTILINE)

    if match:
        return match.group(1).strip()

    return ''


def backfill_session(session_data: dict[str, Any], repo: SessionRepository, dry_run: bool = False) -> bool:
    """
    Backfill single session into database

    Args:
        session_data: Session data dictionary
        repo: SessionRepository instance
        dry_run: If True, only print what would be done

    Returns:
        True if successful
    """
    session_id = session_data.get('id', 'unknown')

    if dry_run:
        print(f"[DRY RUN] Would create session: {session_id}")
        print(f"  Task: {session_data.get('task_title', 'N/A')}")
        print(f"  Progress: {session_data.get('task_progress', 0)}%")
        print(f"  Mode: {session_data.get('mode', 'N/A')}, Scope: {session_data.get('scope', 'N/A')}")
        return True

    try:
        # Check if session already exists
        existing = repo.get(session_id)

        if existing:
            print(f"  ⚠️  Session already exists: {session_id}")
            return False

        # Create session
        repo.create(session_data)
        print(f"  ✅ Created session: {session_id}")
        return True

    except Exception as e:
        print(f"  ❌ Failed to create session {session_id}: {e}")
        return False


def main():
    """Main backfill process"""
    import argparse

    parser = argparse.ArgumentParser(description='Backfill sessions into database')
    parser.add_argument('--dry-run', action='store_true', help='Preview without writing')
    args = parser.parse_args()

    print("\n✅ Session Backfill Script\n")
    print(f"Database: {DB_PATH}")
    print(f"Mode: {'DRY RUN' if args.dry_run else 'WRITE'}\n")

    # Initialize repository
    repo = SessionRepository(DB_PATH)

    # Load current session
    print("📋 Loading current session...")
    current_session = load_current_session()

    # Load historical sessions
    print("📋 Loading handover sessions...")
    handover_sessions = load_handover_sessions()

    print(f"\nFound {len(handover_sessions)} handover sessions")

    # Backfill historical sessions first
    print("\n🔄 Backfilling historical sessions...\n")
    success_count = 0
    fail_count = 0

    for session in handover_sessions:
        if backfill_session(session, repo, dry_run=args.dry_run):
            success_count += 1
        else:
            fail_count += 1

    # Backfill current session
    if current_session:
        print("\n🔄 Backfilling current session...\n")

        # Generate session ID if not present
        if 'id' not in current_session:
            current_session['id'] = f"session-{datetime.now().strftime('%Y-%m-%d-%H%M%S')}"

        if 'started_at' not in current_session:
            current_session['started_at'] = datetime.now().isoformat()

        if backfill_session(current_session, repo, dry_run=args.dry_run):
            success_count += 1
        else:
            fail_count += 1

    # Summary
    print("\n" + "="*50)
    print("📊 Backfill Summary")
    print("="*50)
    print(f"✅ Successfully backfilled: {success_count}")
    print(f"❌ Failed: {fail_count}")
    print(f"📁 Total sessions processed: {success_count + fail_count}")

    if args.dry_run:
        print("\n💡 Run without --dry-run to actually write to database")

    print()


if __name__ == '__main__':
    main()
