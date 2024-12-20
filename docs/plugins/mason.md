# Mason Plugin

## Original Inspiration
- [filepe3000](https://github.com/felipe300/Nvim-setup/blob/main/lua/base/plugins/lsp/mason.lua)

## Setup

Overview of plugin setup in order of operations.

### Load Plugins

- mason
- mason-lspconfig
- mason-null-ls
- lspconfig

### Config Files

- `lang = require('config.lsp.lang')`
- `lsputils = require('config.lsp.utils')`
- `handlers = require('config.lsp.handlers')`

### Overview

1. Loads plugins
2. Source config files
3. Configure `settings`
4. Run `mason.setup(settings)`
5. Call `mason_lspconfig.setup({ ensure_installed = lang.servers, automatic_installation = true, })`
6. Call `mason_null_ls.setup({ ensure_installed = lang.parsers, automatic_installation = true, })`
7. Call `handlers.setup()`
8. Call `mason_lspconfig.setup_handlers()`
9. Loop through servers in `lang.servers`:
  - Load `opts` from `config.lsp.servers.[server]`
  - Perform `lspconfig[server].setup(opts)`


