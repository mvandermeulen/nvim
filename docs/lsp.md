
## Language Server & LSP Configuration

### Mason Configuration

File Path: `lua/plugins/mason.lua`

File Path: `lua/config/lsp/mason.lua`

File Path: `lua/config/lsp/lang.lua`
- Returns a dictionary (lua table) with keys: 'parsers', 'servers'

File Path: `lua/config/lsp/utils.lua`
- Returns a dictionary (lua table) with keys: 'capabilities', 'hs_version', 'hs_path'
- Returns a dictionary (lua table) with method: 'get_python_path'

We run the following mason functions:
- `mason.setup(settings)`
- `mason_lspconfig.setup()`
- `mason_null_ls.setup()`
- `mason_lspconfig.setup_handlers()`

Next we loop through the list of servers, retrieve configuration and run `lspconfig[server].setup(opts)` where opts is the server configuration.

### LSP Signature

File Path: `lua/plugins/lsp-signature.lua`

File Path: `lua/config/lsp/signature.lua`
- Returns a dictionary (lua table) with keys: '', ''
- Returns a dictionary (lua table) with method: ''

### Null ls

File Path: `lua/plugins/null-ls.lua`
- Returns a dictionary (lua table) with keys: '', ''
- Returns a dictionary (lua table) with method: ''

### Goto Preview

File Path: `lua/plugins/goto-preview.lua`

### Symbols Outline

File Path: `lua/plugins/symbols.lua`

