--[[
-- Neovim Global Configuration
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]

-----------------------------------------------
-- Key Setup
-----------------------------------------------
vim.g.mapleader = ' '
vim.g.log_level = 'warn' -- Use this for global debugging
-- place for personal utility & configuration options
_G.my = {}

-----------------------------------------------
-- Faster startup
-----------------------------------------------
if not pcall(require, 'impatient') then
  print 'Failed to load impatient.nvim'
end

-----------------------------------------------
-- Configuration
-----------------------------------------------

-- Plugin management via Packer
require 'plugins'
-- All non plugin related (vim) options
require 'settings'
-- Vim mappings, see lua/config/which.lua for more mappings
require 'mappings'

--require('core_config.lsp')
--require('core_config.keymaps')
--require('config.plugins')
--require('config.options')
--require('config.mappings')
--require('core_config.colorscheme')

-- vim.defer_fn(function()
--   require 'user.autocmds'
--   require 'user.mappings'
--   require 'user.plugins'
--   require 'user.plugin'
--   require 'user.completion'
--   require 'user.treesitter'
--   require 'user.quickfix'
-- end, 0)
--
--
-- local core_modules = {
--   'core',
--   'core.options',
--   'core.autocmds',
--   'core.statusline',
--   '_compiled',
-- }
--
-- for _, module in ipairs(core_modules) do
--   pcall(require, module)
-- end
--
-- -- Load keybindings module at the end because the keybindings module cost is high
-- vim.defer_fn(function()
--   require('core.mappings').basic()
-- end, 20)
--
--
