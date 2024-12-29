--[[
-- Copilot Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-08
--]]


local status_ok, codecompanion = pcall(require, 'codecompanion')
if not status_ok then
  return
end

codecompanion.setup({
  display = {
    action_palette = {
      provider = "telescope",
    },
    chat = {
      render_headers = false,
      show_settings = true,
    },
  },
  adapters = require('plugins.ai.codecompanion.adapters'),
  strategies = {
    chat = {
      adapter = "copilot",
    },
    inline = {
      adapter = "copilot",
    },
    agent = {
      adapter = "copilot",
    },
  },
})

-- require('plugins.ai.codecompanion.setup').setup()
