--[[
-- Which Key Plugin
-- Author: Mark van der Meulen
-- Updated: 2024-12-21
--]]

local status_ok, wk = pcall(require, 'which-key')
if not status_ok then
  return
end

