--[[
-- Helpers: Precognition
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-23
--]]

local M = {}

function M.toggle()
  if require("precognition").toggle() then
      vim.notify("precognition on")
  else
      vim.notify("precognition off")
  end
end

return M
