#!/usr/bin/env bash
# StatusLine display script for Claude Code
# Displays: Activity • Progress Bar • Context% • Task • Weekly% • Model

# Catppuccin Mocha color codes (RGB)
COLOR_GREEN="166;227;161"      # a6e3a1 - 0-60% usage, active
COLOR_YELLOW="249;226;175"     # f9e2af - 60-80% usage
COLOR_PEACH="250;179;135"      # fab387 - 80-90% usage
COLOR_RED="243;139;168"        # f38ba8 - 90-100% usage
COLOR_LAVENDER="180;190;254"   # b4befe - task name
COLOR_MAUVE="203;166;247"      # cba6f7 - weekly usage
COLOR_BLUE="137;180;250"       # 89b4fa - model name
COLOR_GRAY="108;112;134"       # 6c7086 - inactive/overlay

# Read JSON input from stdin
input=$(cat)

# Parse JSON input
model_name=$(echo "$input" | jq -r '.model.display_name // "Unknown"' | sed 's/@.*//')
tokens=$(echo "$input" | jq -r '.usage.tokens // 0')
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // ""')

# Calculate context percentage (200k token limit for all models)
max_tokens=200000
if command -v bc &> /dev/null; then
    context_pct=$(echo "scale=0; $tokens * 100 / $max_tokens" | bc)
else
    # Fallback if bc not available
    context_pct=$((tokens * 100 / max_tokens))
fi

# Generate progress bar with color
generate_progress_bar() {
    local pct=$1
    local filled=$((pct / 10))  # 10% per block character
    local empty=$((10 - filled))

    # Choose color based on percentage
    local bar_color
    if [ "$pct" -lt 60 ]; then
        bar_color=$COLOR_GREEN
    elif [ "$pct" -lt 80 ]; then
        bar_color=$COLOR_YELLOW
    elif [ "$pct" -lt 90 ]; then
        bar_color=$COLOR_PEACH
    else
        bar_color=$COLOR_RED
    fi

    # Build progress bar
    local bar="["
    for ((i=0; i<filled; i++)); do
        bar+="█"
    done
    for ((i=0; i<empty; i++)); do
        bar+="░"
    done
    bar+="]"

    # Return colored bar
    printf '%s' "\033[38;2;${bar_color}m${bar}\033[0m"
}

progress_bar=$(generate_progress_bar "$context_pct")

# Get activity status
if [ -f "$HOME/.claude/activity.log" ]; then
    # Check if there are recent entries (last 5 minutes)
    recent_count=$(find "$HOME/.claude/activity.log" -mmin -5 2>/dev/null | wc -l)
    if [ "$recent_count" -gt 0 ]; then
        activity="\033[38;2;${COLOR_GREEN}m●\033[0m"  # green dot
    else
        activity="\033[38;2;${COLOR_GRAY}m○\033[0m"   # gray dot
    fi
else
    activity="\033[38;2;${COLOR_GRAY}m○\033[0m"       # gray dot
fi

# Get current task from TodoWrite
task=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    # Try to extract task from TodoWrite calls in transcript
    # Look for todos with status "in_progress" or "pending"
    task=$(grep -A 5 '"tool": "TodoWrite"' "$transcript_path" 2>/dev/null | \
           grep -E '"status":\s*"(in_progress|pending)"' -B 2 | \
           grep '"content":' | head -1 | \
           sed 's/.*"content":\s*"\([^"]*\)".*/\1/' | \
           cut -c1-15)
fi

# Fallback to project directory name if no task found
if [ -z "$task" ] && [ -n "$project_dir" ]; then
    task=$(basename "$project_dir" | cut -c1-15)
fi

# Final fallback
if [ -z "$task" ]; then
    task="idle"
fi

# Get weekly usage
weekly_pct=0
if [ -f "$HOME/.claude/usage-tracking.json" ]; then
    weekly_pct=$(jq -r '.current_week_pct // 0' "$HOME/.claude/usage-tracking.json" 2>/dev/null || echo "0")
fi

# Format and output statusLine
# [●] [████████░░] 78% • feature-impl • W:45% • Sonnet
echo -e "${activity} ${progress_bar} ${context_pct}% • \033[38;2;${COLOR_LAVENDER}m${task}\033[0m • \033[38;2;${COLOR_MAUVE}mW:${weekly_pct}%\033[0m • \033[38;2;${COLOR_BLUE}m${model_name}\033[0m"
