--[[
-- LSP Utils
-- Author: Mark van der Meulen
-- Updated: 13-02-2023
--]]

local M = {}
local util = require 'lspconfig/util'

M.capabilities = require("cmp_nvim_lsp").default_capabilities()
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.hs_version = vim.fn.system('hs -c _VERSION'):gsub('[\n\r]', '')
M.hs_path = vim.split(vim.fn.system('hs -c package.path'):gsub('[\n\r]', ''), ';')

function M.get_python_path(workspace)
  -- Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then
    return util.path.join(vim.env.VIRTUAL_ENV, 'bin', 'python3')
  end
  -- Find and use virtualenv in workspace directory.
  for _, pattern in ipairs { '*', '.*' } do
    local match = vim.fn.glob(util.path.join(workspace, pattern, 'pyvenv.cfg'))
    if match ~= '' then
      return util.path.join(util.path.dirname(match), 'bin', 'python3')
    end
  end
  -- Fallback to system Python.
  return vim.fn.exepath 'python3' or vim.fn.exepath 'python' or 'python'
end





return M

