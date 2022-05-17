--[[
-- Neovim Options
--
-- Author: Mark van der Meulen
-- Updated: 24-04-2022
--]]

vim.cmd [[au BufWinEnter * set formatoptions-=cro]]
vim.cmd 'set inccommand=split'
vim.opt.completeopt = 'menuone,noselect' -- Autocomplete options
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.completeopt = { 'menuone', 'noinsert', 'noselect' } -- Completion options (for deoplete)
-----------------------------------------------------------
-- Startup
-----------------------------------------------------------

-- Disable builtins plugins
local disabled_built_ins = {
  'netrw',
  'netrwPlugin',
  'netrwSettings',
  'netrwFileHandlers',
  'gzip',
  'zip',
  'zipPlugin',
  'tar',
  'tarPlugin',
  'getscript',
  'getscriptPlugin',
  'vimball',
  'vimballPlugin',
  '2html_plugin',
  'logipat',
  'rrhelper',
  'spellfile_plugin',
  'matchit',
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g['loaded_' .. plugin] = 1
end

vim.o.breakindent = true
vim.o.signcolumn = 'auto:2-5'
vim.o.switchbuf = 'usetab,newtab'
vim.o.sessionoptions = 'globals,blank,buffers,curdir,folds,help,tabpages,winsize'
vim.o.eadirection = 'hor'
vim.o.showtabline = 2
vim.o.tabline = "%!luaeval('require[[user.tabline]].tabline()')"

-- Notify with nvim-notify if nvim is focused,
-- otherwise send a desktop notification.
vim.g.nvim_focused = true
vim.notify = fn.require_on_exported_call('user.notify').notify

vim.g.python_host_prog = '/usr/bin/python2'
vim.g.python3_host_prog = vim.env.HOME .. '/.asdf/shims/python3'
vim.g.node_host_prog = vim.env.XDG_DATA_HOME .. '/yarn/global/node_modules/neovim/bin/cli.js'
vim.g.ruby_host_prog = '/usr/bin/ruby'

---- Builtin plugins
vim.g.loaded_matchparen = 1
