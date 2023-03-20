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
_G.my.ui = { theme = 'rose-pine', bg = 'dark' }
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
-- Finalise UI
vim.cmd(string.format('set background=%s', _G.my.ui.bg))
vim.cmd(string.format('colorscheme %s', _G.my.ui.theme))

