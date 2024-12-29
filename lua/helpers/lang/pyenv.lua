--[[
-- Helpers: Pyenv
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-23
--]]


local M = {}

-- Environment switcher
-- Change this to include your own python environments
local custom_python_envs = {
    { base_path = vim.fn.expand("~/.venvs"), source = "venvs", },
}

-- Wrapper to get environment from a base path
local get_venvs_wrapper = function(base_path, source, opts)
    local venvs = {}
    if base_path == nil then
        return venvs
    end
    local paths = require("plenary.scandir").scan_dir(
        base_path,
        vim.tbl_extend(
            "force",
            { depth = 1, only_dirs = true, silent = true },
            opts or {}
        )
    )
    for _, path in ipairs(paths) do
        table.insert(venvs, {
            name = require("plenary.path"):new(path):make_relative(base_path),
            path = path,
            source = source,
        })
    end
    return venvs
end



function M.get_current_venv(notify)
  -- local repo = vim.fn.input "Repository name / URI: "
  local current_venv = require('swenv.api').get_current_venv()
  if notify then
    vim.notify("Current virtual environment: " .. current_venv)
  else
    print("Current virtual environment: " .. current_venv)
  end
end


function M.select_venv()
  require('swenv.api').pick_venv()
end

function M.set_venv(venv)
  if venv then
    require('swenv.api').set_venv(venv)
  else
    require('swenv.api').set_venv('venv_fuzzy_name')
  end
end

return M

