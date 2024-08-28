--[[
-- Neovim Global Configuration
-- Author: Mark van der Meulen
-- Updated: 2024-08-22
--]]

-----------------------------------------------
-- Key Setup
-----------------------------------------------
vim.g.mapleader = ' '
vim.g.log_level = 'warn' -- Use this for global debugging
-- place for personal utility & configuration options
_G.my = {}
_G.my.plugins = {}
_G.my.plugins.themes = require('config.vdm.theme-plugins')
_G.my.ui = { theme = 'catpuccin-mocha', bg = 'dark' }
-- _G.my.ui = { theme = 'kanagawa', bg = 'dark' }
-- _G.my.ui = { theme = 'rose-pine', bg = 'dark' }
-- _G.my.ui = { theme = 'aura-soft-dark', bg = 'dark' }
-----------------------------------------------
-- Faster startup
-----------------------------------------------
vim.loader.enable()
-----------------------------------------------
-- Configuration
-----------------------------------------------
-- All non plugin related (vim) options
require 'settings'
require 'plugins'
-- Vim mappings, see lua/config/which.lua for more mappings
require 'mappings'
require 'helpers'
-- Finalise UI
vim.cmd(string.format('set background=%s', _G.my.ui.bg))
-- vim.cmd(string.format('colorscheme %s', _G.my.ui.theme))
-- vim.cmd.colorscheme(string.format('%s', _G.my.ui.theme))
vim.cmd([[colorscheme catppuccin-mocha]])

