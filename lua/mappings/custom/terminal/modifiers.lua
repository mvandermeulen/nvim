--[[
-- Mappings: Terminal - Modifiers
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-25
--]]



-- Navigation from terminal
-- vim.keymap.set("t", "<C-esc>", [[<C-\><C-n>]], opts)
vim.keymap.set("t", "<M-h>", [[<C-\><C-n><C-w>h]], opts)
vim.keymap.set("t", "<M-j>", [[<C-\><C-n><C-w>j]], opts)
vim.keymap.set("t", "<M-k>", [[<C-\><C-n><C-w>k]], opts)
vim.keymap.set("t", "<M-l>", [[<C-\><C-n><C-w>l]], opts)


