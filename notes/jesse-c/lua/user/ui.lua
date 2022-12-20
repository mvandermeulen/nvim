---------------
-- Line numbers
---------------
vim.o.number = true
vim.wo.relativenumber = true
----------------------
-- Syntax highlighting
----------------------
vim.cmd([[ filetype plugin indent on ]])
vim.cmd([[ syntax enable ]])
vim.g.indent_blankline_enabled = true
vim.g.indent_blankline_char = "┆"
vim.g.indent_blankline_char_list = { "|", "¦", "┆", "┊" }
vim.g.indent_blankline_use_treesitter = true
vim.g.indent_blankline_show_first_indent_level = false
----------------------
-- Splits
----------------------
vim.api.nvim_create_autocmd("VimResized", {
	pattern = "*",
	callback = function(_args)
		vim.cmd([[ wincmd = ]])
	end,
	desc = "Auto resize splits when window is resized",
})
vim.o.splitbelow = true
vim.o.splitright = true
vim.api.nvim_set_keymap("n", "<C-X>", "<cmd>split<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-V>", "<cmd>vsplit<cr>", { silent = true, noremap = true })
------------
-- Scrolling
------------
vim.o.scrolloff = 4
-----------------------------
-- Current line
-----------------------------
vim.o.ruler = true
vim.o.cursorline = true
------------------------
-- Conceal
------------------------
vim.o.concealcursor = ""
-----------------------
-- Status
-----------------------
vim.o.showmode = true
vim.o.laststatus = 3
------------------------------
-- Column marker
------------------------------
-- Using lukas-reineke/virt-column.nvim instead
-- o.colorcolumn = "81"
---------------------------
-- Characters
---------------------------
-- Show whitespace characters
vim.o.list = true
-- Show trailing whitespace as dots
vim.o.listchars = "trail:·,tab:→ ,nbsp:·"
----------------------------
-- Sign column
----------------------------
-- Always show sign column
vim.wo.signcolumn = "yes"
----------------------
-- Folds
----------------------
vim.o.foldlevelstart = 99
----------------------------
-- Indentation
----------------------------
-- Use spaces instead of tabs
vim.o.expandtab = true
-- More intelligent tabulation
vim.o.smarttab = true
-- Number of spaces that a <Tab> counts for
vim.o.tabstop = 2
-- Number of spaces used for autoindent
vim.o.shiftwidth = vim.o.tabstop
-- Number of spaces that a <Tab> counts for
vim.o.softtabstop = vim.o.tabstop
-- Copy indent from current line when starting a new line
vim.o.autoindent = true
-- Do smart autoindenting when starting a new line
vim.o.smartindent = true
-------------------------
-- Wrapping
-------------------------
-- Enable soft-wrapping
vim.o.wrap = true
-- Do not break words at the middle
vim.o.linebreak = true
-- Mantain indentation on wrap
vim.o.breakindent = true
-- Add characters after wrap
vim.o.breakindentopt = "shift:2"
-- Character to show after wrap
vim.o.showbreak = "↳ "
----------
-- Tabline
----------
vim.o.showtabline = 2
vim.o.title = true
--------
-- Bells
--------
vim.o.errorbells = false
vim.o.visualbell = false
------------
-- Rendering
------------
-- When running macros and regexes on a large file, lazy redraw tells Neovim
-- not to draw the screen, which greatly speeds it up, upto 6-7x faster
vim.o.lazyredraw = true

vim.g.rainbow_active = true
