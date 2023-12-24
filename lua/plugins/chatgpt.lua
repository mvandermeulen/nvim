--[[
-- ChatGPT Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2023-08-09
--]]

-- The OpenAI API key can be provided in one of the following two ways:

-- In the configuration option api_key_cmd, provide the path and arguments to an executable that returns the API key via stdout.
-- Setting it via an environment variable called $OPENAI_API_KEY.

local status_ok, chatgpt = pcall(require, 'chatgpt')
if not status_ok then
  return
end

chatgpt.setup()
