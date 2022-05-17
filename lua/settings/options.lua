-- Global
local fn = vim.fn

-- Indentation
vim.opt.tabstop = 2 -- Number of spaces tabs count for
vim.opt.softtabstop = 2 -- 2 spaces inserted for <tab> when editing a file, also # removed by backspace
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 2 -- Shift 2 spaces when tab
vim.opt.shiftround = true -- Round indent
--vim.opt.autoindent = true                          --
--vim.opt.smartindent = true                          -- Insert indents automatically
vim.opt.cindent = true

-- Undo
vim.opt.undolevels = 1000
vim.opt.undofile = true -- enable/disable undo file creation
vim.opt.undodir = fn.stdpath("data") .. "/undodir" -- set undo directory

-- Swap
vim.opt.swapfile = false -- enable/disable swap file creation
vim.opt.dir = fn.stdpath("data") .. "/swp" -- swap file directory

-- Backup
vim.opt.backup = false -- creates a backup file
vim.opt.backupcopy = "yes"
vim.opt.writebackup = false

-- Encoding
vim.opt.fileformat = "unix"
vim.opt.fileencoding = "utf-8" -- the encoding written to a file
vim.opt.encoding = "utf-8"

-- Input
vim.opt.mouse = "a" -- Enable mouse in all modes.
vim.opt.mousehide = true -- Hide the mouse cursor while typing

-- Timeouts
vim.opt.updatetime = 300 -- faster completion
vim.opt.timeoutlen = 400 -- time to wait for a mapped sequence to complete (in milliseconds)
vim.opt.ttimeoutlen = 0 -- Time in milliseconds to wait for a key code sequence to complete
vim.g.cursorhold_updatetime = 100 -- Decrease time of completion menu.

-- Search
vim.opt.showmatch = true -- Highlight matching parenthesis
vim.opt.matchtime = 2 -- how long to jump to matching parenthesis for
vim.opt.incsearch = true -- Shows the match while typing
vim.opt.hlsearch = true -- Highlight found searches
vim.opt.ignorecase = true -- ignore case in search patterns
vim.opt.smartcase = true -- Do not ignore case with capitals
vim.opt.wrapscan = true -- Searches wrap around the end of the file
vim.opt.gdefault = true -- Add the g flag to search/replace by default
vim.opt.grepprg = "rg --hidden --vimgrep --smart-case --" -- use rg instead of grep
vim.opt.inccommand = "nosplit" -- interactive feedback as we compose our substitute command

-- Clipboard
vim.opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard

-- General
vim.opt.history = 500 -- Use the 'history' option to set the number of lines from command mode that are remembered.
vim.opt.hidden = true -- Enable background buffers
vim.opt.autoread = true
-- vim.opt.fillchars = { vert = ' ' }
vim.opt.shortmess:append("sI") -- Disable nvim intro
--vim.opt.shortmess:append { c = true, S = true }
--vim.opt.shortmess = o.shortmess + "c"               -- prevent "pattern not found" messages
vim.opt.errorbells = false
vim.opt.visualbell = false
vim.opt.title = true
vim.opt.titlestring = "%{join(split(getcwd(), '/')[-2:], '/')}"
vim.opt.shada = { "!", "'500", "<500", "s10", "h" }
--vim.opt.startofline = false

vim.opt.pastetoggle = "<F2>"
