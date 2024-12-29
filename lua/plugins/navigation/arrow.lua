--[[
-- Arrow Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-21
--]]

local status_ok, arrow = pcall(require, 'arrow')
if not status_ok then
  return
end

arrow.setup()
