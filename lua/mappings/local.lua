--[[
-- Local Leader Mappings
--
-- Author: Mark van der Meulen
-- Updated: 01-06-2022
--]]

-----------------------------------------------
-- Helpers
-----------------------------------------------

default_options = { noremap = true, silent = true }
expr_options = { noremap = true, expr = true, silent = true }

-- Function for make mapping easier.
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end


-----------------------------------------------
-- Set Local Leader Key
-----------------------------------------------

--vim.g.maplocalleader = "\\"
vim.g.maplocalleader = ","


-----------------------------------------------
-- Mappings: NORMAL Mode
-----------------------------------------------

map("n", "<localleader>1", "1gt", default_options)
map("n", "<localleader>2", "2gt", default_options)
map("n", "<localleader>3", "3gt", default_options)
map("n", "<localleader>4", "4gt", default_options)
map("n", "<localleader>5", "5gt", default_options)
map("n", "<localleader>6", "6gt", default_options)
map("n", "<localleader>7", "7gt", default_options)
map("n", "<localleader>8", "8gt", default_options)
map("n", "<localleader>9", "9gt", default_options)
map("n", "<localleader>pp", ":set paste<CR>", default_options)
map("n", "<localleader>po", ":set nopaste<CR>", default_options)



-----------------------------------------------
-- Mappings: INSERT Mode
-----------------------------------------------

