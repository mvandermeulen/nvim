--[[
-- LSP Languages
-- Author: Mark van der Meulen
-- Updated: 13-02-2023
--]]

local M = {}

M.parsers = {
  -- "bash",
  -- "css",
  -- "scss",
  -- "dockerfile",
  -- "gitignore",
  -- "html",
  -- "json",
  -- "markdown",
  -- "python",
  -- "sql",
  -- "lua",
  "stylua",
  "prettier",
  -- "javascript",
  -- "typescript",
  -- "tsx",
  -- "yaml",
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
  -- 'pyright',
  'basedpyright',
  'gopls',
  'terraformls',
  'yamlls',
  'jsonls',
  'bashls',
}

return M
