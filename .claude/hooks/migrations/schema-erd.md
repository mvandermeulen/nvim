# Storage Layer Entity Relationship Diagram

## Schema Relationships

```
┌─────────────────────────────────────────────────────────────────┐
│                    schema_migrations                            │
│  (Migration version tracking - no relationships)                │
├─────────────────────────────────────────────────────────────────┤
│  PK: version (INTEGER)                                          │
│      description (TEXT)                                         │
│      applied_at (DATETIME)                                      │
│      rollback_sql (TEXT)                                        │
└─────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────┐
│                        sessions                                 │
│  (Claude Code session lifecycle and health tracking)            │
├─────────────────────────────────────────────────────────────────┤
│  PK: id (TEXT)                                                  │
│      started_at, ended_at (DATETIME)                            │
│      health_status, message_count                               │
│      mode, scope                                                │
│      task_title, task_reference, task_phase, task_progress      │
│      current_file, current_function, branch                     │
│      markdown_file, notes                                       │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   │ 1:N (one session has many...)
                   │
        ┌──────────┼──────────┬──────────────┐
        │          │          │              │
        ▼          ▼          ▼              ▼
┌───────────────┐ ┌──────┐ ┌─────────┐ ┌─────────┐
│  hook_events  │ │tasks │ │decisions│ │patterns │
│               │ │      │ │         │ │         │
├───────────────┤ ├──────┤ ├─────────┤ ├─────────┤
│PK: id (INT)   │ │PK: id│ │PK: id   │ │PK: id   │
│FK: session_id │ │FK:sid│ │FK: sid  │ │No FK    │
│   hook_name   │ │FK:pid│ │  title  │ │pattern  │
│   timestamp   │ │desc  │ │ context │ │type     │
│   event_data  │ │status│ │decision │ │occurr   │
│   status      │ │hours │ │rationale│ │confid   │
│   error_msg   │ │mdfile│ │category │ │         │
│   exec_time   │ │prior │ │impact   │ │         │
└───────────────┘ └──┬───┘ └─────────┘ └─────────┘
                     │
                     │ Self-referencing FK
                     │ (parent_task_id)
                     │
                     ▼
            ┌──────────────┐
            │   Subtasks   │
            │ (same table) │
            └──────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      journal_fts                                │
│  (Virtual FTS5 table for full-text search - no FK relationships)│
├─────────────────────────────────────────────────────────────────┤
│      entry_id, timestamp, entry_type                            │
│      content (searchable), tags                                 │
│      markdown_file                                              │
└─────────────────────────────────────────────────────────────────┘
```

## Relationship Summary

| Parent Table | Child Table | Relationship | Foreign Key | On Delete |
|--------------|-------------|--------------|-------------|-----------|
| sessions | hook_events | 1:N | session_id | CASCADE |
| sessions | tasks | 1:N | session_id | SET NULL |
| sessions | decisions | 1:N | session_id | CASCADE |
| tasks | tasks (self) | 1:N | parent_task_id | CASCADE |

## Cascade Rules

**CASCADE** (delete children when parent deleted):
- `sessions` → `hook_events` - Events belong to session
- `sessions` → `decisions` - Decisions belong to session
- `tasks` → `tasks` (subtasks) - Subtasks belong to parent task

**SET NULL** (preserve children, clear foreign key):
- `sessions` → `tasks` - Keep task history even if session deleted

**No Foreign Key**:
- `patterns` - Standalone analytics table
- `journal_fts` - Search index, linked via markdown_file path
- `schema_migrations` - System table

## Index Strategy

### Primary Key Indexes (automatic)
- All tables have PK indexes

### Foreign Key Indexes
- `hook_events.session_id` - Fast session event lookups
- `tasks.session_id` - Fast session task lookups
- `tasks.parent_task_id` - Fast subtask lookups
- `decisions.session_id` - Fast session decision lookups

### Query Optimization Indexes
- `sessions.started_at DESC` - Chronological session queries
- `sessions.health_status` - Health monitoring
- `sessions.ended_at IS NULL` - Partial index for active sessions
- `tasks.status, priority DESC` - Prioritized task queries
- `hook_events.hook_name, timestamp DESC` - Event type queries
- `hook_events.status = 'error'` - Partial index for error tracking
- `decisions.category, created_at DESC` - Decision categorization
- `decisions.impact IN ('high', 'critical')` - Partial index for important decisions
- `patterns.pattern_type, confidence DESC` - Pattern analysis

## Data Flow

### Write Path
```
Application
    ↓
Repository (Abstract)
    ↓
SQLite Repository (Concrete)
    ↓
├─→ sessions table
├─→ hook_events table
├─→ tasks table
├─→ decisions table
├─→ patterns table
└─→ journal_fts table
    ↓
Redis Cache (optional) ←─ Cache hit/miss
    ↓
Return to Application
```

### Read Path
```
Application
    ↓
Repository (Abstract)
    ↓
Redis Cache? ─────── Cache HIT ──→ Return cached data
    │
    │ Cache MISS
    ↓
SQLite Query
    │
    ├─→ Indexed query (fast)
    └─→ Full table scan (slow, rare)
    ↓
Cache result in Redis
    ↓
Return to Application
```

## Storage Tiers

**Tier 1: Markdown** (Human-editable source of truth)
- Plan files (`.claude/docs/plans/`)
- Journal entries (`.claude/journal/`)
- Session state (`.claude/session/current-session.yaml`)

**Tier 2: SQLite** (Queryable historical data)
- All tables in `sessions.db`
- Structured queries for analytics
- Permanent storage, append-only

**Tier 3: Redis** (Real-time coordination, optional)
- Session state cache
- Task status cache
- Hook event cache
- Pattern confidence cache

## Migration Strategy

All schema changes go through migration system:

1. Create new migration file: `002_add_column.sql`
2. Define forward migration (ALTER TABLE, etc.)
3. Define rollback SQL
4. Insert into `schema_migrations` table
5. Run migration runner

**Version Tracking**:
- `schema_migrations.version` - Sequential integer (1, 2, 3...)
- `schema_migrations.applied_at` - When migration ran
- `schema_migrations.rollback_sql` - How to undo

**Safety**:
- Migrations run in transaction (all or nothing)
- Version conflicts detected
- Rollback available for all migrations
