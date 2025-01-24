--[[
-- Helpers: AI Models
--
-- Author: Mark van der Meulen
-- Updated: 2025-01-12
--]]


local M = {}

M.ollama = {
  chat = {
    { name = '', id = '', ctx_limit = 16384, restricted = { servers = { 'mba', 'mbp' }, } },
    { name = '', id = '', ctx_limit = 16384, restricted = { servers = { 'mba', 'mbp' }, } },
  },
  inline = {
    { name = '', id = '', ctx_limit = 16384, restricted = { servers = { 'mba', 'mbp' }, } },
    { name = '', id = '', ctx_limit = 16384, restricted = { servers = { 'mba', 'mbp' }, } },
  },
  tools = {
    { name = '', id = '', ctx_limit = 16384, restricted = { servers = { 'mba', 'mbp' }, } },
    { name = '', id = '', ctx_limit = 16384, restricted = { servers = { 'mba', 'mbp' }, } },
  },
  agents = {
    { name = '', id = '', ctx_limit = 16384, restricted = { servers = { 'mba', 'mbp' }, } },
    { name = '', id = '', ctx_limit = 16384, restricted = { servers = { 'mba', 'mbp' }, } },
  },
}

M.copilot = {
  chat = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  inline = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  tools = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  agents = {
    { name = '', id = '', ctx_limit = 16384 },
  },
}

M.huggingface = {
  chat = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  inline = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  tools = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  agents = {
    { name = '', id = '', ctx_limit = 16384 },
  },
}

M.github = {
  chat = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  inline = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  tools = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  agents = {
    { name = '', id = '', ctx_limit = 16384 },
  },
}


M.anthropic = {
  chat = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  inline = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  tools = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  agents = {
    { name = '', id = '', ctx_limit = 16384 },
  },
}


M.groq = {
  chat = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  inline = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  tools = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  agents = {
    { name = '', id = '', ctx_limit = 16384 },
  },
}


M.openai = {
  chat = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  inline = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  tools = {
    { name = '', id = '', ctx_limit = 16384 },
  },
  agents = {
    { name = '', id = '', ctx_limit = 16384 },
  },
}



return M
