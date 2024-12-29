--[[
-- Navigator Plugin
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]

require("Navigator").setup({
  auto_save = nil,
  -- disable_on_zoom = false,
})

default_options = {noremap = true, silent = true}
-- tmux navigation
vim.api.nvim_set_keymap("n", "<C-h>", "<cmd>lua require('Navigator').left()<CR>", default_options)
vim.api.nvim_set_keymap("n", "<C-k>", "<cmd>lua require('Navigator').up()<CR>", default_options)
vim.api.nvim_set_keymap("n", "<C-l>", "<cmd>lua require('Navigator').right()<CR>", default_options)
vim.api.nvim_set_keymap("n", "<C-j>", "<cmd>lua require('Navigator').down()<CR>", default_options)
vim.api.nvim_set_keymap("n", "<C-;>", "<cmd>lua require('Navigator').previous()<CR>", default_options)
