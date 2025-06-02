--[[
-- Neovim Global Configuration
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

require 'start'
require 'settings' -- All non plugin related (vim) options
require 'plugins'
require 'mappings' -- Vim mappings, see lua/config/which.lua for more mappings
require 'helpers'

if not _G.my.firstload then
  vim.cmd([[colorscheme catppuccin-mocha]])
end
