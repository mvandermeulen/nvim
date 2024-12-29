--[[
-- Local Leader Mappings
--
-- Author: Mark van der Meulen
-- Updated: 01-06-2022
--]]

-----------------------------------------------
-- Helpers
-----------------------------------------------

expr_options = { noremap = true, expr = true, silent = true }


local function dfo(desc)
  if desc then
    return { noremap = true, silent = true, desc = desc }
  else
    return { noremap = true, silent = true }
  end
end

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

map("n", "<localleader>1", "1gt", dfo('Tab 1'))
map("n", "<localleader>2", "2gt", dfo('Tab 2'))
map("n", "<localleader>3", "3gt", dfo('Tab 3'))
map("n", "<localleader>4", "4gt", dfo('Tab 4'))
map("n", "<localleader>5", "5gt", dfo('Tab 5'))
map("n", "<localleader>6", "6gt", dfo('Tab 6'))
map("n", "<localleader>7", "7gt", dfo('Tab 7'))
map("n", "<localleader>8", "8gt", dfo('Tab 8'))
map("n", "<localleader>9", "9gt", dfo('Tab 9'))
map("n", "<localleader>pp", ":set paste<CR>", dfo('Paste Mode'))
map("n", "<localleader>po", ":set nopaste<CR>", dfo('Paste Mode Off'))



-----------------------------------------------
-- Mappings: INSERT Mode
-----------------------------------------------

