--[[
-- Copilot Chat Plugin: Window
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-26
--]]

local icons = require("helpers.ui.icons")

return {
  layout = 'horizontal', -- Options: 'vertical', 'horizontal', 'float', 'replace'
  -- layout = 'float', -- Options: 'vertical', 'horizontal', 'float', 'replace'
  -- width = 0.6,
  height = 0.3,
  -- height = 0.4,
  border = 'single', -- Options: 'none', 'single', 'double', 'rounded', 'solid', 'shadow'
  relative = 'editor', -- Options: 'editor', 'win', 'cursor', 'mouse'
  winblend = 0, -- Set winblend to 0 for no transparency
  title = icons.ui.Copilot .. ' Copilot Chat', -- title of chat window
}
