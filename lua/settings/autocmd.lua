--[[
-- Autocommand functions
--
-- Author: Mark van der Meulen
-- Updated: 24-04-2022
--]]

-- Define autocommands with Lua APIs
-- See: h:api-autocmd, h:augroup

local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand
local fn = vim.fn

-- Highlight on yank
augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  group = 'YankHighlight',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = '1000' })
  end
})

-- Don't auto comment new lines
autocmd('BufEnter', {
  pattern = '*',
  command = 'set fo-=c fo-=r fo-=o'
})

-- Disable line length marker
augroup('setLineLength', { clear = true })
autocmd('Filetype', {
  group = 'setLineLength',
  pattern = { 'text', 'markdown', 'html', 'xhtml', 'javascript', 'typescript' },
  command = 'setlocal cc=0'
})

-- Set indentation to 2 spaces
augroup('setIndent', { clear = true })
autocmd('Filetype', {
  group = 'setIndent',
  pattern = { 'xml', 'html', 'xhtml', 'css', 'scss', 'javascript', 'typescript',
    'yaml', 'lua'
  },
  command = 'setlocal shiftwidth=2 tabstop=2'
})

-- Set line number for help files.
augroup('help_config', { clear = true })
autocmd('Filetype', {
  group = 'help_config',
  pattern = { 'help' },
  command = 'setlocal number'
})

-- Restore cursor position?
autocmd("BufReadPost", {
  callback = function()
    local last_pos = vim.fn.line("'\"")
    if last_pos > 0 and last_pos <= vim.fn.line("$") then
      vim.api.nvim_win_set_cursor(0, {last_pos, 0})
    end
  end,
})

-- Terminal settings

-- Open a Terminal on the right tab
autocmd('CmdlineEnter', {
  command = 'command! Term :botright vsplit term://$SHELL'
})
-- Enter insert mode when switching to terminal
autocmd('TermOpen', {
  command = 'setlocal listchars= nonumber norelativenumber nocursorline',
})
autocmd('TermOpen', {
  pattern = '*',
  command = 'startinsert'
})
-- Close terminal buffer on process exit
autocmd('BufLeave', {
  pattern = 'term://*',
  command = 'stopinsert'
})

-- Cursor Line and Status line settings

-- Add cursorline and diasable it in some buffers and filetypes.
statusline_hide = {
  "dashboard",
  "TelescopePrompt",
  "TelescopeResults",
  "terminal",
  "toggleterm",
}

function hide_statusline(types)
  for _, type in pairs(types) do
    if vim.bo.filetype == type or vim.bo.buftype == type then
      vim.opt.laststatus = 0
      vim.opt.ruler = false
      vim.opt.cursorline = false
      break
    else
      vim.opt.laststatus = 3
      vim.opt.ruler = true
      vim.opt.cursorline = true
    end
  end
end

-- BufEnter,BufRead,BufWinEnter,FileType,WinEnter
vim.cmd("autocmd BufEnter,BufRead,BufWinEnter,FileType,WinEnter * lua hide_statusline(statusline_hide)")

