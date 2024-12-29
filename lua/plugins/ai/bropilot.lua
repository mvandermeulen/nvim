--[[
-- Bropilot Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-10
--]]


local status_ok, bropilot = pcall(require, 'bropilot')
if not status_ok then
  return
end

bropilot.setup({
  auto_suggest = true,
  excluded_filetypes = {},
  model = "RobinBially/qwen2.5-coder-16k:7b-instruct-q4_K_M",
  model_params = {
    num_ctx = 16384,
  },
  debounce = 500,
  preset = true,
  keymap = {
    accept_line = "<M-o>",
    accept_block = "<M-b>",
    suggest = "<M-;>",
  },
  ollama_url = "http://ml-worker:11434/api",
})
