#!/home/vandem/.claude/data/venv/bin/python3
"""
PreCompact Dispatcher - Handle context compaction events.

Delegates to handlers/context_manager.py for:
- Extracting key context (CLAUDE.md, active todos, session summary)
- Preserving important state across context window compaction

Runs on PreCompact event before Claude compresses context.
"""
import json
import sys

from hooks.hook_utils import graceful_main, log_event
from hooks.config import fast_json_loads
from hooks.handlers.context_manager import handle_pre_compact


@graceful_main("pre_compact_dispatcher")
def main():
    try:
        raw = fast_json_loads(sys.stdin.read())
    except Exception as e:
        log_event("pre_compact_dispatcher", "parse_error", {"error": str(e)})
        sys.exit(1)

    result = handle_pre_compact(raw)

    if result:
        print(json.dumps(result))

    sys.exit(0)


if __name__ == "__main__":
    main()
