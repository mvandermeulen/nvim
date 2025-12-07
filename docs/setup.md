## Setup and Installation Commands

### Initial Setup
- Install Neovim: `brew install neovim`
- Install dependencies: `brew install ripgrep fd` (for Telescope)
- Clone to `~/.config/nvim`
- Run the setup script in `scripts/setup-python.sh`


```bash
# Run the Python environment setup script
./scripts/setup-python.sh
```

This script:
- Installs all Neovim plugins via Lazy.nvim
- Installs Mason tools (basedpyright, ruff, debugpy, mypy)
- Verifies installations

### Manual Tool Management
```bash
# Launch Neovim and install/update plugins
nvim --headless -c "Lazy! sync" -c "qa"

# Install specific Mason tools
nvim --headless -c "MasonInstall basedpyright ruff debugpy mypy" -c "qa"

# Update TreeSitter parsers
nvim --headless -c "TSUpdate" -c "qa"
```

### Language Server Setup
- Run `:Mason` in Neovim
- Install packages listed in `lua/config/lsp/lang.lua`:
  - basedpyright, luals
  - typescript-language-server
  - eslint_d, prettier, shfmt, stylua
  - lua-language-server, json-lsp, eslint-lsp
  - vue-language-server (if needed)

### Copilot Setup
- Run `:Copilot setup` and follow authentication steps
- Requires GitHub account with Copilot enabled

### Troubleshooting
- Use `:checkhealth [PACKAGE_NAME]` to diagnose issues





