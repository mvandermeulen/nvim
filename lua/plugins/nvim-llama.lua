--[[
-- Ollama Interface
--
-- Author: Mark van der Meulen
-- Updated: 2024-01-16
--]]

local status_ok, llama = pcall(require, 'nvim-llama')
if not status_ok then
  return
end

local defaults = {
  -- See plugin debugging logs
  debug = false,
  -- The model for ollama to use. This model will be automatically downloaded.
  model = 'dolphin-mixtral:8x7b',
}



llama.setup()
-- llama.setup(defaults)
