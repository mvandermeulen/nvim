--[[
-- Helpers: AI Providers
--
-- Author: Mark van der Meulen
-- Updated: 2025-01-12
--]]

local M = {}

local ai_models = require('helpers.ai.models')

M.ollama = {
  servers = {
    { hostname = 'mba', port = '11434', priority = 1000},
    { hostname = 'ml-worker', port = '11434', priority = 800},
    { hostname = 'mbp', port = '11434', priority = 500},
    { hostname = 'localhost', port = '11434', priority = 400},
    { hostname = 'localhost', port = '11435', priority = 350},
    { hostname = 'localhost', port = '11436', priority = 350},
    { hostname = 'localhost', port = '11437', priority = 350},
    { hostname = 'localhost', port = '11438', priority = 350},
    { hostname = 'localhost', port = '11439', priority = 350},
    { hostname = 'localhost', port = '11440', priority = 350},
  },
  models = ai_models.ollama,
}

M.copilot = {
  models = ai_models.copilot,
}

M.huggingface = {
  models = ai_models.huggingface,
}

M.github = {
  models = ai_models.github,
}

M.anthropic = {
  models = ai_models.anthropic,
}

M.groq = {
  models = ai_models.groq,
}

M.openai = {
  models = ai_models.openai,
}


return M
