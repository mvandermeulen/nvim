# Automation Infrastructure

This document describes the automated session management and planning system infrastructure.

## Overview

The automation infrastructure ensures:
1. **Session state** is automatically tracked throughout conversations
2. **Message counts** update on every user interaction
3. **Health checks** warn when handover needed
4. **Project-manager** maintains planning documentation

## Components

### 1. Hooks Directory (`.claude/hooks/`)

#### `session-init.sh`
**Purpose**: Initialize session state on conversation start
**Triggers**: SessionStart hook
**Actions**:
- Resets message counter to 0
- Generates new session ID
- Updates session metadata with start timestamp
- Sets health to 🟢

#### `message-counter.sh`
**Purpose**: Track message count throughout conversation
**Triggers**: UserPromptSubmit hook
**Actions**:
- Increments counter file (`.message_count`)
- Updates session state with new count
- Triggers health status recalculation

#### `update-session.sh`
**Purpose**: Core session state updater
**Triggers**: Called by other hooks
**Actions**:
- Updates YAML fields in `current-session.yaml`
- Calculates health status based on message count:
  - 🟢 Healthy (0-30 messages)
  - 🟡 Approaching (31-45 messages)
  - 🔴 Handover Now (46+ messages)
- Updates timestamps in ISO 8601 format

#### `health-check.sh`
**Purpose**: Display current session health and recommendations
**Triggers**: Manual or on-demand
**Actions**:
- Reads current session state
- Displays health indicator and message count
- Provides recommendations based on health status

### 2. Session State File

**Location**: `.claude/session/current-session.yaml`

**Contents**:
```yaml
session:
  id: "YYYY-MM-DD_session_NNN"
  health: "🟢|🟡|🔴"
  message_count: N
  started_at: "ISO 8601 timestamp"
  last_updated: "ISO 8601 timestamp"

mode: "BUILD|DEBUG|REVIEW|LEARN|RAPID"
scope: "MICRO|SMALL|MEDIUM|LARGE|EPIC"

task:
  title: "Current task description"
  phase: "planning|implementation|testing|review|completed"
  progress: 0-100

context:
  current_file: ""
  current_function: ""
  branch: "main"
  last_command: ""

todos:
  completed: []
  in_progress: []
  pending: []

notes:
  - "Session notes"
```

### 3. Hook Configuration

**Location**: `.claude/settings.json`

**Hooks configured**:

```json
"SessionStart": [
  {
    "type": "command",
    "command": "bash .claude/hooks/session-init.sh",
    "timeout": 2
  }
]

"UserPromptSubmit": [
  {
    "type": "command",
    "command": "bash .claude/hooks/message-counter.sh",
    "timeout": 2
  }
]
```

### 4. Project-Manager Agent

**Location**: `.claude/agents/project-manager.md`

**Purpose**: Maintains planning documentation
**Triggers**: Manual via Task tool
**Updates**:
- `.claude/docs/planning/SESSION_STATE.md`
- `.claude/docs/planning/DAILY_BACKLOG.md`
- `.claude/docs/planning/SPRINT_BACKLOG.md`
- `.claude/docs/planning/DECISIONS.md`
- Archives in `.claude/docs/planning/completed/`

## Workflow

### Session Start
```
User starts conversation
  ↓
SessionStart hook fires
  ↓
session-init.sh runs
  ↓
Session state initialized
  ↓
Message counter reset to 0
```

### During Conversation
```
User submits message
  ↓
UserPromptSubmit hook fires
  ↓
message-counter.sh runs
  ↓
Counter increments
  ↓
update-session.sh updates state
  ↓
Health status recalculated
```

### Task Completion
```
Claude completes task
  ↓
Marks todo as completed
  ↓
Triggers project-manager agent
  ↓
Agent updates planning docs
  ↓
Task archived, backlogs refreshed
```

## Health Status Indicators

| Status | Range | Meaning | Action |
|--------|-------|---------|--------|
| 🟢 | 0-30 | Healthy | Normal operation |
| 🟡 | 31-45 | Approaching | Plan handover |
| 🔴 | 46+ | Critical | Handover now |

## Manual Commands

While automation handles most tracking, manual commands available:

### Check Session Health
```bash
bash .claude/hooks/health-check.sh
```

### View Session State
```bash
cat .claude/session/current-session.yaml
```

### Check Message Count
```bash
cat .claude/session/.message_count
```

## Troubleshooting

### Session state not updating
1. Check hooks are executable: `ls -l .claude/hooks/*.sh`
2. Verify settings.json has hooks configured
3. Check for errors in hook logs

### Message count incorrect
1. Reset counter: `echo "0" > .claude/session/.message_count`
2. Re-run session-init.sh
3. Verify UserPromptSubmit hook is firing

### Health status wrong
1. Check message count in session state
2. Verify update-session.sh logic
3. Manually update if needed

## File Permissions

All hook scripts must be executable:
```bash
chmod +x .claude/hooks/*.sh
```

Verified in settings.json permissions:
```json
"allow": [
  "Bash(.claude/hooks/*.sh:*)"
]
```

## Integration with Planning System

The automation infrastructure works with the planning system:

1. **Session hooks** track conversation health
2. **Project-manager agent** maintains planning docs
3. **Together** they provide:
   - Real-time session awareness
   - Automatic documentation updates
   - Handover preparation
   - Context preservation

## Testing

Test the infrastructure:

```bash
# Initialize session
bash .claude/hooks/session-init.sh

# Increment message count
bash .claude/hooks/message-counter.sh

# Check health
bash .claude/hooks/health-check.sh

# Verify session state updated
cat .claude/session/current-session.yaml
```

Expected output:
- Session ID generated
- Message count incremented
- Health status calculated
- Timestamps in ISO 8601

## Future Enhancements

Potential improvements:
1. Automatic handover document generation at 🔴 status
2. Pattern detection for productivity optimization
3. Integration with git hooks for commit tracking
4. Automated backlog prioritization
5. AI-powered task time estimation refinement

## Maintenance

Regular maintenance tasks:
- Archive old session logs
- Clean up `.message_count` files
- Verify hook permissions after git clone
- Update health thresholds if needed
- Review and refine automation logic

## References

- [SESSION_MANAGEMENT.md](SESSION_MANAGEMENT.md): User-facing session management guide
- [PLANNING-SYSTEM.md](PLANNING-SYSTEM.md): Planning system protocol
- [PROJECT_MANAGER_TRIGGERS.md](guides/PROJECT_MANAGER_TRIGGERS.md): When/how to trigger agent
- `.claude/agents/project-manager.md`: Agent configuration

---

**Status**: ✅ Active and tested
**Last Updated**: 2026-01-02
**Maintained By**: Automation infrastructure
