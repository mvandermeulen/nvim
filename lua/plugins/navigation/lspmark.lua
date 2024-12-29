--[[
-- LSP Marks Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-23
--]]


local status_ok, lspmark = pcall(require, 'lspmark')
if not status_ok then
  return
end

lspmark.setup()

