"""
Suggestion Engine - Unified suggestion system for Claude Code.

Provides:
- suggest_skill: Suggests creator skills for config files (PreToolUse: Write, Edit)
- suggest_subagent: Suggests agent delegation for exploration (PreToolUse: Grep, Glob, Read)
- suggest_optimization: Suggests better tool alternatives (PreToolUse: Bash, Grep, Read)
- suggest_chain: Suggests follow-up specialists after Task (PostToolUse: Task)
"""
# Handler metadata for dispatcher auto-discovery
# PreToolUse handlers (suggest_skill, suggest_subagent, suggest_optimization)
APPLIES_TO_PRE = ["Write", "Edit", "Grep", "Glob", "Read", "Bash", "LSP"]
# PostToolUse handlers (suggest_chain)
APPLIES_TO_POST = ["Task"]

__all__ = [
    # Unified entry points (for dispatchers)
    "handle_pre_tool",
    "suggest_chain",
    # Individual suggesters
    "suggest_skill",
    "suggest_subagent",
    "suggest_optimization",
    # State management
    "atomic_update_state",
    # Metadata
    "APPLIES_TO_PRE",
    "APPLIES_TO_POST",
]

import threading
from pathlib import Path

from hooks.config import Limits, SuggestionPatterns
from hooks.hook_sdk import PreToolUseContext, PostToolUseContext, Response, HookState


# =============================================================================
# State Management (using HookState with in-memory cache)
# =============================================================================

# Global state (not session-scoped) for cross-session suggestion tracking
_hook_state = HookState("suggestion-engine", use_session=False)
_cached_state: dict | None = None
_state_lock = threading.Lock()


def get_state() -> dict:
    """Load or initialize shared suggestion state (thread-safe)."""
    global _cached_state
    with _state_lock:
        if _cached_state is None:
            _cached_state = _hook_state.load(default={})
        return _cached_state.copy()  # Return copy to prevent external mutation


def update_state(updates: dict, save: bool = False) -> None:
    """Update state with new values (thread-safe). Optionally save immediately.

    WARNING: This can lose concurrent updates. Prefer atomic_update_state for
    read-modify-write patterns like incrementing counters.
    """
    global _cached_state
    with _state_lock:
        if _cached_state is None:
            _cached_state = _hook_state.load(default={})
        _cached_state.update(updates)
        _apply_limits()
        if save:
            _hook_state.save(_cached_state)


def atomic_update_state(updater, save: bool = False) -> dict:
    """Atomic read-modify-write pattern (thread-safe).

    Args:
        updater: Function that takes state dict and modifies it in place
        save: Whether to persist to disk after update

    Returns:
        Copy of updated state
    """
    global _cached_state
    with _state_lock:
        if _cached_state is None:
            _cached_state = _hook_state.load(default={})
        updater(_cached_state)
        _apply_limits()
        if save:
            _hook_state.save(_cached_state)
        return _cached_state.copy()


def _apply_limits() -> None:
    """Apply size limits to cached state (must be called under lock)."""
    global _cached_state
    if _cached_state is None:
        return
    if "skills_suggested" in _cached_state:
        _cached_state["skills_suggested"] = list(_cached_state["skills_suggested"])[-Limits.MAX_SUGGESTED_SKILLS:]
    if "recent_patterns" in _cached_state:
        _cached_state["recent_patterns"] = _cached_state["recent_patterns"][-Limits.MAX_RECENT_PATTERNS:]


# =============================================================================
# Unified PreToolUse Entry Point
# =============================================================================


def handle_pre_tool(raw: dict) -> dict | None:
    """Unified PreToolUse handler - routes to appropriate suggestion function.

    Args:
        raw: Raw context dict from dispatcher

    Returns:
        Response dict or None
    """
    tool_name = raw.get("tool_name", "")

    if tool_name in ("Write", "Edit"):
        return suggest_skill(raw)
    elif tool_name in ("Grep", "Glob", "Read"):
        return suggest_subagent(raw) or suggest_optimization(raw)
    elif tool_name == "Bash":
        return suggest_optimization(raw)
    elif tool_name == "LSP":
        return suggest_optimization(raw)

    return None


# =============================================================================
# Skill Suggester (PreToolUse: Write, Edit)
# =============================================================================


def suggest_skill(raw: dict) -> dict | None:
    """Suggest creator skills when writing config files."""
    ctx = PreToolUseContext(raw)
    if ctx.tool_name not in ("Write", "Edit"):
        return None

    file_path = ctx.tool_input.file_path
    if not file_path:
        return None

    for rule in SuggestionPatterns.get_skill_suggestions():
        if rule["pattern"].search(file_path):
            cache_key = f"{rule['skill']}:{Path(file_path).name}"

            # Check and update atomically to prevent duplicate suggestions
            should_suggest = False

            def check_and_add(state):
                nonlocal should_suggest
                suggested = set(state.get("skills_suggested", []))
                if cache_key not in suggested:
                    suggested.add(cache_key)
                    state["skills_suggested"] = list(suggested)
                    should_suggest = True

            atomic_update_state(check_and_add, save=True)

            if not should_suggest:
                return None

            reason = (
                f"Creating {rule['type']} file. "
                f"Consider using the `{rule['skill']}` skill for correct format and patterns. "
                f"Load with: Skill(skill=\"{rule['skill']}\")"
            )
            return Response.allow(reason)
    return None


# =============================================================================
# Subagent Suggester (PreToolUse: Grep, Glob, Read)
# =============================================================================


def suggest_subagent(raw: dict) -> dict | None:
    """Suggest agent delegation for exploration patterns."""
    ctx = PreToolUseContext(raw)

    if ctx.tool_name not in ("Grep", "Glob", "Read"):
        return None

    pattern = ctx.tool_input.pattern or ""
    path = ctx.tool_input.path or ctx.tool_input.file_path or ""

    # Track consecutive searches using atomic update
    if ctx.tool_name in ("Grep", "Glob"):
        def update_searches(state):
            state["consecutive_searches"] = state.get("consecutive_searches", 0) + 1
            recent = state.get("recent_patterns", [])
            recent.append(pattern)
            state["recent_patterns"] = recent[-5:]

        state = atomic_update_state(update_searches, save=True)
    else:
        # Reset consecutive searches on non-search operation
        def reset_searches(state):
            if state.get("consecutive_searches", 0) > 0:
                state["consecutive_searches"] = 0

        state = atomic_update_state(reset_searches, save=True)

    # Rule 1: Multiple consecutive searches
    if state.get("consecutive_searches", 0) >= 3:
        return _subagent_suggestion(
            "exploration",
            f"Multiple searches detected ({state['consecutive_searches']}). "
            "Consider Task(Explore) to search more efficiently."
        )

    # Rule 2: Broad glob patterns
    if ctx.tool_name == "Glob" and pattern:
        if "**" in pattern or pattern.count("*") >= 2:
            if not path or path in (".", "./", "/"):
                return _subagent_suggestion(
                    "exploration",
                    "Broad glob pattern. Consider Task(Explore) for codebase-wide search."
                )

    # Rule 3: Generic grep without specific path
    if ctx.tool_name == "Grep":
        if not path or path in (".", "./"):
            if len(pattern) < 15 and not pattern.startswith("^"):
                return _subagent_suggestion(
                    "exploration",
                    "Exploratory grep. Consider Task(Explore) for better context management."
                )

    # Rule 4: Reading many files
    if ctx.tool_name == "Read":
        def update_reads(state):
            state["recent_reads"] = state.get("recent_reads", 0) + 1

        state = atomic_update_state(update_reads, save=True)
        if state.get("recent_reads", 0) >= 5:
            return _subagent_suggestion(
                "exploration",
                f"Reading multiple files ({state['recent_reads']}). Consider Task(Explore) to offload exploration."
            )

    return None


def _subagent_suggestion(agent_type: str, reason: str) -> dict:
    agent_name, agent_desc = SuggestionPatterns.AGENT_RECOMMENDATIONS.get(agent_type, ("Explore", ""))
    decision_reason = (
        f"[Subagent Suggestion] {reason}\n"
        f"  Recommended: Task(subagent_type='{agent_name}') - {agent_desc}"
    )
    return Response.allow(decision_reason)


# =============================================================================
# Tool Optimizer (PreToolUse: Bash, Grep, Read)
# =============================================================================


def suggest_optimization(raw: dict) -> dict | None:
    """Suggest better tool alternatives."""
    ctx = PreToolUseContext(raw)

    suggestion = None

    if ctx.tool_name == "Bash":
        command = (ctx.tool_input.command or "").strip()
        for pattern, alt, reason in SuggestionPatterns.get_bash_alternatives():
            if pattern.search(command):
                suggestion = f"Consider ~/.claude/scripts/{alt} ({reason})"
                break

    elif ctx.tool_name == "Grep":
        output_mode = ctx.tool_input.output_mode or "files_with_matches"
        if output_mode == "content" and not ctx.tool_input.head_limit:
            suggestion = "Add head_limit to Grep to reduce token usage"

    elif ctx.tool_name == "Read":
        file_path = ctx.tool_input.file_path or ""
        try:
            if file_path and Path(file_path).exists():
                size = Path(file_path).stat().st_size
                if size > 50000:
                    suggestion = "Large file - consider smart-view.sh"
        except Exception:
            pass

    if suggestion:
        return Response.allow(f"[Optimization] {suggestion}")

    return None


# =============================================================================
# Agent Chainer (PostToolUse: Task)
# =============================================================================


def suggest_chain(raw: dict) -> dict | None:
    """Suggest follow-up specialists based on Task output."""
    ctx = PostToolUseContext(raw)

    if ctx.tool_name != "Task":
        return None

    source_agent = ctx.tool_input.subagent_type or ""
    if source_agent not in SuggestionPatterns.CHAINABLE_AGENTS:
        return None

    output = ctx.tool_result.content
    if not output:
        return None

    recommendations = []
    seen_agents = set()

    for rule in SuggestionPatterns.get_chain_rules():
        for pattern in rule["patterns"]:
            if pattern.search(output):
                agent = rule["agent"]
                if agent not in seen_agents and agent != source_agent:
                    recommendations.append({"agent": agent, "reason": rule["reason"]})
                    seen_agents.add(agent)
                break

    if recommendations:
        msg_lines = [f"[Agent Chaining] Based on {source_agent} findings:"]
        for rec in recommendations[:Limits.MAX_CHAIN_RECOMMENDATIONS]:
            msg_lines.append(f"  → Task(subagent_type='{rec['agent']}') - {rec['reason']}")
        msg_lines.append("  Use orchestrator for comprehensive multi-agent review.")

        return Response.message("\n".join(msg_lines), event="PostToolUse")

    return None
