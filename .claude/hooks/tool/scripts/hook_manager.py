#!/home/vandem/.claude/data/venv/bin/python3
"""
Hook Manager - Unified CLI for managing Claude Code hooks.

Provides:
- List all hooks and their status
- Enable/disable hooks (persistent or session-scoped)
- Show detailed hook status (last run, errors, latency)
- View recent log entries for hooks

Usage:
    python hook_manager.py list
    python hook_manager.py status [hook_name]
    python hook_manager.py enable <hook_name> [--session]
    python hook_manager.py disable <hook_name> [--session]
    python hook_manager.py logs [hook_name] [--lines N]
"""
import argparse
import json
import os
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Optional

# Paths
CLAUDE_DIR = Path.home() / ".claude"
HOOKS_DIR = CLAUDE_DIR / "hooks"
HANDLERS_DIR = HOOKS_DIR / "handlers"
DISPATCHERS_DIR = HOOKS_DIR / "dispatchers"
DATA_DIR = CLAUDE_DIR / "data"
CONFIG_FILE = DATA_DIR / "hook-config.json"
LOG_FILE = DATA_DIR / "hook-events.jsonl"
SESSION_DIR = DATA_DIR / "session-hooks"

# ANSI colors
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
CYAN = "\033[0;36m"
NC = "\033[0m"  # No color


def ensure_config() -> dict:
    """Ensure config file exists and return its contents."""
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    if not CONFIG_FILE.exists():
        CONFIG_FILE.write_text('{"disabled": [], "updated": ""}')
    try:
        return json.loads(CONFIG_FILE.read_text())
    except json.JSONDecodeError:
        return {"disabled": [], "updated": ""}


def save_config(config: dict) -> None:
    """Save config to file."""
    config["updated"] = datetime.now().isoformat()
    CONFIG_FILE.write_text(json.dumps(config, indent=2))


def get_session_id() -> str:
    """Get current session ID."""
    if session_id := os.environ.get("CLAUDE_SESSION_ID"):
        return session_id
    if transcript_dir := os.environ.get("CLAUDE_TRANSCRIPT_DIR"):
        return Path(transcript_dir).name
    # Generate or retrieve persistent session ID
    session_file = DATA_DIR / ".current-session"
    if session_file.exists():
        return session_file.read_text().strip()
    import uuid
    new_id = str(uuid.uuid4())[:8]
    session_file.write_text(new_id)
    return new_id


def get_session_config_path() -> Path:
    """Get session-specific config file path."""
    SESSION_DIR.mkdir(parents=True, exist_ok=True)
    return SESSION_DIR / f"{get_session_id()}.json"


def get_session_overrides() -> dict:
    """Get session-specific hook overrides."""
    path = get_session_config_path()
    if path.exists():
        try:
            return json.loads(path.read_text())
        except json.JSONDecodeError:
            pass
    return {"disabled": [], "enabled": []}


def save_session_overrides(overrides: dict) -> None:
    """Save session-specific overrides."""
    path = get_session_config_path()
    path.write_text(json.dumps(overrides, indent=2))


def discover_hooks() -> list[dict]:
    """Discover all hooks in the hooks directory."""
    hooks = []
    
    # Handlers
    if HANDLERS_DIR.exists():
        for f in sorted(HANDLERS_DIR.glob("*.py")):
            if f.name.startswith("_"):
                continue
            hooks.append({
                "name": f.stem,
                "type": "handler",
                "path": str(f),
                "extension": "py",
            })
    
    # Dispatchers
    if DISPATCHERS_DIR.exists():
        for f in sorted(DISPATCHERS_DIR.glob("*.py")):
            if f.name.startswith("_") or f.name == "base.py":
                continue
            hooks.append({
                "name": f.stem,
                "type": "dispatcher",
                "path": str(f),
                "extension": "py",
            })
    
    # Legacy top-level hooks
    for f in sorted(HOOKS_DIR.glob("*.py")):
        if f.name.startswith("_"):
            continue
        # Skip if already found as handler/dispatcher
        if any(h["name"] == f.stem for h in hooks):
            continue
        hook_type = "library" if f.stem in ("hook_sdk", "hook_utils", "config") else "legacy"
        hooks.append({
            "name": f.stem,
            "type": hook_type,
            "path": str(f),
            "extension": "py",
        })
    
    return hooks


def is_hook_disabled(hook_name: str) -> tuple[bool, str]:
    """Check if hook is disabled. Returns (is_disabled, scope)."""
    # Check session overrides first
    session = get_session_overrides()
    if hook_name in session.get("disabled", []):
        return True, "session"
    if hook_name in session.get("enabled", []):
        return False, "session"
    
    # Check global config
    config = ensure_config()
    if hook_name in config.get("disabled", []):
        return True, "global"
    
    return False, ""


def get_hook_stats(hook_name: str, limit: int = 100) -> dict:
    """Get statistics for a hook from log file."""
    stats = {
        "total_calls": 0,
        "errors": 0,
        "avg_latency_ms": 0,
        "last_run": None,
        "last_error": None,
    }
    
    if not LOG_FILE.exists():
        return stats
    
    latencies = []
    try:
        with open(LOG_FILE, "r") as f:
            # Read last N lines efficiently
            lines = f.readlines()[-limit:]
        
        for line in lines:
            try:
                entry = json.loads(line)
                if entry.get("hook") == hook_name or hook_name in str(entry.get("message", "")):
                    stats["total_calls"] += 1
                    
                    if "elapsed_ms" in entry:
                        latencies.append(entry["elapsed_ms"])
                    
                    if entry.get("level") == "error":
                        stats["errors"] += 1
                        stats["last_error"] = entry.get("message", "")[:100]
                    
                    if ts := entry.get("timestamp"):
                        stats["last_run"] = ts
            except json.JSONDecodeError:
                continue
    except IOError:
        pass
    
    if latencies:
        stats["avg_latency_ms"] = sum(latencies) / len(latencies)
    
    return stats


def cmd_list(args) -> None:
    """List all hooks and their status."""
    hooks = discover_hooks()
    
    print(f"{BLUE}Hooks in {HOOKS_DIR}{NC}")
    print()
    print(f"{'HOOK':<35} {'TYPE':<12} {'STATUS':<15} {'FILE'}")
    print(f"{'─'*35} {'─'*12} {'─'*15} {'─'*30}")
    
    for hook in hooks:
        name = hook["name"]
        hook_type = hook["type"]
        
        if hook_type == "library":
            status = "n/a"
            status_color = YELLOW
        else:
            disabled, scope = is_hook_disabled(name)
            if disabled:
                status = f"disabled ({scope})" if scope else "disabled"
                status_color = RED
            else:
                status = "enabled"
                status_color = GREEN
        
        file_name = f"{name}.{hook['extension']}"
        print(f"{name:<35} {hook_type:<12} {status_color}{status:<15}{NC} {file_name}")
    
    print()
    print(f"{YELLOW}Tip:{NC} Use 'hook_manager.py status <hook>' for details")


def cmd_status(args) -> None:
    """Show detailed status for a hook."""
    hook_name = args.hook
    
    if hook_name:
        hooks = [h for h in discover_hooks() if h["name"] == hook_name]
        if not hooks:
            print(f"{RED}Hook not found: {hook_name}{NC}")
            sys.exit(1)
    else:
        hooks = discover_hooks()
    
    for hook in hooks:
        name = hook["name"]
        disabled, scope = is_hook_disabled(name)
        stats = get_hook_stats(name)
        
        print(f"{CYAN}=== {name} ==={NC}")
        print(f"  Type:        {hook['type']}")
        print(f"  Path:        {hook['path']}")
        
        if hook["type"] != "library":
            status = f"disabled ({scope})" if disabled else "enabled"
            status_color = RED if disabled else GREEN
            print(f"  Status:      {status_color}{status}{NC}")
        
        if stats["total_calls"] > 0:
            print(f"  Calls:       {stats['total_calls']}")
            print(f"  Avg latency: {stats['avg_latency_ms']:.1f}ms")
            if stats["errors"]:
                print(f"  Errors:      {RED}{stats['errors']}{NC}")
            if stats["last_run"]:
                print(f"  Last run:    {stats['last_run']}")
            if stats["last_error"]:
                print(f"  Last error:  {RED}{stats['last_error']}{NC}")
        print()


def cmd_enable(args) -> None:
    """Enable a hook."""
    hook_name = args.hook
    
    # Verify hook exists
    hooks = [h for h in discover_hooks() if h["name"] == hook_name]
    if not hooks:
        print(f"{RED}Hook not found: {hook_name}{NC}")
        sys.exit(1)
    
    if args.session:
        # Session-scoped enable
        overrides = get_session_overrides()
        if hook_name in overrides.get("disabled", []):
            overrides["disabled"].remove(hook_name)
        if hook_name not in overrides.get("enabled", []):
            overrides.setdefault("enabled", []).append(hook_name)
        save_session_overrides(overrides)
        print(f"{GREEN}Enabled {hook_name} for this session{NC}")
    else:
        # Global enable
        config = ensure_config()
        if hook_name in config.get("disabled", []):
            config["disabled"].remove(hook_name)
            save_config(config)
            print(f"{GREEN}Enabled {hook_name} globally{NC}")
        else:
            print(f"{YELLOW}{hook_name} is already enabled{NC}")


def cmd_disable(args) -> None:
    """Disable a hook."""
    hook_name = args.hook
    
    # Verify hook exists
    hooks = [h for h in discover_hooks() if h["name"] == hook_name]
    if not hooks:
        print(f"{RED}Hook not found: {hook_name}{NC}")
        sys.exit(1)
    
    if hooks[0]["type"] == "library":
        print(f"{RED}Cannot disable library: {hook_name}{NC}")
        sys.exit(1)
    
    if args.session:
        # Session-scoped disable
        overrides = get_session_overrides()
        if hook_name in overrides.get("enabled", []):
            overrides["enabled"].remove(hook_name)
        if hook_name not in overrides.get("disabled", []):
            overrides.setdefault("disabled", []).append(hook_name)
        save_session_overrides(overrides)
        print(f"{YELLOW}Disabled {hook_name} for this session{NC}")
    else:
        # Global disable
        config = ensure_config()
        if hook_name not in config.get("disabled", []):
            config.setdefault("disabled", []).append(hook_name)
            save_config(config)
            print(f"{YELLOW}Disabled {hook_name} globally{NC}")
        else:
            print(f"{YELLOW}{hook_name} is already disabled{NC}")


def cmd_logs(args) -> None:
    """Show recent log entries for a hook."""
    hook_name = args.hook
    limit = args.lines
    
    if not LOG_FILE.exists():
        print(f"{YELLOW}No log file found at {LOG_FILE}{NC}")
        return
    
    print(f"{BLUE}Recent log entries{' for ' + hook_name if hook_name else ''}{NC}")
    print()
    
    try:
        with open(LOG_FILE, "r") as f:
            lines = f.readlines()[-500:]  # Read last 500 for filtering
        
        count = 0
        for line in reversed(lines):
            if count >= limit:
                break
            try:
                entry = json.loads(line)
                if hook_name and hook_name not in str(entry):
                    continue
                
                ts = entry.get("timestamp", "")[:19]
                level = entry.get("level", "info")
                hook = entry.get("hook", "unknown")
                msg = entry.get("message", "")[:80]
                
                level_color = RED if level == "error" else YELLOW if level == "warning" else NC
                print(f"{ts} {level_color}[{level:5}]{NC} {hook}: {msg}")
                count += 1
            except json.JSONDecodeError:
                continue
    except IOError as e:
        print(f"{RED}Error reading log file: {e}{NC}")


def cmd_session(args) -> None:
    """Show session-specific overrides."""
    session_id = get_session_id()
    overrides = get_session_overrides()
    
    print(f"{BLUE}Session: {session_id}{NC}")
    print()
    
    if not overrides.get("disabled") and not overrides.get("enabled"):
        print(f"{YELLOW}No session-specific overrides{NC}")
        return
    
    if overrides.get("disabled"):
        print(f"{RED}Disabled for this session:{NC}")
        for hook in overrides["disabled"]:
            print(f"  - {hook}")
    
    if overrides.get("enabled"):
        print(f"{GREEN}Enabled for this session (overriding global disable):{NC}")
        for hook in overrides["enabled"]:
            print(f"  - {hook}")


def main():
    parser = argparse.ArgumentParser(
        description="Hook Manager - Manage Claude Code hooks",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    %(prog)s list
    %(prog)s status tool_analytics
    %(prog)s disable tdd_guard --session
    %(prog)s enable tdd_guard
    %(prog)s logs --lines 50
"""
    )
    
    subparsers = parser.add_subparsers(dest="command", required=True)
    
    # list
    list_parser = subparsers.add_parser("list", help="List all hooks")
    list_parser.set_defaults(func=cmd_list)
    
    # status
    status_parser = subparsers.add_parser("status", help="Show hook status")
    status_parser.add_argument("hook", nargs="?", help="Hook name (all if omitted)")
    status_parser.set_defaults(func=cmd_status)
    
    # enable
    enable_parser = subparsers.add_parser("enable", help="Enable a hook")
    enable_parser.add_argument("hook", help="Hook name")
    enable_parser.add_argument("--session", action="store_true", help="Session-scoped only")
    enable_parser.set_defaults(func=cmd_enable)
    
    # disable
    disable_parser = subparsers.add_parser("disable", help="Disable a hook")
    disable_parser.add_argument("hook", help="Hook name")
    disable_parser.add_argument("--session", action="store_true", help="Session-scoped only")
    disable_parser.set_defaults(func=cmd_disable)
    
    # logs
    logs_parser = subparsers.add_parser("logs", help="Show recent log entries")
    logs_parser.add_argument("hook", nargs="?", help="Filter by hook name")
    logs_parser.add_argument("--lines", "-n", type=int, default=20, help="Number of lines")
    logs_parser.set_defaults(func=cmd_logs)
    
    # session
    session_parser = subparsers.add_parser("session", help="Show session overrides")
    session_parser.set_defaults(func=cmd_session)
    
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
