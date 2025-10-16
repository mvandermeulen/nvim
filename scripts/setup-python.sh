#!/bin/bash

echo "Setting up Neovim Python development environment..."

# Install plugins
echo "Installing plugins..."
nvim --headless -c "Lazy! sync" -c "qa"

# Install Mason tools
echo "Installing LSP servers and tools..."
nvim --headless -c "MasonInstall basedpyright ruff debugpy mypy" -c "qa"

# Wait for installations to complete
echo "Waiting for installations to complete..."
sleep 5

# Verify installations
echo "Verifying installations..."
nvim --headless -c "lua local mason = require('mason-registry'); print('BasedPyright:', mason.is_installed('basedpyright')); print('Ruff:', mason.is_installed('ruff')); print('Debugpy:', mason.is_installed('debugpy'))" -c "qa"

echo "Setup complete! Your Neovim Python environment is ready."
echo "Run 'nvim' to start using your configured environment."