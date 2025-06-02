--[[
-- Avante: Vendors
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-26
--]]


return {
  groq = {
    __inherited_from = 'openai',
    api_key_name = 'GROQ_API_KEY',
    endpoint = 'https://api.groq.com/openai/v1/',
    model = 'llama-3.3-70b-specdec',
  },
  copilot = {
    model = "claude-3.5-sonnet",
    extra_request_body = {
      max_tokens = 8192, -- Copilot has a max token limit of 4096
    },
  },
  -- cerebras = {
  --   __inherited_from = 'openai',
  --   api_key_name = 'CEREBRAS_API_KEY',
  --   endpoint = 'https://api.cerebras.ai/v1/',
  --   model = 'llama3.1-70b',
  -- },
}
