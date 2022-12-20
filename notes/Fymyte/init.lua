-------------------------------------------------------------------------------
-- FILE: init.lua
-- AUTHORS: @Fymyte - https://github.com/Fymyte
-------------------------------------------------------------------------------

--[[ NOTE:

Much of the configuration can be found in either:

./after/plugin/*
  This is where configuration for most plugins is located.
  Configurations are sourced automatically at startup

./plugin/*.lua
  This is where config for vim default options live.
  - options
  - keymaps
  - diagnostics

./lua/user/*.lua
  This is where added functionalities are located.
  Utils functions, or plugins extensions are also in this directory

--]]


-- If packer is not installed, install and quit.
if not require 'fymyte.packer_bootstrap'.installed() then
  return
end

-- Manually source the packer_compiled file for plugins using `rtp`
local packer_compiled = vim.fn.stdpath('config') .. '/plugin/packer_compiled.lua'
vim.cmd('luafile'  .. packer_compiled)

-- remove navigation using space
vim.keymap.set('', '<space>', '<nop>', { noremap=true, silent=true })
vim.g.mapleader = ' '     -- Leader key -> "<space>"
vim.g.log_level = 'warn'  -- Use this for global debugging

require'fymyte/globals'
require'fymyte.lsp'
