--[[
-- Scissors Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-08-28
--]]


vim.keymap.set("n", "<leader>Se", function() require("scissors").editSnippet() end)

-- when used in visual mode, prefills the selection as snippet body
vim.keymap.set({ "n", "x" }, "<leader>Sa", function() require("scissors").addNewSnippet() end)

