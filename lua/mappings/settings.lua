local M = {}

local ui_mappings = {
    name = ' UI',
    b = { '<cmd>:Gitsigns toggle_current_line_blame<cr>', ' Toggle Blame' },
    l = { '<cmd>:Gitsigns toggle_linehl<cr>', ' Toggle modified line highlighting' },
    s = { '<cmd>:Gitsigns toggle_signs<cr>', ' Toggle Git Signs' },
}


M.mappings = {
    name = ' Settings',
    --[[ a = { '<cmd>lua require("neoclip").start()', '' }, ]]
    --[[ b = { '<cmd>lua require("neoclip").pause()', '' }, ]]
    u = ui_mappings,
}

--[[ M.options = { ]]
--[[   mode = "n", ]]
--[[   silent = true, ]]
--[[   noremap = true, ]]
--[[   prefix = "<leader><leader>", ]]
--[[   nowait = false, ]]
--[[ } ]]

return M
