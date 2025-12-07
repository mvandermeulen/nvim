--[[
-- LSP Languages
-- Author: Mark van der Meulen
-- Updated: 13-02-2023
--]]

local M = {}

M.parsers = {
  "stylua",
  "prettier",
  "prettier",
  "prettierd",
  "markdownlint",
  "markdown-toc",
  "black",
  "sql-formatter",
  "eslint_d",
  'debugpy',
}

M.servers = {
  'basedpyright',
  'lua_ls',
  'gopls',
  'yamlls',
  'jsonls',
  'bashls',
}

return M
