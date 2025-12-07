## Architecture Overview

This is a Python-focused Neovim configuration built on Lazy.nvim with the following key components:

### Plugin Management
- **Lazy.nvim**: Plugin manager with lazy loading
- Plugins organized in `lua/plugins/` with modular configuration files
- Auto-installs plugins and ensures required tools are available
- **Which-key**: Keybinding discovery and organization
- **Lualine** status line with file info and git integration

### Language Support Architecture
- **Mason** for automatic LSP server management
- **nvim-lspconfig** with pre-configured servers:
  - **Lua** (lua_ls) - Neovim configuration optimized
  - **Primary LSP Stack**: BasedPyright (type checking) + Ruff (linting/formatting)
  - **HTML/CSS** - Web development essentials
  - **Svelte** - Modern web framework support
  - **GraphQL** - API development
  - **Debugging**: nvim-dap with Python adapter and UI
  - **Completion**: nvim-cmp with LSP, snippets, buffer, and path sources
  - **UV Integration**: Built-in support for UV package management
  - **TreeSitter**: Syntax highlighting and text objects for Python, Lua, Markdown, JSON, YAML, HTML, Bash
- **Diagnostics** with custom icons and error handling
- **Go to definition/references** with Telescope integration

### 🔧 **Code Intelligence**

- **nvim-cmp** autocompletion with multiple sources:
  - LSP completion
  - File path completion
  - Buffer text completion
  - Snippet expansion
- **LuaSnip** with friendly snippets
- **Treesitter** syntax highlighting for 20+ languages
- **Code actions** and smart renaming
- **Incremental selection** with Treesitter

### 🔍 **Fuzzy Finding & Search**

- **Telescope** with multiple pickers:
  - File finder (`<leader>ff`)
  - Live grep (`<leader>fs`)
  - Recent files (`<leader>fr`)
  - Grep under cursor (`<leader>fc`)
  - Todo comments (`<leader>ft`)
  - Keymaps (`<leader>fk`)
- **FZF native** replacing Telescope for improved performance

### 📁 **File Management**

- **NeoTree** file explorer with:
  - Relative line numbers
  - Git integration
  - Custom icons and folder arrows
  - Auto-refresh functionality
- **Auto-session** for project session management

### 🎮 **Git Integration**

- **LazyGit** integration for git operations
- **Trouble** for diagnostics and quickfix management

### Key Integrations
- **UV Package Manager**: Native commands for Python project management
- **Auto-detection**: Automatically restarts LSP when changing directories
- **Virtual Environment**: Detects pyproject.toml and sets UV project context
- **FZF-lua**: Fuzzy finder for files, buffers, grep, and more
- **Flash.nvim**: Enhanced motion and search with custom directional labeling
- **Mini.ai**: Advanced text objects for Python functions, classes, and statements
- **Mini.surround**: Surround text objects with brackets, quotes, etc.
- **Mini.operators**: Text manipulation operators
- **Mini.indentscope**: Visual indent scope indication




