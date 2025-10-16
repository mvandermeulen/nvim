--[[
-- Flatten Plugin
-- Author: Mark van der Meulen
-- Updated: 2025-10-16
--]]

-- Link: https://github.com/willothy/flatten.nvim

return {
  {
    'willothy/flatten.nvim',
    config = true,
    -- or pass configuration with
    -- opts = {  }
    -- Ensure that it runs first to minimize delay when opening file from terminal
    lazy = false,
    priority = 1001,
  },
}
