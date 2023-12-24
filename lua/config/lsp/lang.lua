--[[
-- LSP Languages
-- Author: Mark van der Meulen
-- Updated: 13-02-2023
--]]

local M = {}

M.parsers = {
  "bash",
  "c",
  "cpp",
  "css",
  "scss",
  "dockerfile",
  "gitignore",
  "html",
  "json",
  "markdown",
  "python",
  "sql",
  "lua",
  "javascript",
  "typescript",
  "tsx",
  "yaml",
  "vim"
}

M.servers = {
  'lua_ls',
  'pyright',
  'gopls',
  'emmet_ls',
  'ansiblels',
  'jsonls',
  'dockerls',
  'sqlls',
  'terraformls',
  'yamlls',
  'bashls',
  'tsserver',
  'docker_compose_language_service',
}

return M
