# Hook System Workflows

**Last Updated**: 2026-01-27
**Status**: All hooks verified operational

---

## Overview

The hook system provides intelligent agent orchestration through 7 hook events that execute Python handlers via the central `coordinator.py` dispatcher.

## Hook Configuration (settings.json)

```
SessionStart     → session-init.sh → coordinator.py session-start
SessionEnd       → coordinator.py session-end
PreToolUse       → coordinator.py pre-tool-use
PostToolUse      → coordinator.py post-tool-use
UserPromptSubmit → message-counter.sh → coordinator.py user-prompt-submit
Notification     → claude-activity-tracker.sh
Stop             → claude-activity-tracker.sh
SubagentStop     → claude-activity-tracker.sh
```

---

## Workflow: Session Start

**Trigger**: New Claude Code session begins

**Handlers Executed**:
1. `session_manager_initialize` - Load session state from YAML
2. `load_session_context` (Smart Resume) - Load context from previous session

**Data Flow**:
```
Claude Code SessionStart
        ↓
session-init.sh (create session files)
        ↓
coordinator.py session-start
        ↓
    ┌───┴───────────────────┐
    │                       │
state_manager          Smart Resume
(load YAML)         (load from SQLite)
    │                       │
    └───────────┬───────────┘
                ↓
        Redis broadcast
        (session_started)
                ↓
        Database log
        (hook_events)
                ↓
        Return context summary
```

**Output**: Session context with optional smart resume summary

---

## Workflow: User Prompt Submit

**Trigger**: User sends a message

**Handlers Executed**:
1. `context_manager_update` - Track context usage
2. Message counter increment

**Data Flow**:
```
User sends message
        ↓
message-counter.sh (increment count)
        ↓
coordinator.py user-prompt-submit
        ↓
context_manager_update
        ↓
    ┌───┴───────────────────┐
    │                       │
Check thresholds      Redis broadcast
(31=🟡, 46=🔴)       (if threshold hit)
    │                       │
    └───────────┬───────────┘
                ↓
        Database log
                ↓
        Return: "Message #N"
```

**Output**: Message count reminder, health warnings at thresholds

---

## Workflow: Pre-Tool Use

**Trigger**: Before Claude executes any tool

**Handlers Executed**:
1. `context_manager_check_threshold` - Verify context within limits
2. `handle_pre_tool_use` (Suggestion Engine) - Pre-validation for file edits

**Data Flow**:
```
Tool about to execute
        ↓
coordinator.py pre-tool-use
        ↓
    ┌───┴───────────────────┐
    │                       │
Threshold check       Suggestion Engine
                     (if file edit)
    │                       │
    └───────────┬───────────┘
                ↓
        Database log
                ↓
        Return: warnings (advisory only)
```

**Output**: Advisory warnings, never blocks

---

## Workflow: Post-Tool Use

**Trigger**: After Claude executes any tool

**Handlers Executed**:
1. `session_manager_update_state` - Update session state
2. `handle_post_tool_use` (Suggestion Engine) - Post-validation with auto-fix

**Data Flow**:
```
Tool completed
        ↓
coordinator.py post-tool-use
        ↓
    ┌───┴───────────────────┐
    │                       │
State update          Suggestion Engine
                     (run linters, auto-fix)
    │                       │
    └───────────┬───────────┘
                ↓
        Database log
                ↓
        Return: quality metrics
```

**Output**: Auto-fix results, quality suggestions

---

## Workflow: Session End

**Trigger**: Claude Code session ends

**Handlers Executed**:
1. `session_manager_finalize` - Save final session state

**Data Flow**:
```
Session ending
        ↓
coordinator.py session-end
        ↓
session_manager_finalize
        ↓
    ┌───┴───────────────────┐
    │                       │
Save state            Redis broadcast
(YAML + SQLite)       (session_ended)
    │                       │
    └───────────┬───────────┘
                ↓
        Database log
```

**Output**: Session finalized confirmation

---

## Intelligence Layer Workflows

### Smart Resume (session-start)

Loads optimized context from previous sessions:

```
Session starts
        ↓
Check for previous session ID
        ↓
load_session_context(session_id, max_tokens=4000)
        ↓
    ┌───┴─────────────────────────────────┐
    │           │           │             │
Session     Active      Recent       Key Events
State       Tasks     Decisions      (filtered)
(40%)       (30%)       (20%)          (10%)
    │           │           │             │
    └───────────┴───────────┴─────────────┘
                        ↓
            _generate_context_summary()
                        ↓
            Return markdown summary
```

**Token Allocation**:
- Essential (40%): Session state, active tasks
- High (30%): Recent decisions, key events
- Medium (20%): Completed summary, patterns
- Low (10%): Historical data (optional)

**Performance**: < 100ms load time (benchmark: 0.11ms avg)

### Pattern Recognition

Finds similar past sessions for learning:

```
Current session context
        ↓
find_similar_sessions(context)
        ↓
    ┌───┴───────────────────┐
    │                       │
Compare features      Calculate similarity
(mode, scope, task)   (weighted scoring)
    │                       │
    └───────────┬───────────┘
                ↓
        Return top matches
```

### Decision Learning

Tracks and learns from architectural decisions:

```
Decision recorded
        ↓
record_decision(decision_data)
        ↓
    ┌───┴───────────────────┐
    │                       │
Store in DB          Build decision chain
                     (parent → child)
    │                       │
    └───────────┬───────────┘
                ↓
find_similar_decisions(context)
        ↓
Return lessons learned
```

---

## Data Persistence

### Triple-Write Strategy

All significant data persisted in 3 formats:

| Format | Purpose | Location |
|--------|---------|----------|
| Markdown | Human-readable, git-friendly | `.claude/docs/planning/` |
| YAML | Session state, config | `.claude/session/*.yaml` |
| SQLite | Query layer, analytics | `.claude/hooks/data/hooks.db` |


### Database Tables

| Table | Purpose |
|-------|---------|
| `sessions` | Session lifecycle tracking |
| `tasks` | Task management with progress |
| `decisions` | Architectural decisions |
| `hook_events` | Complete audit trail |
| `patterns` | Recognized patterns |

---

## Redis Coordination (Optional)

When Redis is available, enables multi-agent coordination:

### Broadcast Channels

| Channel | Events |
|---------|--------|
| `agent:lifecycle` | Agent start/stop |
| `agent:work_request` | Task delegation |
| `agent:work_complete` | Task completion |
| `session:lifecycle` | Session start/end |
| `session:health` | Health warnings (🟡/🔴) |
| `planning:update` | Planning doc changes |
| `context:warning` | Context threshold alerts |
| `decision:recorded` | High-impact decisions |

### Graceful Degradation

If Redis unavailable:
- All hooks continue functioning
- Coordination features disabled
- Local-only operation
- Warning logged, no errors thrown

---

## Code Quality Validation

### Pre-Tool Validation (Advisory)

```
File edit detected
        ↓
Check file type
        ↓
    ┌───┴───────────────────┐
    │                       │
Python              TypeScript/JS
(basedpyright)      (tsc)
    │                       │
    └───────────┬───────────┘
                ↓
        Return warnings (no blocking)
```

### Post-Tool Validation (Auto-Fix)

```
File edited
        ↓
Run linter
        ↓
    ┌───┴───────────────────┐
    │                       │
Python (ruff)       TS/JS (eslint)
    │                       │
    └───────────┬───────────┘
                ↓
        Auto-fix if safe
                ↓
        Log quality metrics
```

**Tools Integrated**:
- **Python**: ruff (lint + fix), basedpyright (types)
- **TypeScript**: eslint (lint + fix), tsc (types)
- **JavaScript**: eslint (lint + fix)

---

## Performance Metrics

| Metric | Target | Actual |
|--------|--------|--------|
| Hook execution | < 50ms | 2-20ms |
| Smart resume load | < 100ms | 0.11ms |
| Database write | < 10ms | ~3ms |
| Redis broadcast | < 5ms | ~1ms |

---

## Verification Commands

```bash
# Test all hooks
python3 .claude/hooks/coordinator.py session-start --verbose
python3 .claude/hooks/coordinator.py user-prompt-submit --verbose
python3 .claude/hooks/coordinator.py pre-tool-use --verbose
python3 .claude/hooks/coordinator.py post-tool-use --verbose
python3 .claude/hooks/coordinator.py session-end --verbose

# Check database
sqlite3 .claude/hooks/data/hooks.db ".tables"
sqlite3 .claude/hooks/data/hooks.db "SELECT * FROM hook_events ORDER BY event_timestamp DESC LIMIT 5;"

# Run tests
python3 .claude/hooks/tests/test_smart_resume.py
python3 .claude/hooks/tests/test_redis_coordinator.py

# Check Redis (if available)
redis-cli ping
```

---

## Test Coverage

| Module | Tests | Status |
|--------|-------|--------|
| smart_resume | 20 | ✅ |
| decision_learning | 20 | ✅ |
| pattern_recognition | 29 | ✅ |
| context_optimizer | 15 | ✅ |
| integration | 12 | ✅ |
| redis_coordinator | 15 | ✅ |
| **Total** | **111** | ✅ |

---

## File Structure

```
.claude/hooks/
├── coordinator.py          # Central dispatcher
├── config.py               # Configuration
├── state_manager.py        # Session state
├── redis_coordinator.py    # Multi-agent coordination
├── task_manager.py         # Task persistence
├── decision_manager.py     # Decision tracking
├── handlers/
│   └── suggestion_engine.py  # Code quality
├── intelligence/
│   ├── smart_resume.py       # Context loading
│   ├── decision_learning.py  # Decision chains
│   ├── pattern_recognition.py # Similar sessions
│   └── context_optimizer.py  # Token budgeting
├── repositories/
│   ├── base.py
│   ├── session.py
│   ├── task.py
│   ├── decision.py
│   └── event.py
├── data/
│   └── hooks.db            # SQLite database
└── tests/
    └── test_*.py           # Unit tests (111 total)
```
