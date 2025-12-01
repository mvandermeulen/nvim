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
  'lua_ls',
  'basedpyright',
  'gopls',
  'terraformls',
  'yamlls',
  'jsonls',
  'bashls',
}

return M
