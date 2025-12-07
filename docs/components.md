## Key Components

### Plugin Management
- Uses Lazy.nvim with plugins defined in `lua/plugins_lazy.lua`
- Supports local development plugins (gcloudrun.nvim in ~/Development)
- Plugins are loaded with lazy loading strategies for performance

### LSP Setup
- Mason for LSP server management
- Custom LSP configurations for Go (gopls), Helm (helm_ls), and Laravel (laravel_ls)
- UFO plugin for enhanced folding with LSP support
- Lspsaga for enhanced LSP UI

### Key Features
- Telescope for fuzzy finding with live grep args extension
- TreeSJ for splitting/joining code structures
- Spectre and SSR for search and replace
- Multiple cursor support with vim-visual-multi
- Git integration with Fugitive, Gitsigns, and Diffview
- AI integration with ChatGPT (Avante) and GitHub Copilot

### Theme and UI
- GitHub dark theme as default
- Lualine statusline with bufferline
- NeoTree file explorer
- Scrollbar with git signs integration
- Statuscol for enhanced status column
