-- Migration 001: Create Base Schema for Hook System Storage
-- Created: 2026-01-23
-- Phase: Phase 2 - Storage Layer Implementation
-- Description: Complete SQLite schema for hook events, sessions, tasks, decisions, and migrations

-- Enable foreign key support (must be run per connection)
PRAGMA foreign_keys = ON;

-- ============================================================================
-- Schema Migrations Table
-- ============================================================================
-- Tracks which migrations have been applied and when
-- This table MUST exist before running migrations

CREATE TABLE IF NOT EXISTS schema_migrations (
    version INTEGER PRIMARY KEY,
    description TEXT NOT NULL,
    applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    rollback_sql TEXT  -- SQL to rollback this migration
);

-- ============================================================================
-- Sessions Table (EXTENDED from Phase 1)
-- ============================================================================
-- Tracks Claude Code session lifecycle and health

CREATE TABLE IF NOT EXISTS sessions (
    -- Primary key
    id TEXT PRIMARY KEY,  -- Format: YYYY-MM-DD_session_XXX

    -- Timestamps
    started_at DATETIME NOT NULL,
    ended_at DATETIME,  -- NULL if session still active
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Session metadata (from current-session.yaml)
    health_status TEXT NOT NULL DEFAULT '🟢',  -- 🟢 (0-30) | 🟡 (31-45) | 🔴 (46+)
    message_count INTEGER NOT NULL DEFAULT 0,
    mode TEXT NOT NULL DEFAULT 'BUILD',  -- DEBUG | BUILD | REVIEW | LEARN | RAPID
    scope TEXT NOT NULL DEFAULT 'MEDIUM',  -- MICRO | SMALL | MEDIUM | LARGE | EPIC

    -- Current task tracking
    task_title TEXT,
    task_reference TEXT,  -- Path to plan file
    task_phase TEXT,  -- planning | implementation | testing | review | completed
    task_progress INTEGER DEFAULT 0,  -- 0-100%

    -- Context
    current_file TEXT,
    current_function TEXT,
    branch TEXT DEFAULT 'main',
    last_command TEXT,

    -- Documentation
    markdown_file TEXT,  -- Path to session log markdown
    notes TEXT,  -- JSON array of session notes

    -- Constraints
    CHECK (health_status IN ('🟢', '🟡', '🔴')),
    CHECK (mode IN ('DEBUG', 'BUILD', 'REVIEW', 'LEARN', 'RAPID')),
    CHECK (scope IN ('MICRO', 'SMALL', 'MEDIUM', 'LARGE', 'EPIC')),
    CHECK (task_progress >= 0 AND task_progress <= 100)
);

-- Indexes for common session queries
CREATE INDEX IF NOT EXISTS idx_sessions_started_at ON sessions(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_health_status ON sessions(health_status);
CREATE INDEX IF NOT EXISTS idx_sessions_active ON sessions(ended_at) WHERE ended_at IS NULL;

-- ============================================================================
-- Hook Events Table (NEW in Phase 2)
-- ============================================================================
-- Tracks ALL hook executions for audit trail and debugging

CREATE TABLE IF NOT EXISTS hook_events (
    -- Primary key
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- Event identification
    hook_name TEXT NOT NULL,  -- session-start | user-prompt-submit | pre-tool-use | post-tool-use | session-end
    event_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Relationships
    session_id TEXT,  -- Foreign key to sessions table

    -- Event data
    event_data TEXT,  -- JSON payload from Claude Code
    handler_results TEXT,  -- JSON array of handler results

    -- Status
    status TEXT NOT NULL DEFAULT 'success',  -- success | error | skipped | no_handlers
    error_message TEXT,
    handlers_executed INTEGER DEFAULT 0,

    -- Performance
    execution_time_ms INTEGER,  -- Milliseconds to execute all handlers

    -- Foreign keys
    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE,

    -- Constraints
    CHECK (hook_name IN ('session-start', 'user-prompt-submit', 'pre-tool-use', 'post-tool-use', 'session-end')),
    CHECK (status IN ('success', 'error', 'skipped', 'no_handlers'))
);

-- Indexes for common hook event queries
CREATE INDEX IF NOT EXISTS idx_hook_events_session ON hook_events(session_id, event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_hook_events_hook_name ON hook_events(hook_name, event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_hook_events_status ON hook_events(status) WHERE status = 'error';

-- ============================================================================
-- Tasks Table (EXTENDED from Phase 1)
-- ============================================================================
-- Tracks todos and task progress across sessions

CREATE TABLE IF NOT EXISTS tasks (
    -- Primary key
    id TEXT PRIMARY KEY,  -- UUID or sequential ID

    -- Relationships
    session_id TEXT,  -- Session where task was created
    parent_task_id TEXT,  -- For subtasks (NULL if top-level)

    -- Task metadata
    description TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',  -- pending | in_progress | completed | blocked

    -- Time tracking
    estimated_hours REAL,
    actual_hours REAL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    started_at DATETIME,  -- When marked in_progress
    completed_at DATETIME,  -- When marked completed

    -- Documentation
    markdown_file TEXT,  -- Plan file where task defined
    markdown_section TEXT,  -- Section in plan file

    -- Task metadata
    priority INTEGER DEFAULT 0,  -- Higher = more important
    blockers TEXT,  -- JSON array of blocker descriptions

    -- Foreign keys
    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL,
    FOREIGN KEY (parent_task_id) REFERENCES tasks(id) ON DELETE CASCADE,

    -- Constraints
    CHECK (status IN ('pending', 'in_progress', 'completed', 'blocked')),
    CHECK (priority >= 0)
);

-- Indexes for common task queries
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status, priority DESC);
CREATE INDEX IF NOT EXISTS idx_tasks_session ON tasks(session_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tasks_parent ON tasks(parent_task_id);

-- ============================================================================
-- Decisions Table (EXTENDED from Phase 1)
-- ============================================================================
-- Architectural and technical decisions with context

CREATE TABLE IF NOT EXISTS decisions (
    -- Primary key
    id TEXT PRIMARY KEY,  -- UUID or sequential ID

    -- Relationships
    session_id TEXT NOT NULL,  -- Session where decision made

    -- Decision metadata
    title TEXT NOT NULL,
    context TEXT,  -- Why this decision was needed
    decision TEXT NOT NULL,  -- What was decided
    rationale TEXT,  -- Why this decision was made

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Documentation
    markdown_file TEXT,  -- DECISIONS.md or journal entry

    -- Categorization
    category TEXT,  -- architecture | design | implementation | process
    impact TEXT,  -- low | medium | high | critical

    -- Foreign keys
    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE,

    -- Constraints
    CHECK (category IN ('architecture', 'design', 'implementation', 'process', NULL)),
    CHECK (impact IN ('low', 'medium', 'high', 'critical', NULL))
);

-- Indexes for common decision queries
CREATE INDEX IF NOT EXISTS idx_decisions_session ON decisions(session_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_decisions_category ON decisions(category, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_decisions_impact ON decisions(impact) WHERE impact IN ('high', 'critical');

-- ============================================================================
-- Patterns Table (from Phase 1 - unchanged)
-- ============================================================================
-- Pattern recognition across sessions

CREATE TABLE IF NOT EXISTS patterns (
    id TEXT PRIMARY KEY,
    pattern_type TEXT NOT NULL,
    description TEXT,
    occurrences INTEGER DEFAULT 1,
    confidence REAL DEFAULT 0.0,  -- 0.0 to 1.0
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_seen_at DATETIME,

    -- Constraints
    CHECK (confidence >= 0.0 AND confidence <= 1.0),
    CHECK (occurrences > 0)
);

-- Index for pattern lookups
CREATE INDEX IF NOT EXISTS idx_patterns_type ON patterns(pattern_type, confidence DESC);

-- ============================================================================
-- Journal Full-Text Search (from Phase 1 - unchanged)
-- ============================================================================
-- FTS5 virtual table for fast journal entry search

CREATE VIRTUAL TABLE IF NOT EXISTS journal_fts USING fts5(
    entry_id,
    timestamp UNINDEXED,
    entry_type,
    content,
    tags,
    markdown_file UNINDEXED
);

-- ============================================================================
-- Triggers for Automatic Timestamp Updates
-- ============================================================================

-- Update sessions.updated_at on any change
CREATE TRIGGER IF NOT EXISTS sessions_updated_at
AFTER UPDATE ON sessions
FOR EACH ROW
BEGIN
    UPDATE sessions SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Update tasks.started_at when status changes to in_progress
CREATE TRIGGER IF NOT EXISTS tasks_started_at
AFTER UPDATE OF status ON tasks
FOR EACH ROW
WHEN NEW.status = 'in_progress' AND OLD.status != 'in_progress'
BEGIN
    UPDATE tasks SET started_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Update tasks.completed_at when status changes to completed
CREATE TRIGGER IF NOT EXISTS tasks_completed_at
AFTER UPDATE OF status ON tasks
FOR EACH ROW
WHEN NEW.status = 'completed' AND OLD.status != 'completed'
BEGIN
    UPDATE tasks SET completed_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- ============================================================================
-- Rollback SQL (for migration system)
-- ============================================================================

-- This migration creates tables, so rollback drops them
-- (Stored in schema_migrations.rollback_sql)
/*
DROP TRIGGER IF EXISTS tasks_completed_at;
DROP TRIGGER IF EXISTS tasks_started_at;
DROP TRIGGER IF EXISTS sessions_updated_at;
DROP TABLE IF EXISTS journal_fts;
DROP TABLE IF EXISTS patterns;
DROP INDEX IF EXISTS idx_decisions_impact;
DROP INDEX IF EXISTS idx_decisions_category;
DROP INDEX IF EXISTS idx_decisions_session;
DROP TABLE IF EXISTS decisions;
DROP INDEX IF EXISTS idx_tasks_parent;
DROP INDEX IF EXISTS idx_tasks_session;
DROP INDEX IF EXISTS idx_tasks_status;
DROP TABLE IF EXISTS tasks;
DROP INDEX IF NOT EXISTS idx_hook_events_status;
DROP INDEX IF NOT EXISTS idx_hook_events_hook_name;
DROP INDEX IF NOT EXISTS idx_hook_events_session;
DROP TABLE IF EXISTS hook_events;
DROP INDEX IF EXISTS idx_sessions_active;
DROP INDEX IF EXISTS idx_sessions_health_status;
DROP INDEX IF EXISTS idx_sessions_started_at;
DROP TABLE IF EXISTS sessions;
-- schema_migrations table NOT dropped (needed for migration tracking)
*/

-- ============================================================================
-- End of Migration 001
-- ============================================================================

-- Note: Migration tracking handled by migration runner
