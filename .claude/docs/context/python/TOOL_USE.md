# Tool Usage Strategy

<tool_selection_hierarchy>
1. **MCP Tools First**: Check if there are MCP (Model Context Protocol) tools available that can serve the purpose
2. **CLI Fallback**: If no MCP tool exists, use equivalent CLI option
   - Fetch latest man/help page or run with --help to understand usage
   - Examples: Use `psql` instead of postgres tool, `git` instead of git tool, `gh` instead of github tool 
3. **API Direct**: For web services without CLI, use curl to call APIs directly
   - Examples: Use Jira API, GitHub API, etc.
</tool_selection_hierarchy>

## 🔍 Search Command Requirements

**CRITICAL**: Always use `rg` (ripgrep) instead of traditional `grep` and `find` commands:

```bash
# ❌ Don't use grep
grep -r "pattern" .

# ✅ Use rg instead
rg "pattern"

# ❌ Don't use find with name
find . -name "*.py"

# ✅ Use rg with file filtering
rg --files | rg "\.py$"
# or
rg --files -g "*.py"
```

**Enforcement Rules:**

```
(
    r"^grep\b(?!.*\|)",
    "Use 'rg' (ripgrep) instead of 'grep' for better performance and features",
),
(
    r"^find\s+\S+\s+-name\b",
    "Use 'rg --files | rg pattern' or 'rg --files -g pattern' instead of 'find -name' for better performance",
),
```

## 🔍 Debugging Tools

### Debugging Commands

```bash
# Interactive debugging with ipdb
uv add --dev ipdb
# Add breakpoint: import ipdb; ipdb.set_trace()

# Memory profiling
uv add --dev memory-profiler
uv run python -m memory_profiler script.py

# Line profiling
uv add --dev line-profiler
# Add @profile decorator to functions

# Debug with rich traceback
uv add --dev rich
# In code: from rich.traceback import install; install()
```



