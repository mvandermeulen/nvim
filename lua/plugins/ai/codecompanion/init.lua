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
    -- action_palette = {
    --   provider = "telescope",
    -- },
    chat = {
      render_headers = false,
      show_settings = true,
    },
  },
  adapters = require('plugins.ai.codecompanion.adapters'),
  strategies = {
    chat = {
      adapter = "qwen_7b_mba",
      -- adapter = "copilot",
    },
    inline = {
      adapter = "copilot_sonnet",
    },
    agent = {
      adapter = "copilot_sonnet",
    },
  },
})

local ccs_status, ccs = pcall(require, 'plugins.ai.codecompanion.setup')
if not ccs_status then
  vim.notify('Unable to load CodeCompanion setup module', vim.log.levels.ERROR)
  return
end
ccs.setup()
-- require('plugins.ai.codecompanion.setup').setup()
