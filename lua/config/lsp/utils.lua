--[[
-- LSP Utils
-- Author: Mark van der Meulen
-- Updated: 13-02-2023
--]]

local M = {}
local cmd = vim.cmd
local fs_status, fs = pcall(require, 'helpers.fs')
local util_status, utils = pcall(require, 'helpers.utils')

M.hs_version = vim.fn.system('hs -c _VERSION'):gsub('[\n\r]', '')
M.hs_path = vim.split(vim.fn.system('hs -c package.path'):gsub('[\n\r]', ''), ';')

function M.get_python_path(workspace)
  -- Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then
    return fs.path_join(vim.env.VIRTUAL_ENV, 'bin', 'python3')
  end
  local venv = utils.add_venv_to_path(workspace)
  if venv ~= nil then
    return fs.path_join(venv, 'bin', 'python3')
  end
  -- Find and use virtualenv in workspace directory.
  for _, pattern in ipairs { '*', '.*' } do
    local match = vim.fn.glob(fs.path_join(workspace, pattern, 'pyvenv.cfg'))
    if match ~= '' then
      return fs.path_join(fs.dirname(match), 'bin', 'python3')
    end
  end
  -- Fallback to system Python.
  return vim.fn.exepath 'python3' or vim.fn.exepath 'python' or 'python'
end


return M
