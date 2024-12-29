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
  mappings = {
    ask = "<leader>Aa",
    edit = "<leader>Ae",
    refresh = "<leader>Ar",
    diff = {
      ours = "co",
      theirs = "ct",
      both = "cb",
      next = "]x",
      prev = "[x",
    },
    jump = {
      next = "]]",
      prev = "[[",
    },
    submit = {
      normal = "<CR>",
      insert = "<C-s>",
    },
    toggle = {
      debug = "<leader>Ad",
      hint = "<leader>Ah",
    },
  },
})


