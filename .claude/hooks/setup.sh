#!/usr/bin/env zsh

SCRIPT_DIRECTORY=${0:a:h}
OTHER_SCRIPT_DIRECTORY="$(dirname $0:A)"
echo "==> Running setup script from ${SCRIPT_DIRECTORY}";
REPO_ROOT=$(git -C "${SCRIPT_DIRECTORY}" rev-parse --show-toplevel 2>/dev/null);
[[ -z "${REPO_ROOT}" ]] && echo "ERROR: Not in a git repository" && exit 1;
echo "Repository root found at ${REPO_ROOT}";
LOCAL_VENV_DIRECTORY="${REPO_ROOT}/.venv";
LOCAL_CLAUDE_DIRECTORY="${REPO_ROOT}/.claude";
LOCAL_SHARE_DIRECTORY="${REPO_ROOT}/.rhino/share";
[[ ! -d "${LOCAL_CLAUDE_DIRECTORY}" ]] && echo "ERROR: Could not find claude directory" && exit 1;
LOCAL_HOOKS_DIRECTORY="${LOCAL_CLAUDE_DIRECTORY}/hooks";
[[ ! -d "${LOCAL_HOOKS_DIRECTORY}" ]] && echo "ERROR: Could not find hooks directory" && exit 1;
RUNNER="${LOCAL_HOOKS_DIRECTORY}/migrations/runner.py"
[[ ! -f "${RUNNER}" ]] && echo "ERROR: Could not find migration runner." && exit 1;
DB_PATH="${LOCAL_SHARE_DIRECTORY}/hooks.db"


[[ ! -d "${LOCAL_SHARE_DIRECTORY}" ]] && {
  echo "==> Creating share directory..."
  cd "${REPO_ROOT}" && mkdir -p "${LOCAL_SHARE_DIRECTORY}" && \
    echo "    Share directory created at ${LOCAL_SHARE_DIRECTORY}";
}


[[ ! -d "${LOCAL_VENV_DIRECTORY}" ]] && {
  echo "==> Creating virtual environment..."
  cd "${REPO_ROOT}" && uv init --python=3.13 && uv venv .venv && \
    uv add psutil pyyaml hiredis redis frontmatter tree-sitter pydantic libtmux toml ruff black tiktoken pynvim aiosqlite orjson && \
    echo "    Virtual environment created at ${LOCAL_VENV_DIRECTORY}"
}


echo "==> Checking Redis..."
if ! redis-cli ping > /dev/null 2>&1; then
  echo "ERROR: Redis is not reachable. Start Redis and retry."
  exit 1
fi
echo "    Redis OK"

echo "==> Applying database migrations..."
uv run "${RUNNER}" --db-path "${DB_PATH}" apply

echo ""
echo "✓ Hook system setup complete"
