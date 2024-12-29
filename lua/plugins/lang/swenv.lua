--[[
-- Swenv Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-23
--]]

-- Environment switcher
-- Change this to include your own python environments
local M = {}

M.custom_python_envs = {
    { base_path = vim.fn.expand("~/.venvs"), source = "venvs", },
}

-- Wrapper to get environment from a base path
M.get_venvs_wrapper = function(base_path, source, opts)
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

return M
