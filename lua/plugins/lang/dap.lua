--[[
-- DAP Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-20
--]]


local status_ok, dap = pcall(require, 'dap')
if not status_ok then
  return
end
