CREATE TABLE schema_migrations (
                version INTEGER PRIMARY KEY,
                description TEXT NOT NULL,
                applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                rollback_sql TEXT
            );
CREATE TABLE sessions (
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
CREATE INDEX idx_sessions_started_at ON sessions(started_at DESC);
CREATE INDEX idx_sessions_health_status ON sessions(health_status);
CREATE INDEX idx_sessions_active ON sessions(ended_at) WHERE ended_at IS NULL;
CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE tasks (
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
CREATE INDEX idx_tasks_status ON tasks(status, priority DESC);
CREATE INDEX idx_tasks_session ON tasks(session_id, created_at DESC);
CREATE INDEX idx_tasks_parent ON tasks(parent_task_id);
CREATE TABLE decisions (
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
CREATE INDEX idx_decisions_session ON decisions(session_id, created_at DESC);
CREATE INDEX idx_decisions_category ON decisions(category, created_at DESC);
CREATE INDEX idx_decisions_impact ON decisions(impact) WHERE impact IN ('high', 'critical');
CREATE TABLE patterns (
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
CREATE INDEX idx_patterns_type ON patterns(pattern_type, confidence DESC);
CREATE VIRTUAL TABLE journal_fts USING fts5(
    entry_id,
    timestamp UNINDEXED,
    entry_type,
    content,
    tags,
    markdown_file UNINDEXED
)
/* journal_fts(entry_id,timestamp,entry_type,content,tags,markdown_file) */;
CREATE TABLE IF NOT EXISTS 'journal_fts_data'(id INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE IF NOT EXISTS 'journal_fts_idx'(segid, term, pgno, PRIMARY KEY(segid, term)) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS 'journal_fts_content'(id INTEGER PRIMARY KEY, c0, c1, c2, c3, c4, c5);
CREATE TABLE IF NOT EXISTS 'journal_fts_docsize'(id INTEGER PRIMARY KEY, sz BLOB);
CREATE TABLE IF NOT EXISTS 'journal_fts_config'(k PRIMARY KEY, v) WITHOUT ROWID;
CREATE TRIGGER sessions_updated_at
AFTER UPDATE ON sessions
FOR EACH ROW
BEGIN
    UPDATE sessions SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;
CREATE TRIGGER tasks_started_at
AFTER UPDATE OF status ON tasks
FOR EACH ROW
WHEN NEW.status = 'in_progress' AND OLD.status != 'in_progress'
BEGIN
    UPDATE tasks SET started_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;
CREATE TRIGGER tasks_completed_at
AFTER UPDATE OF status ON tasks
FOR EACH ROW
WHEN NEW.status = 'completed' AND OLD.status != 'completed'
BEGIN
    UPDATE tasks SET completed_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;
CREATE TABLE IF NOT EXISTS "hook_events" (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hook_name TEXT NOT NULL,
    event_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    session_id TEXT,
    event_data TEXT,
    handler_results TEXT,
    status TEXT NOT NULL DEFAULT 'success',
    error_message TEXT,
    handlers_executed INTEGER DEFAULT 0,
    execution_time_ms INTEGER,
    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE,
    CHECK (hook_name IN ('session-start', 'user-prompt-submit', 'pre-tool-use', 'post-tool-use', 'session-end', 'notification', 'stop', 'subagent-stop')),
    CHECK (status IN ('success', 'error', 'skipped', 'no_handlers'))
);
CREATE INDEX idx_hook_events_session ON hook_events(session_id, event_timestamp DESC);
CREATE INDEX idx_hook_events_hook_name ON hook_events(hook_name, event_timestamp DESC);
CREATE INDEX idx_hook_events_status ON hook_events(status) WHERE status = 'error';
