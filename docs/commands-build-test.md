## Development Commands

Since this is a Neovim configuration, there are no traditional build/test commands. Configuration changes are applied by:

1. Reloading Neovim (`:qa` and restart)
2. Using `:Lazy sync` to update plugins
3. Using `:Mason` to manage LSP servers


### Build, Test, and Development Commands
- Run Neovim with this config: `nvim` (uses this directory by default).
- Isolated dev sandbox: `NVIM_APPNAME=nvim-dev nvim` (safe to experiment).
- Headless startup check: `NVIM_APPNAME=nvim-dev nvim --headless '+qall'` (fails on errors).
- Format code: `stylua init.lua lua/ lsp/`.
- Plugin ops (inside Neovim): `:Lazy sync` (install/update), `:Lazy clean`, `:checkhealth`, `:Mason`.
- Reload current file after edits: `:luafile %`.
