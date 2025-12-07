## Development Workflows

The repository includes utilities for various development workflows:

1. Python development with Poetry and virtualenv
2. Rust development with Cargo and rustup
3. Git workflow shortcuts and utilities
4. Neovim as the primary editor with LSP configuration

### Claude Development Workflow

When making changes to this repository:

1. **Verify file existence** before referencing scripts or commands
1. **Use actual file paths** from the repository structure
1. **Update all relevant README.md files** after making any user-facing changes
1. **Update all relevant project-level CLAUDE.md files** after clarifying any Claude-specific workflows

### LSP Configuration
- **BasedPyright**: Primary language server for type checking
- **Ruff**: Linting and formatting (hover disabled in favor of BasedPyright)
- Both configured to work with virtual environments
- Auto-format on save available via `<leader>lf`
- **Diagnostic Display**: Uses floating windows instead of above-line virtual text for better readability

### Debugging Setup
- Debugpy adapter configured with Mason-installed debugpy at `~/.local/share/nvim/mason/packages/debugpy/venv/bin/python`
- UI automatically opens/closes with debug sessions
- Virtual text shows variable values during debugging
- F-keys mapped for step debugging (F5=continue, F10=step_over, F11=step_into, F12=step_out)

## Testing Guidelines
- Validate no startup errors via headless check above.
- Use `:checkhealth` and confirm Mason/LSP tools are installed.
- Repro minimal issues with `nvim -u NONE` (baseline) vs. `NVIM_APPNAME=nvim-dev nvim` (this config).
- Snippets: open a buffer of the target filetype and expand to verify.

## Commit & Pull Request Guidelines
- Commits: short, present-tense summaries (style seen in history, e.g., “add kotlin snippet”, “telescope hidden files”).
- PRs: include a concise description, affected modules, any new keymaps, and before/after notes or screenshots (when UX-visible).
- Link related issues; note breaking changes or migration steps (e.g., plugin rename, moved files).