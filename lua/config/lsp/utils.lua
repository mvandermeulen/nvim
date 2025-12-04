--[[
-- LSP Utils
-- Author: Mark van der Meulen
-- Updated: 2025-12-01
--]]

local log = require('plenary.log').new({ plugin = 'mason', level = 'debug', use_console = true })
local function mylog(msg, level)
  local level = level or 'debug'
  log.debug(msg)
  if level == 'info' or level == 'warn' or level == 'error' then
    vim.notify(msg, vim.log.levels.INFO, { title = 'Mason' })
  end
end

local M = {}

local fs_status, fs = pcall(require, 'helpers.utils.fs')
local util_status, utils = pcall(require, 'helpers.utils')
local root_pattern = require('lspconfig.util').root_pattern
local path_status, Path = pcall(require, 'helpers.utils.path')


local system_name = vim.loop.os_uname().sysname
local hostname = vim.env.HOST
if hostname ~= 'devbox' and system_name ~= 'Linux' then
  M.hs_version = vim.fn.system('hs -c _VERSION'):gsub('[\n\r]', '')
  M.hs_path = vim.split(vim.fn.system('hs -c package.path'):gsub('[\n\r]', ''), ';')
end


if not fs_status then
  mylog('Error loading helper: fs', 'error')
  -- print('Error loading helper: fs')
  -- vim.notify('Error loading helpers: fs', vim.log.levels.ERROR)
  return M
end

if not util_status then
  mylog('Error loading helper: utils', 'error')
  -- print('Error loading helper: utils')
  -- vim.notify('Error loading helpers: utils', vim.log.levels.ERROR)
  return M
end

if not path_status then
  mylog('Error loading helper: path', 'error')
  -- print('Error loading helper: path')
  -- vim.notify('Error loading helpers: path', vim.log.levels.ERROR)
  return M
end

-- mylog('Loaded helpers', 'info')

M.root_files = {
  '.git',
  '.gitignore',
  '.python-version',
  'setup.cfg',
  'requirements.txt',
  'pyproject.toml',
  '.venv',
  'venv',
  'uv.lock',
  'setup.py',
  'Pipfile',
  'ruff.toml',
  '.ruff.toml',
  '.activate',
  'package.json',
}

M.ignore_diagnostic_message = {
  '"self" is not accessed',
  '"args" is not accessed',
  '"kwargs" is not accessed',
  '"cls" is not accessed',
}

M.basepath_conda = nil
M.basepath_conda_venv = nil
if vim.env.CONDA_EXE then
  -- M.basepath_conda = vim.fn.fnamemodify(vim.env.CONDA_EXE, ':h:h')
  M.basepath_conda = Path:new(vim.env.CONDA_EXE):parent():parent()
  M.basepath_conda_venv = fs.path_join(M.basepath_conda, 'envs')
end




function M.get_python_path(workspace)
  mylog('Getting Python path for workspace: ' .. workspace, 'debug')
  -- Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then
    mylog('Using activated virtualenv: ' .. vim.env.VIRTUAL_ENV, 'debug')
    return fs.path_join(vim.env.VIRTUAL_ENV, 'bin', 'python3')
  end
  local venv = utils.add_venv_to_path(workspace)
  mylog('Using venv from workspace: ' .. tostring(venv), 'debug')
  if venv ~= nil then
    mylog('Using venv: ' .. venv, 'debug')
    return fs.path_join(venv, 'bin', 'python3')
  end
  -- Find and use virtualenv in workspace directory.
  for _, pattern in ipairs { '*', '.*' } do
    local match = vim.fn.glob(fs.path_join(workspace, pattern, 'uv.lock'))
    if match ~= '' then
      mylog('Using found virtualenv: ' .. match, 'debug')
      return fs.path_join(fs.dirname(match), 'bin', 'python3')
    end
  end
  mylog('Falling back to system Python', 'debug')
  -- Fallback to system Python.
  return vim.fn.exepath 'python3' or vim.fn.exepath 'python' or 'python'
end

M.filter_publish_diagnostics = function(a, params, client_info, extra_message, config)
  ---@diagnostic disable-next-line: unused-local
  local client = vim.lsp.get_client_by_id(client_info.client_id)

  if extra_message.ignore_diagnostic_message then
    local new_index = 1

    for _, diagnostic in ipairs(params.diagnostics) do
      if not vim.tbl_contains(extra_message.ignore_diagnostic_message, diagnostic.message) then
        params.diagnostics[new_index] = diagnostic
        new_index = new_index + 1
      end
    end

    for i = new_index, #params.diagnostics do
      params.diagnostics[i] = nil
    end
  end

  ---@diagnostic disable-next-line: redundant-parameter
  vim.lsp.diagnostic.on_publish_diagnostics(a, params, client_info, extra_message, config)
end


local find_python_cmd = utils.my_cache_fn(function(workspace, cmd)
  -- https://github.com/neovim/nvim-lspconfig/issues/500#issuecomment-851247107

  -- If conda env is activated, use it
  if vim.env.CONDA_PREFIX and vim.env.CONDA_PREFIX ~= M.basepath_conda.filename then
    return Path:new(vim.env.CONDA_PREFIX):join("bin"):join(cmd):absolute()
    -- return fs.abspath(fs.path_join(vim.env.CONDA_PREFIX, 'bin', cmd))
  end

  -- If virtualenv is activated, use it
  if vim.env.VIRTUAL_ENV then
    return Path:new(vim.env.VIRTUAL_ENV):join("bin"):join(cmd):absolute()
    -- return fs.abspath(fs.path_join(vim.env.VIRTUAL_ENV, 'bin', cmd))
  end

  -- If .venv directory, use it
  -- local workspace_venv_cmdpath = Path:new(workspace):join(".venv/bin"):join(cmd)
  local workspace_dot_venv_cmdpath = fs.path_join(workspace, '.venv', 'bin', cmd)
  -- if workspace_venv_cmdpath:exists() then
  if fs.exists(workspace_dot_venv_cmdpath) then
    -- return workspace_venv_cmdpath:absolute()
    return fs.abspath(workspace_dot_venv_cmdpath)
  end

  local workspace_venv_cmdpath = fs.path_join(workspace, 'venv', 'bin', cmd)
  if fs.exists(workspace_venv_cmdpath) then
    return fs.abspath(workspace_venv_cmdpath)
  end

  -- If .venv directory, use it
  -- local workspace_venv_cmdpath = Path:new(workspace):join("venv/bin"):join(cmd)
  -- if workspace_venv_cmdpath:exists() then
  --   return workspace_venv_cmdpath:absolute()
  -- end

  -- If a conda env exists with `almost` the same name as the workspace, use it
  -- local workspace_name = utils.to_workspace_name(workspace)
  -- if workspace and workspace_name then
  --   -- Check for any conda env named like the project
  --   if M.basepath_conda_venv then
  --     local conda_venv_path = M.basepath_conda_venv:glob(workspace_name)
  --     if #conda_venv_path > 0 then
  --       return conda_venv_path[1]:join("bin", cmd):absolute()
  --     end
  --   end

  --   -- Check for any virtualenv named like the project
  -- end

  -- Fallback to system Python.
  return cmd
end)

M.wax_get_python_path = utils.my_cache_fn(function(workspace, cmd)
  workspace = workspace or utils.find_workspace_name(vim.api.nvim_buf_get_name(0))
  cmd = cmd or "python"

  if workspace == nil then
    return cmd
  end

  local python_path = nil

  local function pattern_to_python_path(pattern)
    -- return Path:new(workspace):find_root_dir({ pattern }):join("bin", cmd):absolute()
    return fs.abspath(fs.path_join(root_pattern({ pattern })(workspace), 'bin', cmd))
  end

  if M.basepath_conda_venv and string.find(workspace, M.basepath_conda_venv) then
    -- In case of jump to definition inside dependency with conda venv:
    python_path = pattern_to_python_path("conda-meta")
  else
    python_path = find_python_cmd(workspace, cmd)
  end

  return python_path
end)


-- mylog('Loaded LSP Utils', 'info')

return M
