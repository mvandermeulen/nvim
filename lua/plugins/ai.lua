--[[
-- AI Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-08-28
--]]


local status_ok, ai = pcall(require, 'ai')
if not status_ok then
  return
end

ai.setup({
  provider = "ollama",
  ollama = {
    model = "codestral:latest", -- You can start with smaller one like `gemma2` or `llama3.1`
    --endpoint = "http://192.168.2.47:11434", -- In case you access ollama from another machine
  }
})

