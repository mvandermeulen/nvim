--[[
-- LSP Languages
-- Author: Mark van der Meulen
-- Updated: 13-02-2023
--]]

local M = {}

M.parsers = {
  "bash",
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
  "stylua",
  "prettier",
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
  'docker_compose_language_service',
  'vimls',
}

return M
