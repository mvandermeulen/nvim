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
  'bashls',
  'cssls',
  --[[ "tailwindcss", ]]
  'dockerls',
  'emmet_ls',
  'gopls',
  'html',
  'jsonls',
  'pyright',
  'sqlls',
  'lua_ls',
  --[[ 'svelte-language-server', ]]
  'terraformls',
  'tsserver',
  'yamlls',
  --[[ 'yaml-language-server', ]]
  'jsonls',
}

return M
