## Important Notes

- Leader key: Space (`" "`)
- Local leader: Backslash (`"\"`)
- Python files use 2-space indentation, 88-character line width
- LSP servers restart automatically when changing project directories
- Configuration assumes ruff.toml exists in home directory (`~/ruff.toml`)
- Line numbers and sign column always visible
- Smart case search enabled
- Clear search highlighting with `<Esc>`
- Diagnostic display uses floating windows on CursorHold (500ms delay)
- Very magic regex mode enabled by default
- Uses Neovim's job control API for terminal management
- State cleanup is important to avoid resource leaks (timers, jobs, autocmds)
- Formatter configurations for Lua (stylua), TypeScript/JavaScript (prettier)
- Go-specific configuration with custom gopls path and logging