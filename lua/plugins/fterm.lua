--[[
-- FTerm Plugin
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]
local fterm_opts = { border = 'single', dimensions = { height = 0.7, width = 0.7 } }
require('FTerm').setup(fterm_opts)

-- Example keybindings
vim.keymap.set('n', '<A-i>', '<CMD>lua require("FTerm").toggle()<cr>')
vim.keymap.set('t', '<A-i>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')

-- or create a vim command
--vim.api.nvim_add_user_command('FTermOpen', require('FTerm').open, { bang = true })
-- This will close the terminal window but preserves the actual terminal session
--vim.api.nvim_add_user_command('FTermClose', require('FTerm').close, { bang = true })
-- Unlike closing, this will remove the terminal session
--vim.api.nvim_add_user_command('FTermExit', require('FTerm').exit, { bang = true })
-- Toggling the terminal
--vim.api.nvim_add_user_command('FTermToggle', require('FTerm').toggle, { bang = true })

-- See more configuration options here: https://github.com/numToStr/FTerm.nvim
