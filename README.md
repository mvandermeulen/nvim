# Neovim Config


## Overview

You will want to clone the repo and run the packer install. It may require a little tweaking if using on windows as I store a fair bit in ~/.local on macos/linux and my home directory is initialised by the setup scripts not the neovim scripts.

When I want to reset my local install I run the following which can probably be adapted for Windows:

```
rm -rf ~/.local/share/nvim && rm -rf ~/.cache/nvim && git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

## Configuration Structure

The init.lua file is the where the entire high level configuration reside. This file works as follows:

1. Sets leader to `<space>` and log level to `warn`
2. Creates global `_G.my = {}`
3. Sets UI config in global variable `_G`: `_G.my.ui = { theme = 'rose-pine', bg = 'dark' }`
4. Loads Plugin: impatient.nvim
5. Loads config module: plugins
6. Loads config module: settings
7. Loads config module: mappings
8. Sets the colorscheme



### Plugins Configuration

File Path: `lua/plugins/init.lua`

Plugins are loaded in the following order:

1. Packet loads itself.
2. Impatient
3. `norcalli/nvim-terminal` -> `terminal`
4. `tami5/sqlite.lua`
5. FZF
6. Telescope & Dependencies -> `telescope`
7. `sudormrfbin/cheatsheet.nvim` -> `cheatsheet`
8. Treesitter & Dependencies -> `treesitter`, `treesitter-context` 
9. Clipboard & Registers -> `neoclip`
10. File Management -> `nvim-tree`
11. Window Management & Navigation -> ``, ``, ``, ``, ``
12. Completion Plugins -> ``, ``, ``, ``, ``
13. Snippets -> ``, ``, ``, ``, ``
14. Git Plugins -> ``, ``, ``, ``, ``
15. Buffer Plugins -> ``, ``, ``, ``, ``
16. LSP Configuration -> `mason`, `lsp-signature`, `null-ls`, `goto-preview`, `symbols`
17. Terminal & Command Plugins -> `toggleterm`, `fterm`, `toggletasks`
18. Search highlighting -> `todo`
19. Navigation -> `neoscroll`, `which`
20. Project/Session Management -> `harpoon`, `project`, `sessions`, `workspaces`, `persistence`
21. Language Plugins -> `yaml`, `go`, `webtools`
22. UI Plugins -> `notify`, `marks`, `lualine`, `colorizer`, `zen-mode`, `twilight`, `indent-blankline`, `comment-box`, `alpha-nvim`, `nvim-bqf`, `trouble`
23. Colorschemes -> `nightfox`
24. Integrations -> `http-rest`
25. General Plugins -> `mini`, `numb`, `comment`, `undotree`
25.  -> ``, ``, ``, ``, ``
26.  -> ``

#### Language Server & LSP Configuration

##### Mason Configuration

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

##### LSP Signature

File Path: `lua/plugins/lsp-signature.lua`

File Path: `lua/config/lsp/signature.lua`
- Returns a dictionary (lua table) with keys: '', ''
- Returns a dictionary (lua table) with method: ''

##### Null ls

File Path: `lua/plugins/null-ls.lua`
- Returns a dictionary (lua table) with keys: '', ''
- Returns a dictionary (lua table) with method: ''

##### Goto Preview

File Path: `lua/plugins/goto-preview.lua`

##### Symbols Outline

File Path: `lua/plugins/symbols.lua`







### Settings Configuration

File Path: `lua/settings/init.lua`

#### Autocmd

#### Colour

#### Helpers

#### Options

#### UI



### Mappings Configuration

File Path: `lua/mappings/init.lua`

#### Applications
- 

#### Buffers
- 

#### Clipboard
- 

#### Colors
- 

#### Comments
- 

#### Diagnostics
- 

#### Files
- 

#### Find
- 

#### Focus
- 

#### Git
- 

#### Harpoon
- 

#### Inserts
- 

#### Local
- 

#### Lsp
- 

#### Misc
- 

#### Modes
- 

#### Neovim
- 

#### Others
- 

#### Packer
- 

#### Pandoc
- 

#### Plugins
- 

#### Prompts
- 

#### Search
- 

#### Settings
- 

#### Surround
- 

#### Terminal
- 

#### Treesitter
- 

#### Window
- 

#### Workspace
- 


