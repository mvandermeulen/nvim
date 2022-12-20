local o = vim.o -- For the globals options
local g = vim.g -- For the globals options
local wo = vim.wo -- For the window local options
local bo = vim.bo -- For the buffer local options

local configuration_folder = vim.fn.expand("~") .. "/.config/nvim"

-- ====================
-- Editor
-- ====================

----------
-- Colours
----------
-- True colour support
o.termguicolors = true
---------------------
-- File
---------------------
-- Do not write backups
o.backup = false
o.writebackup = false
-- Do not create swap files
o.swapfile = false
-- Opt-in to filetype.lua
-- https://www.reddit.com/r/neovim/comments/rvwsl3/introducing_filetypelua_and_a_call_for_help/
g.do_filetype_lua = true
g.did_load_filetypes = true
-------------------------
-- Encoding
-------------------------
o.encoding = "utf-8"
------------
-- Clipboard
------------
o.clipboard = "unnamed"
-----------------------
-- Format
-----------------------
o.formatoptions = "qj"
------------------------------
-- Spellchecking
------------------------------
o.spelllang = "en"
-------------------
-- Undo persistance
-------------------
o.undodir = configuration_folder .. "/undodir.nvim"
o.undofile = true
o.undolevels = 10000
--------
-- Shell
--------
-- For fish users out there, its quite slow compared to stock bash, as such
-- tell Neovim to use bash to execute commands
vim.opt.shell = "/bin/bash"
-----------
-- Commands
-----------
o.inccommand = "nosplit"
-----------------------------
-- Local per machine settings
-----------------------------
local f = io.open("~/.config/nvim/local.vim", "r")

if f ~= nil then
	io.close(f)
	vim.cmd([[ source ~/.config/nvim/local.vim ]])
end
--------
-- Folds
--------
o.foldexpr = "nvim_treesitter#foldexpr()"
wo.foldmethod = "expr"
----------------
-- Miscellaneous
----------------
vim.cmd([[ nmap <F3> i<C-R>=strftime("%Y-%m-%d")<CR><Esc> ]])
vim.cmd([[ imap <F3> <C-R>=strftime("%Y-%m-%d")<CR> ]])
