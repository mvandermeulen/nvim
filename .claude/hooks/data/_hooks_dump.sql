PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE schema_migrations (
                version INTEGER PRIMARY KEY,
                description TEXT NOT NULL,
                applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                rollback_sql TEXT
            );
INSERT INTO schema_migrations VALUES(1,'Create Base Schema for Hook System Storage','2026-01-23 18:08:05',NULL);
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
INSERT INTO sessions VALUES('2026-01-27_session_545','2026-01-26T22:04:28Z','2026-01-27T06:04:42.081192','2026-01-26 22:04:28','2026-01-26 22:04:42','🟢',1,'BUILD','LARGE','Agent Orchestration Platform - ALL PHASES COMPLETE','.claude/docs/plans/0004-DEV-012426-AGENT-ORCHESTRATION-PLATFORM.md','completed',100,NULL,NULL,'main',NULL,NULL,NULL);
INSERT INTO sessions VALUES('2026-01-27_session_918','2026-01-26T22:04:46Z','2026-01-30T20:15:48.585543','2026-01-26 22:04:46','2026-01-30 12:15:48','🟢',5,'BUILD','LARGE','Agent Orchestration Platform - ALL PHASES COMPLETE','.claude/docs/plans/0004-DEV-012426-AGENT-ORCHESTRATION-PLATFORM.md','completed',100,NULL,NULL,'main',NULL,NULL,NULL);
INSERT INTO sessions VALUES('2026-01-30_session_589','2026-01-30T12:15:48Z',NULL,'2026-01-30 12:15:48','2026-01-30 12:15:48','🟢',0,'BUILD','LARGE','Agent Orchestration Platform - ALL PHASES COMPLETE','.claude/docs/plans/0004-DEV-012426-AGENT-ORCHESTRATION-PLATFORM.md','completed',100,NULL,NULL,'main',NULL,NULL,NULL);
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
PRAGMA writable_schema=ON;
INSERT INTO sqlite_schema(type,name,tbl_name,rootpage,sql)VALUES('table','journal_fts','journal_fts',0,'CREATE VIRTUAL TABLE journal_fts USING fts5(
    entry_id,
    timestamp UNINDEXED,
    entry_type,
    content,
    tags,
    markdown_file UNINDEXED
)');
CREATE TABLE IF NOT EXISTS 'journal_fts_data'(id INTEGER PRIMARY KEY, block BLOB);
INSERT INTO journal_fts_data VALUES(1,X'');
INSERT INTO journal_fts_data VALUES(10,X'00000000000000');
CREATE TABLE IF NOT EXISTS 'journal_fts_idx'(segid, term, pgno, PRIMARY KEY(segid, term)) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS 'journal_fts_content'(id INTEGER PRIMARY KEY, c0, c1, c2, c3, c4, c5);
CREATE TABLE IF NOT EXISTS 'journal_fts_docsize'(id INTEGER PRIMARY KEY, sz BLOB);
CREATE TABLE IF NOT EXISTS 'journal_fts_config'(k PRIMARY KEY, v) WITHOUT ROWID;
INSERT INTO journal_fts_config VALUES('version',4);
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
INSERT INTO hook_events VALUES(1,'session-start','2026-01-26 21:04:36',NULL,'{}','[{"handler": "session_manager_initialize", "result": {"status": "success", "data": {"session_initialized": true, "current_skill": null, "current_research": null}}}]','success',NULL,1,2);
INSERT INTO hook_events VALUES(2,'user-prompt-submit','2026-01-26 21:04:37',NULL,'{}','[{"handler": "context_manager_update", "result": {"status": "success", "data": {"context_updated": true}}}]','success',NULL,1,3);
INSERT INTO hook_events VALUES(3,'session-start','2026-01-26 21:04:46',NULL,'{}','[{"handler": "session_manager_initialize", "result": {"status": "success", "data": {"session_initialized": true, "current_skill": null, "current_research": null}}}]','success',NULL,1,2);
INSERT INTO hook_events VALUES(4,'session-start','2026-01-26 21:12:33',NULL,'{}','[{"handler": "session_manager_initialize", "result": {"status": "success", "data": {"session_initialized": true, "current_skill": null, "current_research": null}}}]','success',NULL,1,20);
INSERT INTO hook_events VALUES(5,'user-prompt-submit','2026-01-26 21:12:38',NULL,'{}','[{"handler": "context_manager_update", "result": {"status": "success", "data": {"context_updated": true}}}]','success',NULL,1,4);
INSERT INTO hook_events VALUES(6,'pre-tool-use','2026-01-26 21:17:54',NULL,'{}','[{"handler": "context_manager_check_threshold", "result": {"status": "success", "data": {"threshold_ok": true}}}, {"handler": "handle_pre_tool_use", "result": {"status": "skipped", "reason": "Not a file edit operation"}}]','success',NULL,2,3);
INSERT INTO hook_events VALUES(7,'notification','2026-01-26 21:59:14',NULL,'{}','[{"handler": "notification_handler", "result": {"status": "success", "data": {"notification_logged": true, "event_type": "unknown"}}}]','success',NULL,1,4);
DELETE FROM sqlite_sequence;
INSERT INTO sqlite_sequence VALUES('hook_events',7);
CREATE INDEX idx_sessions_started_at ON sessions(started_at DESC);
CREATE INDEX idx_sessions_health_status ON sessions(health_status);
CREATE INDEX idx_sessions_active ON sessions(ended_at) WHERE ended_at IS NULL;
CREATE INDEX idx_tasks_status ON tasks(status, priority DESC);
CREATE INDEX idx_tasks_session ON tasks(session_id, created_at DESC);
CREATE INDEX idx_tasks_parent ON tasks(parent_task_id);
CREATE INDEX idx_decisions_session ON decisions(session_id, created_at DESC);
CREATE INDEX idx_decisions_category ON decisions(category, created_at DESC);
CREATE INDEX idx_decisions_impact ON decisions(impact) WHERE impact IN ('high', 'critical');
CREATE INDEX idx_patterns_type ON patterns(pattern_type, confidence DESC);
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
CREATE INDEX idx_hook_events_session ON hook_events(session_id, event_timestamp DESC);
CREATE INDEX idx_hook_events_hook_name ON hook_events(hook_name, event_timestamp DESC);
CREATE INDEX idx_hook_events_status ON hook_events(status) WHERE status = 'error';
PRAGMA writable_schema=OFF;
COMMIT;
