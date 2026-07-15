#!/home/vandem/.claude/data/venv/bin/python3
"""
Dynamic threshold tuner for hook configuration.

Analyzes historical usage data to suggest optimal threshold values:
- Token warning thresholds based on actual usage patterns
- Output size thresholds based on tool output distributions
- Batch detection thresholds based on edit patterns
- Cost alert thresholds based on spending patterns

Usage:
    python scripts/tune_thresholds.py [--days N] [--apply]
    
Examples:
    python scripts/tune_thresholds.py --days 30
    python scripts/tune_thresholds.py --apply  # Apply suggested changes
"""
import argparse
import json
import os
import sys
from collections import defaultdict
from datetime import datetime, timedelta
from pathlib import Path
from statistics import mean, stdev, median, quantiles

# Paths
DATA_DIR = Path.home() / ".claude" / "data"
TRACKER_DIR = DATA_DIR / "tracker"
CONFIG_FILE = Path(__file__).parent.parent / "config.py"


def load_daily_token_stats(days: int = 30) -> list[dict]:
    """Load daily token statistics from tracker files."""
    stats = []
    cutoff = datetime.now() - timedelta(days=days)
    
    if not TRACKER_DIR.exists():
        return stats
    
    for stats_file in sorted(TRACKER_DIR.glob("tokens-*.json")):
        try:
            # Parse date from filename
            date_str = stats_file.stem.replace("tokens-", "")
            file_date = datetime.strptime(date_str, "%Y-%m-%d")
            
            if file_date < cutoff:
                continue
            
            with open(stats_file) as f:
                data = json.load(f)
                data['date'] = date_str
                stats.append(data)
        except (json.JSONDecodeError, ValueError, IOError):
            continue
    
    return stats


def analyze_token_usage(stats: list[dict]) -> dict:
    """Analyze token usage patterns."""
    daily_totals = [s.get('total_tokens', 0) for s in stats if s.get('total_tokens', 0) > 0]
    
    if not daily_totals:
        return {
            'samples': 0,
            'current_warning': None,
            'suggested_warning': None,
        }
    
    # Calculate percentiles
    sorted_totals = sorted(daily_totals)
    p50 = sorted_totals[len(sorted_totals) // 2]
    p75_idx = int(len(sorted_totals) * 0.75)
    p90_idx = int(len(sorted_totals) * 0.90)
    p95_idx = int(len(sorted_totals) * 0.95)
    
    p75 = sorted_totals[p75_idx] if p75_idx < len(sorted_totals) else sorted_totals[-1]
    p90 = sorted_totals[p90_idx] if p90_idx < len(sorted_totals) else sorted_totals[-1]
    p95 = sorted_totals[p95_idx] if p95_idx < len(sorted_totals) else sorted_totals[-1]
    
    # Suggest warning at P75 (warns 25% of days)
    # Suggest critical at P95 (warns 5% of days)
    suggested_warning = round(p75 / 1000) * 1000  # Round to nearest 1000
    suggested_critical = round(p95 / 1000) * 1000
    
    return {
        'samples': len(daily_totals),
        'mean': mean(daily_totals),
        'median': p50,
        'p75': p75,
        'p90': p90,
        'p95': p95,
        'max': max(daily_totals),
        'suggested_warning': max(suggested_warning, 100000),  # Minimum 100K
        'suggested_critical': max(suggested_critical, 200000),  # Minimum 200K
    }


def analyze_cost_patterns(stats: list[dict]) -> dict:
    """Analyze cost patterns from daily stats."""
    daily_costs = [s.get('cost_usd', 0) for s in stats if s.get('cost_usd', 0) > 0]
    
    if not daily_costs:
        return {
            'samples': 0,
            'suggested_daily_warning': None,
            'suggested_daily_critical': None,
        }
    
    sorted_costs = sorted(daily_costs)
    p75_idx = int(len(sorted_costs) * 0.75)
    p95_idx = int(len(sorted_costs) * 0.95)
    
    p75 = sorted_costs[p75_idx] if p75_idx < len(sorted_costs) else sorted_costs[-1]
    p95 = sorted_costs[p95_idx] if p95_idx < len(sorted_costs) else sorted_costs[-1]
    
    # Round to sensible values
    def round_cost(c):
        if c < 1:
            return round(c, 2)
        elif c < 10:
            return round(c)
        else:
            return round(c / 5) * 5
    
    return {
        'samples': len(daily_costs),
        'mean': mean(daily_costs),
        'median': median(daily_costs),
        'p75': p75,
        'p95': p95,
        'max': max(daily_costs),
        'suggested_daily_warning': max(round_cost(p75 * 1.5), 5.0),
        'suggested_daily_critical': max(round_cost(p95 * 1.5), 20.0),
    }


def analyze_tool_usage(stats: list[dict]) -> dict:
    """Analyze per-tool usage patterns."""
    tool_totals = defaultdict(list)
    
    for s in stats:
        by_tool = s.get('by_tool', {})
        for tool, count in by_tool.items():
            tool_totals[tool].append(count)
    
    tool_stats = {}
    for tool, counts in tool_totals.items():
        if len(counts) >= 3:
            tool_stats[tool] = {
                'days_used': len(counts),
                'mean': mean(counts),
                'max': max(counts),
            }
    
    return tool_stats


def load_current_thresholds() -> dict:
    """Load current threshold values from config."""
    from hooks.config import Thresholds, CostTracking
    
    return {
        'token_warning': Thresholds.TOKEN_WARNING,
        'token_critical': Thresholds.TOKEN_CRITICAL,
        'daily_token_warning': Thresholds.DAILY_TOKEN_WARNING,
        'output_warning': Thresholds.OUTPUT_WARNING,
        'output_critical': Thresholds.OUTPUT_CRITICAL,
        'daily_cost_warning': CostTracking.DAILY_COST_WARNING,
        'daily_cost_critical': CostTracking.DAILY_COST_CRITICAL,
        'session_cost_warning': CostTracking.SESSION_COST_WARNING,
        'session_cost_critical': CostTracking.SESSION_COST_CRITICAL,
    }


def generate_recommendations(token_analysis: dict, cost_analysis: dict, current: dict) -> list[dict]:
    """Generate threshold recommendations based on analysis."""
    recommendations = []
    
    # Daily token threshold
    if token_analysis.get('suggested_warning'):
        suggested = token_analysis['suggested_warning']
        current_val = current['daily_token_warning']
        
        if abs(suggested - current_val) / current_val > 0.2:  # >20% difference
            recommendations.append({
                'setting': 'daily_token_warning',
                'current': current_val,
                'suggested': suggested,
                'reason': f"Based on P75={token_analysis['p75']:,} of {token_analysis['samples']} days",
                'config_class': 'ThresholdConfig',
            })
    
    # Daily cost threshold
    if cost_analysis.get('suggested_daily_warning'):
        suggested = cost_analysis['suggested_daily_warning']
        current_val = current['daily_cost_warning']
        
        if abs(suggested - current_val) / current_val > 0.2:
            recommendations.append({
                'setting': 'daily_cost_warning',
                'current': current_val,
                'suggested': suggested,
                'reason': f"Based on P75=${cost_analysis['p75']:.2f} of {cost_analysis['samples']} days",
                'config_class': 'CostConfig',
            })
    
    if cost_analysis.get('suggested_daily_critical'):
        suggested = cost_analysis['suggested_daily_critical']
        current_val = current['daily_cost_critical']
        
        if abs(suggested - current_val) / current_val > 0.2:
            recommendations.append({
                'setting': 'daily_cost_critical',
                'current': current_val,
                'suggested': suggested,
                'reason': f"Based on P95=${cost_analysis['p95']:.2f} of {cost_analysis['samples']} days",
                'config_class': 'CostConfig',
            })
    
    return recommendations


def print_analysis(token_analysis: dict, cost_analysis: dict, tool_usage: dict, current: dict, recommendations: list) -> None:
    """Print analysis report."""
    print("\n" + "=" * 60)
    print("THRESHOLD TUNING ANALYSIS")
    print("=" * 60)
    
    # Token usage
    print("\n--- DAILY TOKEN USAGE ---")
    if token_analysis['samples'] > 0:
        print(f"  Days analyzed:     {token_analysis['samples']}")
        print(f"  Mean daily tokens: {token_analysis['mean']:,.0f}")
        print(f"  Median:            {token_analysis['median']:,.0f}")
        print(f"  P75:               {token_analysis['p75']:,.0f}")
        print(f"  P95:               {token_analysis['p95']:,.0f}")
        print(f"  Max:               {token_analysis['max']:,.0f}")
        print(f"\n  Current warning:   {current['daily_token_warning']:,}")
        if token_analysis.get('suggested_warning'):
            print(f"  Suggested warning: {token_analysis['suggested_warning']:,}")
    else:
        print("  No token usage data available.")
    
    # Cost patterns
    print("\n--- DAILY COST PATTERNS ---")
    if cost_analysis['samples'] > 0:
        print(f"  Days analyzed:     {cost_analysis['samples']}")
        print(f"  Mean daily cost:   ${cost_analysis['mean']:.2f}")
        print(f"  Median:            ${cost_analysis['median']:.2f}")
        print(f"  P75:               ${cost_analysis['p75']:.2f}")
        print(f"  P95:               ${cost_analysis['p95']:.2f}")
        print(f"  Max:               ${cost_analysis['max']:.2f}")
        print(f"\n  Current warning:   ${current['daily_cost_warning']:.2f}")
        print(f"  Current critical:  ${current['daily_cost_critical']:.2f}")
        if cost_analysis.get('suggested_daily_warning'):
            print(f"  Suggested warning: ${cost_analysis['suggested_daily_warning']:.2f}")
            print(f"  Suggested critical: ${cost_analysis['suggested_daily_critical']:.2f}")
    else:
        print("  No cost data available (enable cost tracking first).")
    
    # Tool breakdown
    if tool_usage:
        print("\n--- TOP TOOLS BY USAGE ---")
        sorted_tools = sorted(tool_usage.items(), key=lambda x: x[1]['mean'], reverse=True)[:5]
        for tool, stats in sorted_tools:
            print(f"  {tool:20} {stats['mean']:,.0f} tokens/day avg (max: {stats['max']:,})")
    
    # Recommendations
    print("\n--- RECOMMENDATIONS ---")
    if recommendations:
        for rec in recommendations:
            print(f"\n  {rec['setting']}:")
            print(f"    Current:   {rec['current']}")
            print(f"    Suggested: {rec['suggested']}")
            print(f"    Reason:    {rec['reason']}")
    else:
        print("  No threshold changes recommended. Current settings look good!")


def apply_recommendations(recommendations: list) -> None:
    """Apply recommended threshold changes (updates environment or prints commands)."""
    if not recommendations:
        print("\nNo changes to apply.")
        return
    
    print("\n--- APPLYING CHANGES ---")
    print("To apply these changes, add to your environment or ~/.claude/settings.json:\n")
    
    for rec in recommendations:
        # For now, just print what would be changed
        setting = rec['setting'].upper()
        value = rec['suggested']
        print(f"  export HOOK_{setting}={value}")
    
    print("\nNote: Direct config.py modification not implemented for safety.")
    print("Consider updating ThresholdConfig/CostConfig defaults in config.py manually.")


def main():
    parser = argparse.ArgumentParser(description='Tune hook thresholds based on usage patterns')
    parser.add_argument('--days', type=int, default=30, help='Days of data to analyze (default: 30)')
    parser.add_argument('--apply', action='store_true', help='Show how to apply suggested changes')
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    
    args = parser.parse_args()
    
    print(f"Loading data from last {args.days} days...", file=sys.stderr)
    
    # Load data
    daily_stats = load_daily_token_stats(args.days)
    
    if not daily_stats:
        print("No usage data found. Run Claude with hooks enabled to collect data.")
        sys.exit(0)
    
    # Analyze
    token_analysis = analyze_token_usage(daily_stats)
    cost_analysis = analyze_cost_patterns(daily_stats)
    tool_usage = analyze_tool_usage(daily_stats)
    current = load_current_thresholds()
    
    # Generate recommendations
    recommendations = generate_recommendations(token_analysis, cost_analysis, current)
    
    if args.json:
        output = {
            'token_analysis': token_analysis,
            'cost_analysis': cost_analysis,
            'tool_usage': tool_usage,
            'current_thresholds': current,
            'recommendations': recommendations,
        }
        print(json.dumps(output, indent=2, default=str))
    else:
        print_analysis(token_analysis, cost_analysis, tool_usage, current, recommendations)
        
        if args.apply and recommendations:
            apply_recommendations(recommendations)


if __name__ == "__main__":
    main()
