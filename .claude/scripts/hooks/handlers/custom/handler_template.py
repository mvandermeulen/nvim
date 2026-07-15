#!/home/vandem/.claude/data/venv/bin/python3
"""
Template for creating custom hook handlers.

This template demonstrates how to create a custom PreToolUse or PostToolUse handler.
Copy this file to create your own handler.

Usage:
    1. Copy this file: cp handler_template.py my_handler.py
    2. Update APPLIES_TO with the tools you want to handle
    3. Implement your logic in the handler function
    4. Register in settings.json or dispatcher TOOL_HANDLERS

Handler Types:
    - PreToolUse: Runs before a tool executes. Can block or modify.
    - PostToolUse: Runs after a tool executes. Can add messages.
"""
from hooks.hook_sdk import (
    PreToolUseContext,
    PostToolUseContext,
    Response,
    HookState,
    log_event,
    get_session_id,
)

# =============================================================================
# Handler Metadata
# =============================================================================

# Specify which tools this handler applies to
# Used by dispatcher auto-discovery for routing
APPLIES_TO = ["Bash", "Edit", "Write"]  # Modify for your use case

# For handlers that differ between PreToolUse and PostToolUse:
# APPLIES_TO_PRE = ["Bash"]
# APPLIES_TO_POST = ["Bash", "Edit"]

# Export list for clean imports
__all__ = [
    "APPLIES_TO",
    "handle_pre_tool",
    "handle_post_tool",
]


# =============================================================================
# State Management (optional)
# =============================================================================

# Use HookState for persistent state across calls
# Set use_session=True for per-session state, False for global state
_state = HookState("my_custom_handler", use_session=True, max_age_secs=3600)


def load_state(session_id: str) -> dict:
    """Load handler state for this session."""
    return _state.load(session_id, default={
        "call_count": 0,
        "last_tool": None,
    })


def save_state(session_id: str, state: dict) -> None:
    """Save handler state."""
    _state.save(state, session_id)


# =============================================================================
# PreToolUse Handler
# =============================================================================

def handle_pre_tool(raw: dict) -> dict | None:
    """
    PreToolUse handler - runs before tool execution.
    
    Can return:
        - None: Allow the tool to proceed (most common)
        - Response.deny(reason): Block the tool with an error message
        - Response.message(msg): Allow but add a warning message
        - Response.allow(): Explicitly allow (same as None)
    
    Args:
        raw: Raw hook input dict containing tool_name, tool_input, sessionId, etc.
    
    Returns:
        Response dict or None
    """
    ctx = PreToolUseContext(raw)
    session_id = get_session_id(raw)
    
    # Load state
    state = load_state(session_id)
    state["call_count"] += 1
    state["last_tool"] = ctx.tool_name
    
    # Example: Block certain patterns
    if ctx.tool_name == "Bash":
        command = ctx.tool_input.command or ""
        
        # Example: Block dangerous commands
        if "rm -rf /" in command:
            log_event("custom_handler", "blocked", {"command": command[:100]})
            return Response.deny("This command is too dangerous!")
        
        # Example: Warn about sudo usage
        if command.startswith("sudo"):
            return Response.message("⚠️ Running with sudo privileges")
    
    # Example: Track file modifications
    if ctx.tool_name in ("Edit", "Write"):
        file_path = ctx.tool_input.file_path
        if file_path:
            log_event("custom_handler", "file_operation", {
                "tool": ctx.tool_name,
                "file": file_path,
            })
    
    # Save state
    save_state(session_id, state)
    
    # Allow the tool to proceed
    return None


# =============================================================================
# PostToolUse Handler
# =============================================================================

def handle_post_tool(raw: dict) -> dict | None:
    """
    PostToolUse handler - runs after tool execution.
    
    Can return:
        - None: No additional output
        - Response.message(msg): Add a message to Claude's context
    
    Args:
        raw: Raw hook input dict containing tool_name, tool_input, tool_result, etc.
    
    Returns:
        Response dict or None
    """
    ctx = PostToolUseContext(raw)
    session_id = get_session_id(raw)
    
    # Load state
    state = load_state(session_id)
    
    # Example: Track successful operations
    if ctx.tool_name == "Bash":
        exit_code = ctx.tool_result.exit_code
        output = ctx.tool_result.output or ""
        
        if exit_code != 0:
            # Log failures
            log_event("custom_handler", "bash_failed", {
                "exit_code": exit_code,
                "output_preview": output[:200],
            })
            
            # Example: Add helpful message on specific errors
            if "command not found" in output:
                return Response.message(
                    f"[Custom Handler] Command not found - check if it's installed"
                )
    
    # Example: Track file modifications
    if ctx.tool_name in ("Edit", "Write"):
        file_path = ctx.tool_input.file_path
        if file_path and not ctx.tool_result.raw.get("is_error"):
            log_event("custom_handler", "file_modified", {
                "tool": ctx.tool_name,
                "file": file_path,
            })
    
    # Save state
    save_state(session_id, state)
    
    return None


# =============================================================================
# Standalone Testing
# =============================================================================

if __name__ == "__main__":
    """Allow running the handler standalone for testing."""
    import json
    import sys
    
    # Read input from stdin
    raw = json.load(sys.stdin)
    
    # Detect event type and run appropriate handler
    event = raw.get("event_name", "")
    
    if event == "PreToolUse" or "tool_result" not in raw:
        result = handle_pre_tool(raw)
    else:
        result = handle_post_tool(raw)
    
    # Output result
    if result:
        print(json.dumps(result))
