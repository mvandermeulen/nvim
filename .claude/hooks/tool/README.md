# Hooks System

Event-driven Python handlers that extend Claude Code behavior.

## Architecture

```
hooks/
├── config.py           # Centralized configuration (patterns, thresholds, timeouts)
├── hook_sdk.py         # SDK: typed contexts, response builders, HookState
├── hook_utils/         # Utilities: logging, JSON, caching, token counting
├── dispatchers/        # Entry points that route events to handlers
│   ├── pre_tool.py     # PreToolUse dispatcher
│   ├── post_tool.py    # PostToolUse dispatcher
│   └── ...             # Other event dispatchers
├── handlers/           # Business logic
│   ├── custom/         # User-created handlers
│   │   └── handler_template.py  # Copy this to create new handlers
│   └── ...             # Built-in handlers
└── tests/              # Test suite
```

## Quick Start: Creating a Handler

1. **Copy the template:**
   ```bash
   cp handlers/custom/handler_template.py handlers/custom/my_handler.py
   ```

2. **Define which tools to handle:**
   ```python
   APPLIES_TO = ["Bash", "Edit"]  # Tools this handler watches
   ```

3. **Implement your logic:**
   ```python
   def handle_pre_tool(raw: dict) -> dict | None:
       ctx = PreToolUseContext(raw)
       if should_block(ctx):
           return Response.deny("Reason for blocking")
       return None  # Allow
   ```

4. **Register in dispatcher** (handlers/pre_tool.py or post_tool.py):
   ```python
   from hooks.handlers.custom.my_handler import handle_pre_tool as my_handler
   TOOL_HANDLERS["Bash"].append(my_handler)
   ```

## Event Types

| Event | When | Can Block? | Use Case |
|-------|------|------------|----------|
| PreToolUse | Before tool runs | Yes | Validation, security, warnings |
| PostToolUse | After tool runs | No | Logging, analysis, suggestions |
| UserPromptSubmit | Before processing prompt | No | Context monitoring |
| PreCompact | Before context compaction | No | Backup, preserve key context |
| SessionStart | Session begins | No | Load context, project detection |
| SessionEnd | Session ends | No | Save learnings, cleanup |
| Stop | Agent interrupted | No | Save state, uncommitted warnings |

## SDK Reference

### Contexts

```python
from hooks.hook_sdk import PreToolUseContext, PostToolUseContext

# PreToolUse
ctx = PreToolUseContext(raw)
ctx.tool_name      # "Bash", "Edit", etc.
ctx.tool_input     # Typed input (command, file_path, etc.)
ctx.cwd            # Current working directory

# PostToolUse
ctx = PostToolUseContext(raw)
ctx.tool_result    # Typed result (output, exit_code, etc.)
```

### Responses

```python
from hooks.hook_sdk import Response

Response.deny("reason")      # Block tool execution
Response.allow()             # Explicitly allow (same as None)
Response.message("info")     # Add message to context
```

### State Management

```python
from hooks.hook_sdk import HookState

state = HookState("my_handler", use_session=True)
data = state.load(session_id, default={})
state.save(data, session_id)
```

### Logging

```python
from hooks.hook_sdk import log_event

log_event("my_handler", "action", {"key": "value"})
# Writes to ~/.claude/data/hook-events.jsonl
```

## Configuration (config.py)

All thresholds, patterns, and timeouts are centralized:

```python
from hooks.config import Thresholds, Timeouts, Patterns

Thresholds.TOKEN_WARNING     # 40000
Timeouts.CHECKPOINT_INTERVAL # 300 (seconds)
Patterns.DANGEROUS_COMMANDS  # Compiled regex list
```

## Testing

```bash
# Run all hook tests
cd ~/.claude && python -m pytest hooks/tests/

# Run specific test
python -m pytest hooks/tests/test_context_manager.py

# Test handler standalone
echo '{"tool_name": "Bash", "tool_input": {"command": "ls"}}' | \
    python handlers/custom/my_handler.py
```

## Performance

Hooks run on every tool call. Keep latency low:

- Use `lru_cache` for regex compilation (already in config.py)
- Use HookState with TTL for persistent data
- Avoid file I/O in hot paths
- Dispatchers lazy-load handlers

Target: <50ms per hook invocation.
