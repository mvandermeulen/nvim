--[[
-- Copilot Chat Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-08
--]]

local icons = require("helpers.ui.icons")
local prompts = require('plugins.ai.copilot_chat.prompts')
local window_settings = require('plugins.ai.copilot_chat.window')
local keys = require('plugins.ai.copilot_chat.mappings')
local chat = require("CopilotChat")
local select = require("CopilotChat.select")

vim.fn.setenv('ANTHROPIC_API_KEY', vim.env.ANTHROPIC_API_KEY)
vim.fn.setenv('OPENAI_API_KEY', vim.env.OPENAI_API_KEY)
vim.fn.setenv('GEMINI_API_KEY', vim.env.GEMINI_API_KEY)
vim.fn.setenv('GROQ_TOKEN', vim.env.GROQ_TOKEN)



opts = {
  debug = false, -- Enable debugging
  log_level = 'info',
  agent = 'copilot',
  question_header   = '  User ', -- Header to use for user questions
  -- answer_header     = '  Copilot ', -- Header to use for AI answers
  -- error_header      = '  Error ', -- Header to use for errors
  -- question_header = '# ' .. icons.ui.User .. 'User', -- Header to use for user questions
  answer_header = '# ' .. icons.ui.Copilot .. 'Copilot', -- Header to use for AI answers
  error_header = '## ' .. icons.ui.CopilotError .. 'Error', -- Header to use for errors
  chat_autocomplete = false, -- Enable chat autocompletion (when disabled, requires manual `mappings.complete` trigger)
  prompts = prompts,
  model = 'claude-3.5-sonnet', -- model to use, :CopilotChatModels for available models
  context = 'buffers', -- Default context to use, 'buffers', 'buffer' or none (can be specified manually in prompt via @).
  history_path = vim.fn.stdpath('data') .. '/copilot_chat_history', -- Default path to stored history
  auto_follow_cursor = true, -- Don't follow the cursor after getting response
  show_folds = false,
  show_help = false,
  auto_insert_mode = false,
  clear_chat_on_new_prompt = false, -- Clears chat on every new prompt
  window = window_settings,
  mappings = keys,
}

opts.selection = select.unnamed
chat.setup(opts)

vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
  chat.ask(args.args, { selection = select.visual })
end, { nargs = "*", range = true })

-- Inline chat with Copilot
vim.api.nvim_create_user_command("CopilotChatInline", function(args)
  chat.ask(args.args, {
    selection = select.visual,
    window = {
      layout = "float",
      relative = "cursor",
      width = 1,
      height = 0.15,
      row = 1,
    },
  })
end, { nargs = "*", range = true })

-- Restore CopilotChatBuffer
vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
  chat.ask(args.args, { selection = select.buffer })
end, { nargs = "*", range = true })

-- Custom buffer for CopilotChat
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "copilot-*",
  callback = function()
    vim.opt_local.relativenumber = true
    vim.opt_local.number = true
    local chat = require('CopilotChat')

    -- Get current filetype and set it to markdown if the current filetype is copilot-chat
    local ft = vim.bo.filetype
    if ft == "copilot-chat" then
      vim.bo.filetype = "markdown"
    end
    vim.keymap.set('n', '<leader>ccS', function()
      local date = os.date('%Y-%m-%d') --[[@ as string]]
      chat.save(date)
    end, { buffer = true, desc = 'Save chat' })
    vim.keymap.set('n', 'gs', function()
      local date = os.date('%Y-%m-%d') --[[@ as string]]
      chat.save(date)
    end, { buffer = true, desc = 'Save chat' })
    -- C-p to print last response
    vim.keymap.set('n', '<C-p>', function()
      print(require("CopilotChat").response())
    end, { buffer = true, remap = true, silent = true, desc = 'Print last response' })
  end,
})


vim.keymap.set("n", "<M-,>", function ()
  local actions = require("CopilotChat.actions")
  require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
end, { noremap = true, silent = true, desc = 'CopilotChat - Prompt Actions' })


