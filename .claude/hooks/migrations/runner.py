"""Migration Runner for Hook System Storage

Manages SQLite schema migrations with apply, rollback, and status tracking.

Usage:
    from migrations.runner import MigrationRunner

    runner = MigrationRunner(db_path=".claude/hooks/hook_system.db")
    runner.apply_migrations()  # Apply all pending
    runner.rollback_migration(version=1)  # Rollback specific version
    runner.status()  # Show applied migrations
"""

import sqlite3
from pathlib import Path
from typing import List, Optional, Tuple
from dataclasses import dataclass
from datetime import datetime
import logging

logger = logging.getLogger(__name__)


@dataclass
class Migration:
    """Represents a single migration file."""

    version: int
    filename: str
    description: str
    forward_sql: str
    rollback_sql: Optional[str] = None

    @classmethod
    def from_file(cls, filepath: Path) -> "Migration":
        """Parse migration from SQL file.

        Expected format:
            -- Migration 001: Description here
            -- Rollback: (optional)
            -- ... rollback SQL here ...
            -- End Rollback

            CREATE TABLE ...
            (forward migration SQL)
        """
        content = filepath.read_text()
        lines = content.split('\n')

        # Extract version from filename (001_create_base_schema.sql -> 1)
        version_str = filepath.stem.split('_')[0]
        version = int(version_str)

        # Extract description from first comment line
        description = ""
        for line in lines:
            if line.startswith('-- Migration'):
                description = line.split(':', 1)[1].strip()
                break

        # Separate forward and rollback SQL
        forward_sql = []
        rollback_sql = []
        in_rollback = False

        for line in lines:
            if line.strip().startswith('-- Rollback:'):
                in_rollback = True
                continue
            elif line.strip().startswith('-- End Rollback'):
                in_rollback = False
                continue

            if in_rollback:
                if not line.startswith('--'):  # Skip comment lines
                    rollback_sql.append(line)
            else:
                if not line.startswith('--'):  # Skip comment lines
                    forward_sql.append(line)

        return cls(
            version=version,
            filename=filepath.name,
            description=description,
            forward_sql='\n'.join(forward_sql).strip(),
            rollback_sql='\n'.join(rollback_sql).strip() if rollback_sql else None
        )


class MigrationRunner:
    """Manages database schema migrations."""

    def __init__(self, db_path: str | Path, migrations_dir: Optional[Path] = None):
        """Initialize migration runner.

        Args:
            db_path: Path to SQLite database file
            migrations_dir: Directory containing migration SQL files
                           (defaults to same directory as this file)
        """
        self.db_path = Path(db_path)
        self.migrations_dir = migrations_dir or Path(__file__).parent

        # Ensure database directory exists
        self.db_path.parent.mkdir(parents=True, exist_ok=True)

        logger.info(f"Migration runner initialized: db={self.db_path}, migrations={self.migrations_dir}")

    def _get_connection(self) -> sqlite3.Connection:
        """Get database connection with foreign keys enabled."""
        conn = sqlite3.Connection(str(self.db_path))
        conn.execute("PRAGMA foreign_keys = ON")
        return conn

    def _ensure_migrations_table(self, conn: sqlite3.Connection) -> None:
        """Create schema_migrations table if it doesn't exist."""
        conn.execute("""
            CREATE TABLE IF NOT EXISTS schema_migrations (
                version INTEGER PRIMARY KEY,
                description TEXT NOT NULL,
                applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                rollback_sql TEXT
            )
        """)
        conn.commit()

    def _get_applied_migrations(self, conn: sqlite3.Connection) -> List[int]:
        """Get list of applied migration versions."""
        cursor = conn.execute("SELECT version FROM schema_migrations ORDER BY version")
        return [row[0] for row in cursor.fetchall()]

    def _discover_migrations(self) -> List[Migration]:
        """Discover all migration files in migrations directory."""
        migration_files = sorted(self.migrations_dir.glob('[0-9][0-9][0-9]_*.sql'))

        migrations = []
        for filepath in migration_files:
            try:
                migration = Migration.from_file(filepath)
                migrations.append(migration)
                logger.debug(f"Discovered migration: {migration.version} - {migration.description}")
            except Exception as e:
                logger.error(f"Failed to parse migration {filepath}: {e}")
                raise

        return sorted(migrations, key=lambda m: m.version)

    def _validate_migration_order(self, migrations: List[Migration]) -> None:
        """Ensure migrations are numbered sequentially."""
        expected = 1
        for migration in migrations:
            if migration.version != expected:
                raise ValueError(
                    f"Migration gap detected: expected version {expected}, "
                    f"found {migration.version} ({migration.filename})"
                )
            expected += 1

    def apply_migrations(self, target_version: Optional[int] = None) -> int:
        """Apply all pending migrations up to target version.

        Args:
            target_version: Apply migrations up to this version (None = all)

        Returns:
            Number of migrations applied
        """
        conn = self._get_connection()
        try:
            self._ensure_migrations_table(conn)

            applied = self._get_applied_migrations(conn)
            available = self._discover_migrations()
            self._validate_migration_order(available)

            # Filter to pending migrations
            pending = [m for m in available if m.version not in applied]

            if target_version:
                pending = [m for m in pending if m.version <= target_version]

            if not pending:
                logger.info("No pending migrations")
                return 0

            logger.info(f"Applying {len(pending)} migration(s)")

            applied_count = 0
            for migration in pending:
                logger.info(f"Applying migration {migration.version}: {migration.description}")

                try:
                    # Execute forward migration
                    conn.executescript(migration.forward_sql)

                    # Record in migrations table
                    conn.execute(
                        """
                        INSERT INTO schema_migrations (version, description, rollback_sql)
                        VALUES (?, ?, ?)
                        """,
                        (migration.version, migration.description, migration.rollback_sql)
                    )

                    conn.commit()
                    applied_count += 1
                    logger.info(f"✓ Migration {migration.version} applied successfully")

                except Exception as e:
                    conn.rollback()
                    logger.error(f"✗ Migration {migration.version} failed: {e}")
                    raise RuntimeError(
                        f"Migration {migration.version} failed: {e}\n"
                        f"All changes have been rolled back."
                    ) from e

            logger.info(f"Successfully applied {applied_count} migration(s)")
            return applied_count

        finally:
            conn.close()

    def rollback_migration(self, version: int) -> None:
        """Rollback a specific migration version.

        Args:
            version: Migration version to rollback
        """
        conn = self._get_connection()
        try:
            self._ensure_migrations_table(conn)

            # Get rollback SQL from migrations table
            cursor = conn.execute(
                "SELECT rollback_sql, description FROM schema_migrations WHERE version = ?",
                (version,)
            )
            row = cursor.fetchone()

            if not row:
                raise ValueError(f"Migration version {version} not found in applied migrations")

            rollback_sql, description = row

            if not rollback_sql:
                raise ValueError(
                    f"Migration {version} has no rollback SQL defined. "
                    f"Cannot rollback migration '{description}'."
                )

            logger.info(f"Rolling back migration {version}: {description}")

            try:
                # Execute rollback SQL
                conn.executescript(rollback_sql)

                # Remove from migrations table
                conn.execute("DELETE FROM schema_migrations WHERE version = ?", (version,))

                conn.commit()
                logger.info(f"✓ Migration {version} rolled back successfully")

            except Exception as e:
                conn.rollback()
                logger.error(f"✗ Rollback {version} failed: {e}")
                raise RuntimeError(
                    f"Rollback of migration {version} failed: {e}\n"
                    f"Database may be in inconsistent state. Manual intervention required."
                ) from e

        finally:
            conn.close()

    def rollback_to_version(self, target_version: int) -> int:
        """Rollback all migrations after target version.

        Args:
            target_version: Rollback to this version (keeping this version applied)

        Returns:
            Number of migrations rolled back
        """
        conn = self._get_connection()
        try:
            self._ensure_migrations_table(conn)

            applied = self._get_applied_migrations(conn)
            to_rollback = [v for v in applied if v > target_version]
            to_rollback.sort(reverse=True)  # Rollback in reverse order

            if not to_rollback:
                logger.info(f"Already at version {target_version}")
                return 0

            logger.info(f"Rolling back {len(to_rollback)} migration(s) to version {target_version}")

            rollback_count = 0
            for version in to_rollback:
                self.rollback_migration(version)
                rollback_count += 1

            logger.info(f"Successfully rolled back {rollback_count} migration(s)")
            return rollback_count

        finally:
            conn.close()

    def status(self) -> List[Tuple[int, str, str, bool]]:
        """Get status of all migrations.

        Returns:
            List of tuples: (version, description, applied_at, is_applied)
        """
        conn = self._get_connection()
        try:
            self._ensure_migrations_table(conn)

            applied_dict = {}
            cursor = conn.execute(
                "SELECT version, description, applied_at FROM schema_migrations ORDER BY version"
            )
            for version, description, applied_at in cursor.fetchall():
                applied_dict[version] = (description, applied_at)

            available = self._discover_migrations()

            status_list = []
            for migration in available:
                if migration.version in applied_dict:
                    desc, applied_at = applied_dict[migration.version]
                    status_list.append((migration.version, desc, applied_at, True))
                else:
                    status_list.append((migration.version, migration.description, "Not applied", False))

            return status_list

        finally:
            conn.close()

    def print_status(self) -> None:
        """Print migration status to console."""
        status = self.status()

        if not status:
            print("No migrations found")
            return

        print("\nMigration Status:")
        print("=" * 80)
        print(f"{'Version':<10} {'Status':<15} {'Description':<35} {'Applied At'}")
        print("-" * 80)

        for version, description, applied_at, is_applied in status:
            status_str = "✓ Applied" if is_applied else "○ Pending"
            desc_short = description[:33] + "..." if len(description) > 35 else description
            print(f"{version:<10} {status_str:<15} {desc_short:<35} {applied_at}")

        print("=" * 80)

        applied_count = sum(1 for _, _, _, is_applied in status if is_applied)
        pending_count = len(status) - applied_count
        print(f"Applied: {applied_count}, Pending: {pending_count}")
        print()

    def reset(self) -> None:
        """WARNING: Drop all tables and reset database.

        This is a destructive operation. Use only for testing.
        """
        logger.warning("RESET: Dropping all tables and resetting database")

        conn = self._get_connection()
        try:
            # Get all tables
            cursor = conn.execute(
                "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
            )
            tables = [row[0] for row in cursor.fetchall()]

            # Drop all tables
            for table in tables:
                conn.execute(f"DROP TABLE IF EXISTS {table}")

            conn.commit()
            logger.warning(f"RESET: Dropped {len(tables)} table(s)")

        finally:
            conn.close()


def main():
    """CLI entry point for migration runner."""
    import argparse

    parser = argparse.ArgumentParser(description="Hook System Migration Runner")
    parser.add_argument(
        "--db-path",
        default=".claude/hooks/hook_system.db",
        help="Path to SQLite database file"
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    # apply command
    apply_parser = subparsers.add_parser("apply", help="Apply pending migrations")
    apply_parser.add_argument("--target", type=int, help="Apply up to this version")

    # rollback command
    rollback_parser = subparsers.add_parser("rollback", help="Rollback migrations")
    rollback_parser.add_argument("version", type=int, help="Rollback this version")

    # rollback-to command
    rollback_to_parser = subparsers.add_parser("rollback-to", help="Rollback to specific version")
    rollback_to_parser.add_argument("version", type=int, help="Rollback to this version")

    # status command
    subparsers.add_parser("status", help="Show migration status")

    # reset command
    subparsers.add_parser("reset", help="WARNING: Drop all tables (testing only)")

    args = parser.parse_args()

    # Configure logging
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )

    runner = MigrationRunner(db_path=args.db_path)

    try:
        if args.command == "apply":
            count = runner.apply_migrations(target_version=args.target)
            print(f"\n✓ Applied {count} migration(s)\n")
            runner.print_status()

        elif args.command == "rollback":
            runner.rollback_migration(version=args.version)
            print(f"\n✓ Rolled back migration {args.version}\n")
            runner.print_status()

        elif args.command == "rollback-to":
            count = runner.rollback_to_version(target_version=args.version)
            print(f"\n✓ Rolled back {count} migration(s)\n")
            runner.print_status()

        elif args.command == "status":
            runner.print_status()

        elif args.command == "reset":
            confirm = input("WARNING: This will delete all data. Type 'yes' to confirm: ")
            if confirm.lower() == "yes":
                runner.reset()
                print("\n✓ Database reset complete\n")
            else:
                print("Reset cancelled")

    except Exception as e:
        logger.error(f"Command failed: {e}")
        exit(1)


if __name__ == "__main__":
    main()
