local opt = vim.opt
local g = vim.g
local fn = vim.fn

-- Leaders
g.mapleader = ' '
g.maplocalleader = ','

-----------------------------------------------------------------------------//
-- Message output on vim actions {{{1
-----------------------------------------------------------------------------//
opt.shortmess = {
  t = true, -- truncate file messages at start
  A = true, -- ignore annoying swap file messages
  o = true, -- file-read message overwrites previous
  O = true, -- file-read message overwrites previous
  T = true, -- truncate non-file messages in middle
  f = true, -- (file x of x) instead of just (x of x
  F = true, -- Don't give file info when editing a file, NOTE: this breaks autocommand messages
  s = true,
  c = true,
  W = true, -- Don't show [w] or written when writing
  I = true, -- Disable Nvim Intro
}

-----------------------------------------------------------------------------//
-- Timings {{{1
-----------------------------------------------------------------------------//
opt.updatetime = 300
opt.timeout = true
opt.timeoutlen = 500
opt.ttimeoutlen = 10

-----------------------------------------------------------------------------//
-- Window splitting and buffers {{{1
-----------------------------------------------------------------------------//
--- NOTE: remove this once 0.6 lands as it is now default
opt.splitbelow = true
opt.splitright = true
opt.eadirection = 'hor'
-- exclude usetab as we do not want to jump to buffers in already open tabs
-- do not use split or vsplit to ensure we don't open any new windows
vim.o.switchbuf = 'useopen,uselast'
opt.fillchars = {
  vert = '▕', -- alternatives │
  fold = ' ',
  eob = ' ', -- suppress ~ at EndOfBuffer
  diff = '╱', -- alternatives = ⣿ ░ ─
  msgsep = '‾',
  foldopen = '▾',
  foldsep = '│',
  foldclose = '▸',
}

-----------------------------------------------------------------------------//
-- Diff {{{1
-----------------------------------------------------------------------------//
-- Use in vertical diff mode, blank lines to keep sides aligned, Ignore whitespace changes
opt.diffopt = opt.diffopt
  + {
    'vertical',
    'iwhite',
    'hiddenoff',
    'foldcolumn:0',
    'context:4',
    'algorithm:histogram',
    'indent-heuristic',
  }

-----------------------------------------------------------------------------//
-- Format Options {{{1
-----------------------------------------------------------------------------//
opt.formatoptions = {
  ['1'] = true,
  ['2'] = true, -- Use indent from 2nd line of a paragraph
  q = true, -- continue comments with gq"
  c = true, -- Auto-wrap comments using textwidth
  r = true, -- Continue comments when pressing Enter
  n = true, -- Recognize numbered lists
  t = false, -- autowrap lines using text width value
  j = true, -- remove a comment leader when joining lines.
  -- Only break if the line was not longer than 'textwidth' when the insert
  -- started and only at a white character that has been entered during the
  -- current insert command.
  l = true,
  v = true,
}

-----------------------------------------------------------------------------//
-- Number {{{1
-----------------------------------------------------------------------------//
opt.number = true
opt.numberwidth = 2
opt.relativenumber = true

-----------------------------------------------------------------------------//
-- Folds {{{1
-----------------------------------------------------------------------------//
-- opt.foldtext = 'v:lua.G.folds()'
opt.foldopen = opt.foldopen + 'search'
opt.foldlevelstart = 99
opt.foldexpr = 'nvim_treesitter#foldexpr()'
-- opt.foldmethod = 'expr'
opt.foldmethod = 'indent'

-----------------------------------------------------------------------------//
-- Grepprg {{{1
-----------------------------------------------------------------------------//
-- Use faster grep alternatives if possible
if fn.executable 'rg' > 0 then
  vim.o.grepprg = [[rg --glob "!.git" --no-heading --vimgrep --follow $*]]
  opt.grepformat = opt.grepformat ^ { '%f:%l:%c:%m' }
elseif fn.executable 'ag' > 0 then
  vim.o.grepprg = [[ag --nogroup --nocolor --vimgrep]]
  opt.grepformat = opt.grepformat ^ { '%f:%l:%c:%m' }
end

-----------------------------------------------------------------------------//
-- Wild and file globbing stuff in command mode {{{1
-----------------------------------------------------------------------------//
opt.wildcharm = fn.char2nr(vim.api.nvim_replace_termcodes([[<Tab>]], true, true, true))
opt.wildmode = 'longest:full,full' -- Shows a menu bar as opposed to an enormous list
opt.wildignorecase = true -- Ignore case when completing file names and directories
-- Binary
opt.wildignore = {
  '*.aux',
  '*.out',
  '*.toc',
  '*.o',
  '*.obj',
  '*.dll',
  '*.jar',
  '*.pyc',
  '*.rbc',
  '*.class',
  '*.gif',
  '*.ico',
  '*.jpg',
  '*.jpeg',
  '*.png',
  '*.avi',
  '*.wav',
  -- Temp/System
  '*.*~',
  '*~ ',
  '*.swp',
  '.lock',
  '.DS_Store',
  'tags.lock',
}
opt.wildoptions = 'pum'
opt.pumblend = 3 -- Make popup window translucent

-----------------------------------------------------------------------------//
-- Display {{{1
-----------------------------------------------------------------------------//
opt.conceallevel = 2
opt.breakindentopt = 'sbr'
opt.linebreak = true -- lines wrap at words rather than random characters
opt.synmaxcol = 1024 -- don't syntax highlight long lines
-- FIXME: use 'auto:2-4' when the ability to set only a single lsp sign is restored
--@see: https://github.com/neovim/neovim/issues?q=set_signs
opt.signcolumn = 'yes:2'
opt.ruler = false
opt.cmdheight = 1 -- Set command line height to two lines
--- be set to a value that isn't equivalent to a vim filetype
vim.g.markdown_fenced_languages = {
  'js=javascript',
  'ts=typescript',
  'shell=sh',
  'bash=sh',
  'console=sh',
}

-----------------------------------------------------------------------------//
-- List chars {{{1
-----------------------------------------------------------------------------//
opt.list = true -- invisible chars
opt.listchars = {
  eol = nil,
  tab = '│ ',
  extends = '›', -- Alternatives: … »
  precedes = '‹', -- Alternatives: … «
  trail = '•', -- BULLET (U+2022, UTF-8: E2 80 A2)
}

-----------------------------------------------------------------------------//
-- Indentation
-----------------------------------------------------------------------------//
opt.wrap = false
opt.wrapmargin = 2
opt.textwidth = 80
opt.autoindent = true
opt.shiftround = true
opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true
opt.tabstop = 2
opt.softtabstop = -1
-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append '<>[]hl'

opt.joinspaces = false
opt.gdefault = true
opt.pumheight = 15
opt.confirm = true -- make vim prompt me to save before doing destructive things
opt.completeopt = { 'menuone', 'noselect' }
opt.hlsearch = true
opt.autowriteall = true -- automatically :write before running commands and changing files
opt.clipboard = { 'unnamedplus' }
opt.termguicolors = true
-- opt.guifont = 'Fira Code Regular Nerd Font Complete Mono:h14'

-----------------------------------------------------------------------------//
-- Emoji {{{1
-----------------------------------------------------------------------------//
-- emoji is true by default but makes (n)vim treat all emoji as double width
-- which breaks rendering so we turn this off.
-- CREDIT: https://www.youtube.com/watch?v=F91VWOelFNE
opt.emoji = false

-----------------------------------------------------------------------------//
-- Title {{{1
-----------------------------------------------------------------------------//
opt.titlestring = ' ❐ %t %r %m'
opt.titleold = fn.fnamemodify(vim.loop.os_getenv 'SHELL', ':t')
opt.title = true
opt.titlelen = 70

-----------------------------------------------------------------------------//
-- Utilities {{{1
-----------------------------------------------------------------------------//
g.did_load_filetypes = 0
opt.showmode = false
opt.sessionoptions = {
  'globals',
  'buffers',
  'curdir',
  'help',
  'winpos',
  -- "tabpages",
}
opt.viewoptions = { 'cursor', 'folds' } -- save/restore just these (with `:{mk,load}view`)
opt.virtualedit = 'block' -- allow cursor to move where there is no text in visual block mode

-------------------------------------------------------------------------------
-- BACKUP AND SWAPS {{{
-------------------------------------------------------------------------------
opt.backup = false
opt.writebackup = false
if fn.isdirectory(vim.o.undodir) == 0 then
  fn.mkdir(vim.o.undodir, 'p')
end
opt.undofile = true
opt.swapfile = false
-- The // at the end tells Vim to use the absolute path to the file to create the swap file.
-- This will ensure that swap file name is unique, so there are no collisions between files
-- with the same name from different directories.
opt.directory = fn.stdpath 'data' .. '/swap/'
if fn.isdirectory(vim.o.directory) == 0 then
  fn.mkdir(vim.o.directory, 'p')
end
--}}}

-----------------------------------------------------------------------------//
-- Match and search {{{1
-----------------------------------------------------------------------------//
opt.ignorecase = true
opt.smartcase = true
opt.wrapscan = true -- Searches wrap around the end of the file
opt.scrolloff = 9
opt.sidescrolloff = 10
opt.sidescroll = 1

-----------------------------------------------------------------------------//
-- Mouse {{{1
-----------------------------------------------------------------------------//
opt.mouse = 'a'
opt.mousefocus = true
-----------------------------------------------------------------------------//

--------------------------------------------------------------------------------
-- Statusline
--------------------------------------------------------------------------------
-- opt.laststatus = 0

--------------------------------------------------------------------------------
-- Session
--------------------------------------------------------------------------------
opt.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal'

-- Others {{{1
opt.cul = true -- cursor line

g.python3_host_prog = '/usr/local/bin/python3'
g.loaded_python_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0

-- disable some builtin vim plugins
local disabled_built_ins = {
  '2html_plugin',
  'getscript',
  'getscriptPlugin',
  'gzip',
  'logipat',
  'netrw',
  'netrwPlugin',
  'netrwSettings',
  'netrwFileHandlers',
  'matchit',
  'tar',
  'tarPlugin',
  'rrhelper',
  'spellfile_plugin',
  'vimball',
  'vimballPlugin',
  'zip',
  'zipPlugin',
}

for _, plugin in pairs(disabled_built_ins) do
  g['loaded_' .. plugin] = 1
end

