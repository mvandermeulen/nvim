#!/home/vandem/.claude/data/venv/bin/python3
"""
Hook execution tracer for debugging.

Sets up trace-level logging for hook execution to help diagnose issues.
When enabled via HOOK_TRACE=1, logs detailed information about:
- Which handlers are selected for each tool
- Handler arguments and results
- Timing breakdowns
- State mutations

Usage:
    HOOK_TRACE=1 claude  # Enable tracing during Claude session
    
    # Or run directly on a saved input
    python scripts/trace_hook.py --event PreToolUse --input '{"tool_name": "Bash", ...}'
"""
import argparse
import json
import os
import sys
import time
from pathlib import Path

# Add hooks to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from hooks.dispatchers.base import BaseDispatcher


def trace_dispatch(dispatcher_class, raw_input: dict) -> dict:
    """Trace a dispatcher execution with detailed output."""
    print(f"\n{'=' * 60}", file=sys.stderr)
    print(f"TRACING: {dispatcher_class.DISPATCHER_NAME}", file=sys.stderr)
    print(f"{'=' * 60}", file=sys.stderr)
    
    print(f"\n--- INPUT ---", file=sys.stderr)
    print(json.dumps(raw_input, indent=2, default=str)[:2000], file=sys.stderr)
    
    # Create dispatcher instance
    dispatcher = dispatcher_class()
    
    # Get routing info
    tool_name = raw_input.get("tool_name", "")
    tool_handlers = dispatcher.get_tool_handlers()
    handlers = tool_handlers.get(tool_name, []) if tool_handlers else dispatcher.ALL_HANDLERS
    
    print(f"\n--- ROUTING ---", file=sys.stderr)
    print(f"Tool: {tool_name}", file=sys.stderr)
    print(f"Handlers: {handlers}", file=sys.stderr)
    
    if not handlers:
        print("No handlers selected for this tool.", file=sys.stderr)
        return None
    
    # Run each handler with detailed tracing
    print(f"\n--- EXECUTION ---", file=sys.stderr)
    results = []
    total_start = time.perf_counter()
    
    for i, handler_name in enumerate(handlers, 1):
        print(f"\n[{i}/{len(handlers)}] Running: {handler_name}", file=sys.stderr)
        
        handler_start = time.perf_counter()
        try:
            result = dispatcher.run_handler(handler_name, raw_input)
            elapsed = (time.perf_counter() - handler_start) * 1000
            
            print(f"  Time: {elapsed:.2f} ms", file=sys.stderr)
            
            if result:
                print(f"  Result type: {type(result).__name__}", file=sys.stderr)
                if isinstance(result, dict):
                    hook_output = result.get("hookSpecificOutput", {})
                    if hook_output:
                        print(f"  Output: {json.dumps(hook_output, default=str)[:500]}", file=sys.stderr)
                    
                    # Check for blocking/decision
                    if result.get("decision"):
                        print(f"  Decision: {result['decision']}", file=sys.stderr)
                        
                results.append({
                    'handler': handler_name,
                    'elapsed_ms': elapsed,
                    'result': result,
                })
            else:
                print(f"  Result: None (no action)", file=sys.stderr)
                results.append({
                    'handler': handler_name,
                    'elapsed_ms': elapsed,
                    'result': None,
                })
                
        except Exception as e:
            elapsed = (time.perf_counter() - handler_start) * 1000
            print(f"  ERROR: {type(e).__name__}: {e}", file=sys.stderr)
            results.append({
                'handler': handler_name,
                'elapsed_ms': elapsed,
                'error': str(e),
            })
    
    total_elapsed = (time.perf_counter() - total_start) * 1000
    
    print(f"\n--- SUMMARY ---", file=sys.stderr)
    print(f"Total time: {total_elapsed:.2f} ms", file=sys.stderr)
    print(f"Handlers run: {len(results)}", file=sys.stderr)
    
    # Show any handlers that produced results
    producing_results = [r for r in results if r.get('result')]
    if producing_results:
        print(f"Handlers with output: {[r['handler'] for r in producing_results]}", file=sys.stderr)
    
    errors = [r for r in results if r.get('error')]
    if errors:
        print(f"Handlers with errors: {[r['handler'] for r in errors]}", file=sys.stderr)
    
    return results


def get_dispatcher_for_event(event_name: str):
    """Get the appropriate dispatcher class for an event type."""
    event_lower = event_name.lower()
    
    if event_lower == "pretooluse":
        from hooks.dispatchers.pre_tool import PreToolDispatcher
        return PreToolDispatcher
    elif event_lower == "posttooluse":
        from hooks.dispatchers.post_tool import PostToolDispatcher
        return PostToolDispatcher
    elif event_lower == "userprompt":
        from hooks.dispatchers.user_prompt import UserPromptDispatcher
        return UserPromptDispatcher
    elif event_lower == "precompact":
        from hooks.dispatchers.pre_compact import PreCompactDispatcher
        return PreCompactDispatcher
    else:
        raise ValueError(f"Unknown event type: {event_name}")


def main():
    parser = argparse.ArgumentParser(description='Trace hook execution')
    parser.add_argument('--event', type=str, required=True,
                        choices=['PreToolUse', 'PostToolUse', 'UserPrompt', 'PreCompact'],
                        help='Event type to trace')
    parser.add_argument('--input', type=str, help='JSON input to process')
    parser.add_argument('--file', type=str, help='File containing JSON input')
    parser.add_argument('--tool', type=str, help='Tool name (creates minimal test input)')
    
    args = parser.parse_args()
    
    # Get input
    if args.input:
        raw_input = json.loads(args.input)
    elif args.file:
        with open(args.file) as f:
            raw_input = json.load(f)
    elif args.tool:
        # Create minimal test input
        raw_input = {
            "tool_name": args.tool,
            "tool_input": {},
            "sessionId": "trace-test-session",
        }
        if args.event.lower() == "posttooluse":
            raw_input["tool_result"] = {"output": "test output"}
    else:
        # Read from stdin
        raw_input = json.load(sys.stdin)
    
    dispatcher_class = get_dispatcher_for_event(args.event)
    results = trace_dispatch(dispatcher_class, raw_input)
    
    # Output results as JSON
    if results:
        print("\n--- JSON OUTPUT ---")
        print(json.dumps(results, indent=2, default=str))


if __name__ == "__main__":
    main()
