local options = {
	-- NeoVim/Vim options
	clipboard = "unnamedplus",
	cmdheight = 1,
	ruler = false,
	ignorecase = true,
	smartcase = true,
	mouse = "a",
	number = true,
	-- relative numbers in normal mode tool at the bottom of options.lua
	numberwidth = 2,
	relativenumber = true,
	expandtab = true,
	shiftwidth = 2,
	smartindent = true,
	tabstop = 2, -- Number of spaces that a <Tab> in the file counts for
	timeoutlen = 400,
	-- interval for writing swap file to disk, also used by gitsigns
	updatetime = 250,
	undofile = true, -- keep a permanent undo (across restarts)

	swapfile = false, -- creates a swapfile
	conceallevel = 0, -- so that `` is visible in markdown files
	fileencoding = "utf-8", -- the encoding written to a file
	hidden = true, -- required to keep multiple buffers and open multiple buffers
	-- fold
	foldmethod = "indent",
	foldlevel = 99,
	foldenable = true,
	autoindent = true,

	termguicolors = true,
	signcolumn = "yes",
	splitright = true,
	splitbelow = true,
  wrap = false,

  -- global status(neovim 0.7.0)
  laststatus = 3  -- 2 for original
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

-- disable nvim intro
vim.opt.shortmess:append("sI")
-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
-- vim.opt.whichwrap:append "<>[]hl"
