## Folder Structure

See README.md for the complete overview. Key points for Claude:

**Current Active Structure:**

- `init.lua` - Entry point that loads settings, plugins, mappings and helpers.
- `lua/plugins/init.lua` - Loads plugin specifications for Lazy.nvim and calls setup.
- `lua/settings/*.lua` - General Vim settings and options
- `lua/mappings/init.lua` - Loads custom Key mappings defined outside of which-key
- `lua/plugins/{category}/init.lua` - Plugin configurations
- `lua/config/lsp/mason.lua` - LSP-specific configurations
- `lua/config/lsp/servers/` - Language Server Configurations
- `lua/helpers/init.lua` - Loads desired helper configs


