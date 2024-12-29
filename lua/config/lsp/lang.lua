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
  "prettier",
  "prettierd",
  "markdownlint",
  "markdown-toc",
  "black",
  "sql-formatter",
  "eslint_d",
  'debugpy',
  "vim"
}

M.servers = {
  'lua_ls',
  'pyright',
  'gopls',
  -- 'ansiblels',
  'terraformls',
  'yamlls',
  'jsonls',
  -- 'sqlls',
  'bashls',
  -- 'dockerls',
  -- 'docker_compose_language_service',
  -- 'vimls',
  -- 'emmet_ls',
  -- "vtsls",
  "marksman",
  -- "lua-language-server",
  -- python
  -- 'basedpyright',
  -- 'ruff',
  -- go
  -- devops
  -- sql
  -- shell & bash
  -- "bash-language-server",
  -- docker
  -- frontend
  -- 'vscode-css-language-server',
  -- 'vscode-html-language-server',
  -- 'vscode-json-language-server',
  -- "html",
  -- "cssls",
  -- "tailwindcss-language-server",
  -- markdown
  -- 'kulala_ls',
}

return M
