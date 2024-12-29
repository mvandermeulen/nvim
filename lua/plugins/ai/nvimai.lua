--[[
-- AI Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-20
--]]


local status_ok, ai = pcall(require, 'ai')
if not status_ok then
  return
end

ai.setup({
  provider = "gemini",
  -- ollama = {
  --   model = "RobinBially/qwen2.5-coder-16k:7b-instruct-q4_K_M", -- You can start with smaller one like `gemma2` or `llama3.1`
  --   -- model = "granite-code:8b", -- You can start with smaller one like `gemma2` or `llama3.1`
  --   endpoint = "http://ml-worker:11434", -- In case you access ollama from another machine
  -- }
  keymaps = {
    toggle = "<leader>Ag",
    send = "<S-Space>",
    close = "q",
    clear = "<leader>Ax",
    previous = "<leader>A[",
    next = "<leader>A]",
    inline_assist = "<leader>Ai",
    stop_generate = "<leader>AX",
  },
  behavior = {
    auto_open = true, -- Automatically open dialog when sending a message
    save_history = true, -- Save chat history between sessions
    history_dir = vim.fn.stdpath("data"), -- Path to save chat history
  },
  appearance = {
    icons = {
      user = "🧑", -- Icon for user messages
      assistant = "🤖", -- Icon for assistant messages
      system = "🖥️", -- Icon for system messages
      error = "❌", -- Icon for error messages
    },
    syntax_highlight = true, -- Syntax highlight code in responses
  },
})

