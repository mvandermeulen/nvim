-- Migration: Add new hook types to hook_events constraint
-- Adds: notification, stop, subagent-stop

-- SQLite doesn't support ALTER TABLE to modify CHECK constraints
-- Need to recreate the table

-- 1. Create new table with updated constraint
CREATE TABLE hook_events_new (
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

-- 2. Copy data
INSERT INTO hook_events_new SELECT * FROM hook_events;

-- 3. Drop old table
DROP TABLE hook_events;

-- 4. Rename new table
ALTER TABLE hook_events_new RENAME TO hook_events;

-- 5. Recreate indexes
CREATE INDEX idx_hook_events_session ON hook_events(session_id, event_timestamp DESC);
CREATE INDEX idx_hook_events_hook_name ON hook_events(hook_name, event_timestamp DESC);
CREATE INDEX idx_hook_events_status ON hook_events(status) WHERE status = 'error';
