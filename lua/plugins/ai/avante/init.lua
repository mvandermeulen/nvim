--[[
-- Avante Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-08-28
--]]


local status_ok, avante = pcall(require, 'avante')
if not status_ok then
  return
end

avante.setup({
  -- provider = "claude",
  -- claude = {
  --   endpoint = "https://api.anthropic.com",
  --   model = "claude-3-5-sonnet-20240620",
  --   temperature = 0,
  --   max_tokens = 4096,
  -- },
  provider = "copilot",
  auto_suggestions_provider = "copilot",
  windows = {
    position = 'bottom',
    wrap = true, -- similar to vim.o.wrap
    width = 30, -- default % based on available width
    sidebar_header = {
      align = 'center', -- left, center, right for title
      rounded = true,
    },
    ask = {
      floating = true,
      focus_on_apply = 'theirs',
    },
  },
  providers = require('plugins.ai.avante.vendors'),
  hints = { enabled = true },
  behaviour = {
    auto_suggestions = false, -- Experimental stage
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = true,
    minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
  },
  mappings = require('plugins.ai.avante.mappings'),
})


