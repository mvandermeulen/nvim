local M = {}

M.mappings = {
    name = '󰣆 Applications',
    --[[ a = { '<cmd>lua require("neoclip").start()', '' }, ]]
    --[[ b = { '<cmd>lua require("neoclip").pause()', '' }, ]]
    u = { '<cmd>lua require("undotree").toggle()<cr>', ' Undotree' },
}

--[[ M.options = { ]]
--[[   mode = "n", ]]
--[[   silent = true, ]]
--[[   noremap = true, ]]
--[[   prefix = "<leader><leader>", ]]
--[[   nowait = false, ]]
--[[ } ]]

return M

