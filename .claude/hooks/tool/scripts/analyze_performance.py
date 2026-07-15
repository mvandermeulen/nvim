#!/home/vandem/.claude/data/venv/bin/python3
"""
Performance analyzer for hook dispatchers.

Analyzes handler timing data from logs and session state to identify:
- Slowest handlers
- Handlers with high variance
- Handler execution trends
- Tool-specific performance

Usage:
    python scripts/analyze_performance.py [--days N] [--handler NAME] [--top N]
    
Examples:
    python scripts/analyze_performance.py --top 10
    python scripts/analyze_performance.py --handler tool_analytics --days 7
"""
import argparse
import json
import re
import sys
from collections import defaultdict
from datetime import datetime, timedelta
from pathlib import Path
from statistics import mean, stdev, median

# Paths
LOGS_DIR = Path.home() / ".claude" / "logs"
DATA_DIR = Path.home() / ".claude" / "data"


def parse_log_line(line: str) -> dict | None:
    """Parse a log line for handler timing data."""
    # Log format: timestamp | level | message | json_data
    # Example: 2025-01-08 12:00:00.123 | INFO | handler_timing | {"handler": "foo", "elapsed_ms": 10.5}
    
    if "handler_timing" not in line:
        return None
    
    try:
        # Extract JSON data from line
        json_match = re.search(r'\{[^{}]+\}', line)
        if not json_match:
            return None
        
        data = json.loads(json_match.group())
        
        # Extract timestamp
        ts_match = re.match(r'(\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2})', line)
        if ts_match:
            data['timestamp'] = ts_match.group(1)
        
        return data
    except (json.JSONDecodeError, AttributeError):
        return None


def load_timing_data(days: int = 7) -> list[dict]:
    """Load timing data from log files."""
    timings = []
    cutoff = datetime.now() - timedelta(days=days)
    
    if not LOGS_DIR.exists():
        return timings
    
    for log_file in sorted(LOGS_DIR.glob("hooks*.log*")):
        try:
            # Skip old rotated logs based on filename date if possible
            with open(log_file, 'r', errors='replace') as f:
                for line in f:
                    data = parse_log_line(line)
                    if data:
                        timings.append(data)
        except (IOError, PermissionError):
            continue
    
    return timings


def analyze_handler_performance(timings: list[dict], top_n: int = 10) -> dict:
    """Analyze handler performance from timing data."""
    by_handler = defaultdict(list)
    by_tool = defaultdict(lambda: defaultdict(list))
    
    for t in timings:
        handler = t.get('handler', 'unknown')
        elapsed = t.get('elapsed_ms', 0)
        tool = t.get('tool', 'unknown')
        
        by_handler[handler].append(elapsed)
        by_tool[tool][handler].append(elapsed)
    
    # Calculate stats for each handler
    handler_stats = {}
    for handler, times in by_handler.items():
        if len(times) < 2:
            handler_stats[handler] = {
                'count': len(times),
                'mean': times[0] if times else 0,
                'median': times[0] if times else 0,
                'std': 0,
                'min': times[0] if times else 0,
                'max': times[0] if times else 0,
                'p95': times[0] if times else 0,
            }
        else:
            sorted_times = sorted(times)
            p95_idx = int(len(sorted_times) * 0.95)
            handler_stats[handler] = {
                'count': len(times),
                'mean': mean(times),
                'median': median(times),
                'std': stdev(times),
                'min': min(times),
                'max': max(times),
                'p95': sorted_times[p95_idx] if p95_idx < len(sorted_times) else sorted_times[-1],
            }
    
    # Sort by mean time (slowest first)
    slowest = sorted(handler_stats.items(), key=lambda x: x[1]['mean'], reverse=True)[:top_n]
    
    # Sort by variance (most inconsistent first)  
    most_variable = sorted(
        [(h, s) for h, s in handler_stats.items() if s['count'] > 5],
        key=lambda x: x[1]['std'],
        reverse=True
    )[:top_n]
    
    # Most frequently called
    most_called = sorted(handler_stats.items(), key=lambda x: x[1]['count'], reverse=True)[:top_n]
    
    return {
        'all_handlers': handler_stats,
        'slowest': slowest,
        'most_variable': most_variable,
        'most_called': most_called,
        'by_tool': dict(by_tool),
        'total_samples': len(timings),
    }


def print_report(analysis: dict, handler_filter: str = None) -> None:
    """Print performance analysis report."""
    print("\n" + "=" * 60)
    print("HOOK PERFORMANCE ANALYSIS")
    print("=" * 60)
    print(f"Total samples: {analysis['total_samples']}")
    
    if handler_filter:
        # Single handler detail view
        if handler_filter not in analysis['all_handlers']:
            print(f"\nHandler '{handler_filter}' not found in timing data.")
            return
        
        stats = analysis['all_handlers'][handler_filter]
        print(f"\nHandler: {handler_filter}")
        print("-" * 40)
        print(f"  Calls:    {stats['count']:,}")
        print(f"  Mean:     {stats['mean']:.2f} ms")
        print(f"  Median:   {stats['median']:.2f} ms")
        print(f"  Std Dev:  {stats['std']:.2f} ms")
        print(f"  Min:      {stats['min']:.2f} ms")
        print(f"  Max:      {stats['max']:.2f} ms")
        print(f"  P95:      {stats['p95']:.2f} ms")
        
        # Show per-tool breakdown
        print(f"\n  By Tool:")
        for tool, tool_handlers in analysis['by_tool'].items():
            if handler_filter in tool_handlers:
                times = tool_handlers[handler_filter]
                print(f"    {tool}: {len(times)} calls, {mean(times):.2f} ms avg")
        return
    
    # Summary view
    print("\n--- SLOWEST HANDLERS (by mean time) ---")
    for handler, stats in analysis['slowest']:
        print(f"  {handler:35} {stats['mean']:7.2f} ms (n={stats['count']:,})")
    
    print("\n--- MOST VARIABLE HANDLERS (by std dev) ---")
    for handler, stats in analysis['most_variable']:
        print(f"  {handler:35} std={stats['std']:7.2f} ms (mean={stats['mean']:.2f})")
    
    print("\n--- MOST FREQUENTLY CALLED ---")
    for handler, stats in analysis['most_called']:
        print(f"  {handler:35} {stats['count']:7,} calls ({stats['mean']:.2f} ms avg)")
    
    # Overall timing summary
    all_times = []
    for handler, stats in analysis['all_handlers'].items():
        all_times.extend([stats['mean']] * stats['count'])
    
    if all_times:
        print(f"\n--- OVERALL ---")
        print(f"  Total handler calls:    {len(all_times):,}")
        print(f"  Overall mean:           {mean(all_times):.2f} ms")
        print(f"  Total time (estimated): {sum(all_times)/1000:.1f} s")


def main():
    parser = argparse.ArgumentParser(description='Analyze hook handler performance')
    parser.add_argument('--days', type=int, default=7, help='Days of logs to analyze (default: 7)')
    parser.add_argument('--handler', type=str, help='Filter to specific handler')
    parser.add_argument('--top', type=int, default=10, help='Show top N results (default: 10)')
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    
    args = parser.parse_args()
    
    print(f"Loading timing data from last {args.days} days...", file=sys.stderr)
    timings = load_timing_data(args.days)
    
    if not timings:
        print("No timing data found. Run hooks with HOOK_PROFILE=1 to collect data.")
        sys.exit(0)
    
    analysis = analyze_handler_performance(timings, args.top)
    
    if args.json:
        # JSON output for programmatic use
        output = {
            'total_samples': analysis['total_samples'],
            'handlers': analysis['all_handlers'],
        }
        print(json.dumps(output, indent=2))
    else:
        print_report(analysis, args.handler)


if __name__ == "__main__":
    main()
