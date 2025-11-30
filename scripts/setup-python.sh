#!/usr/bin/env zsh

PREVIOUS_SCRIPT_NAME="${SCRIPT_NAME:-zsh}"; export SCRIPT_NAME="${0:A:t}";
SCRIPT_DIRECTORY=${0:a:h}
OTHER_SCRIPT_DIRECTORY="$(dirname $0:A)"

#######################################
# Libraries
#######################################
[[ -f "${HOME}/.zshenv" ]] && source "${HOME}/.zshenv"
source "${SHARED_FUNCTIONS_PATH}/log.functions.sh" || {
  echo "Fatal error loading required log scripts!"; return 1;
}
source "${SHARED_FUNCTIONS_PATH}/util.functions.sh" || {
  mylogp "error" "Fatal error loading required utility scripts!"; return 1;
}

mylogp "info" "Setting up Neovim Python development environment..."

# Install plugins
mylogp "info" "Installing plugins..."
nvim --headless -c "Lazy! sync" -c "qa"

# Install Mason tools
mylogp "info" "Installing LSP servers and tools..."
nvim --headless -c "MasonInstall basedpyright ruff debugpy mypy" -c "qa"

# Wait for installations to complete
mylogp "info" "Waiting for installations to complete..."
sleep 5

# Verify installations
mylogp "info" "Verifying installations..."
nvim --headless -c "lua local mason = require('mason-registry'); print('BasedPyright:', mason.is_installed('basedpyright')); print('Ruff:', mason.is_installed('ruff')); print('Debugpy:', mason.is_installed('debugpy'))" -c "qa"

mylogp "info" "Setup complete! Your Neovim Python environment is ready."
mylogp "info" "Run 'nvim' to start using your configured environment."
