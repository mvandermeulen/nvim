--[[
-- FZF
-- Author: Mark van der Meulen
-- Updated: 16-05-2022
--]]

local status_ok, fzf_lua = pcall(require, 'fzf-lua')
if not status_ok then
  return
end

-- local actions = require 'fzf-lua.actions'

fzf_lua.setup {}
