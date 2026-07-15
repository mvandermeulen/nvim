#!/home/vandem/.claude/data/venv/bin/python3
"""
Validate handler routing configuration.

Compares explicit TOOL_HANDLERS definitions with auto-discovered APPLIES_TO metadata
from handler modules. Helps ensure routing stays in sync.

Usage:
    python -m hooks.scripts.validate_routing [--verbose]
    # or directly:
    ./hooks/scripts/validate_routing.py [--verbose]

Exit codes:
    0: All routing in sync
    1: Discrepancies found
"""
import sys


def main():
    verbose = "--verbose" in sys.argv or "-v" in sys.argv

    from hooks.dispatchers.pre_tool import PreToolDispatcher
    from hooks.dispatchers.post_tool import PostToolDispatcher

    all_in_sync = True

    for dispatcher_cls in [PreToolDispatcher, PostToolDispatcher]:
        dispatcher = dispatcher_cls()
        result = dispatcher.validate_routing(verbose=verbose)

        if not result["in_sync"]:
            all_in_sync = False
            if not verbose:
                # Brief output if not verbose
                print(f"[{dispatcher.DISPATCHER_NAME}] Routing mismatch detected")
                if result["missing_explicit"]:
                    print(f"  Missing from TOOL_HANDLERS: {result['missing_explicit']}")
                if result["extra_explicit"]:
                    print(f"  Extra in TOOL_HANDLERS: {result['extra_explicit']}")
        elif verbose:
            print(f"[{dispatcher.DISPATCHER_NAME}] ✓ Routing in sync")

    if all_in_sync:
        if verbose:
            print("\n✓ All dispatcher routing is in sync with handler metadata")
        sys.exit(0)
    else:
        print("\n✗ Routing validation failed - update TOOL_HANDLERS or handler APPLIES_TO")
        sys.exit(1)


if __name__ == "__main__":
    main()
