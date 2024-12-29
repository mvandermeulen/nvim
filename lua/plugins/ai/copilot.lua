--[[
-- Copilot Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-08
--]]


local status_ok, copilot = pcall(require, 'copilot')
if not status_ok then
  return
end

local copilot_api = require 'copilot.api'
-- local copilot_suggestion = require 'copilot.suggestion'
-- local copilot_panel = require 'copilot.panel'
local ns = vim.api.nvim_create_namespace 'user.copilot'

copilot.setup({
  panel = {
    enabled = true,
    auto_refresh = true,
    keymap = {
      jump_prev = "[[",
      jump_next = "]]",
      accept = "<CR>",
      refresh = "gr",
      open = "<M-CR>"
    },
    layout = {
      position = "bottom", -- | top | left | right
      ratio = 0.3
    },
  },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    debounce = 50,
    keymap = {
      accept = "<C-o>",
      next = "<M-]>",
      -- next = "<C-d>",
      -- prev = "<C-u>",
      prev = "<M-[>",
      dismiss = "<C-;>",
      accept_word = false,
      -- accept = "<M-l>",
      -- next = "<M-]>",
      -- prev = "<M-[>",
      -- dismiss = "<C-]>",
    },
  },
  filetypes = {
    yaml = true,
    markdown = true,
    python = true,
    help = false,
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    ["."] = false,
  },
  copilot_node_command = 'node', -- Node.js version must be > 18.x
  server_opts_overrides = {},
})

copilot_api.register_status_notification_handler(function(data)
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  if vim.fn.mode() == 'i' and data.status == 'InProgress' then
    vim.api.nvim_buf_set_extmark(0, ns, vim.fn.line '.' - 1, 0, {
      virt_text = { { ' 🤖Thinking...', 'Comment' } },
      virt_text_pos = 'eol',
      hl_mode = 'combine',
    })
  end
end)
