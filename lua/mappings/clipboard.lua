local M = {}

M.mappings = {
    name = ' Clipboard',
    s = { '<cmd>lua require("neoclip").start()', 'Start Clipboard Recording' },
    p = { '<cmd>lua require("neoclip").pause()', 'Pause Clipboard Recording' },
    t = { '<cmd>lua require("neoclip").toggle()', 'Toggle Clipboard Recording' },
    -- t = { '<cmd>lua require("neoclip").toggle()', 'Toggle Clipboard Recording' },
}

--[[ M.options = { ]]
--[[   mode = "n", ]]
--[[   silent = true, ]]
--[[   noremap = true, ]]
--[[   prefix = "<leader><leader>", ]]
--[[   nowait = false, ]]
--[[ } ]]

return M
