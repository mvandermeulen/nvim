#!/home/vandem/.claude/data/venv/bin/python3
"""Block dangerous bash commands that could cause system damage.

PreToolUse hook for Bash tool.
Blocks or warns about commands that could cause irreversible damage.

Uses hook_sdk for typed context and response builders.
"""
# Handler metadata for dispatcher auto-discovery
APPLIES_TO = ["Bash"]

__all__ = [
    "APPLIES_TO",
    "check_command",
    "check_dangerous_command",
]

from hooks.hook_sdk import (
    PreToolUseContext,
    Response,
    dispatch_handler,
    log_event,
)
from hooks.config import DangerousCommands


def check_command(command: str) -> tuple[str, str | None]:
    """
    Check command for dangerous patterns.

    Args:
        command: The bash command to check

    Returns:
        (action, reason) where action is 'block', 'warn', or 'allow'
    """
    cmd = command.strip()

    # ReDoS protection: limit input length for regex matching
    # But check BOTH start and end of long commands to prevent bypass
    # (attacker could pad start with 2000 chars of junk before dangerous command)
    MAX_CHUNK = 2000

    # For long commands, check start, end, and around any semicolons/pipes
    if len(cmd) > MAX_CHUNK:
        # Check first chunk
        chunks = [cmd[:MAX_CHUNK]]
        # Check last chunk (where dangerous command might be after padding)
        chunks.append(cmd[-MAX_CHUNK:])
        # Check around command separators (;, &&, ||, |)
        for sep in [';', '&&', '||', '|']:
            if sep in cmd:
                for part in cmd.split(sep):
                    part = part.strip()
                    if part and len(part) <= MAX_CHUNK:
                        chunks.append(part)
    else:
        chunks = [cmd]

    # Check blocked patterns against all chunks
    for chunk in chunks:
        for compiled, reason in DangerousCommands.get_blocked():
            if compiled.search(chunk):
                return ('block', reason)

    # Check warning patterns (only first chunk to avoid excessive warnings)
    for compiled, reason in DangerousCommands.get_warnings():
        if compiled.search(chunks[0]):
            return ('warn', reason)

    return ('allow', None)


@dispatch_handler("dangerous_command_blocker", event="PreToolUse")
def check_dangerous_command(ctx: PreToolUseContext) -> dict | None:
    """
    Handler function for dispatcher.

    Args:
        ctx: PreToolUseContext with typed access to tool input

    Returns:
        Response dict if blocked/warned, None if allowed
    """
    command = ctx.tool_input.command
    if not command:
        return None

    action, reason = check_command(command)

    if action == 'block':
        log_event("dangerous_command_blocker", "blocked", {
            "reason": reason,
            "command": command[:100]
        })
        return Response.deny(
            f"[Dangerous Command] BLOCKED: {reason}. "
            f"Command: {command[:100]}... "
            "This command could cause irreversible system damage."
        )

    if action == 'warn':
        log_event("dangerous_command_blocker", "warning", {
            "reason": reason,
            "command": command[:80]
        })
        return Response.allow(
            f"[Dangerous Command] Warning: {reason}. "
            f"Command: {command[:80]}..."
        )

    return None
