--[[
-- Autocommand functions
--
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

-- Define autocommands with Lua APIs
-- See: h:api-autocmd, h:augroup

local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand
local fn = vim.fn


------------------------------------
-- Functions
------------------------------------
local function augroupm(name) return vim.api.nvim_create_augroup("m_autocmds_" .. name, { clear = true }) end
local function naugroup(name) return vim.api.nvim_create_augroup(name, { clear = true }) end

local function clear_cmdarea()
  vim.defer_fn(function()
    vim.api.nvim_echo({}, false, {})
  end, 800)
end

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

-- Cursor Line and Status line settings

-- Add cursorline and diasable it in some buffers and filetypes.
statusline_hide = {
  "dashboard",
  "TelescopePrompt",
  "TelescopeResults",
  "terminal",
  "toggleterm",
}

------------------------------------
-- Events: Copy
------------------------------------

-- Highlight on yank
autocmd('TextYankPost', {
  group = naugroup('YankHighlight'),
  callback = function() vim.highlight.on_yank({ higroup = 'IncSearch', timeout = '1000' }) end
})

------------------------------------
-- Events: Buffer
------------------------------------
-- Don't auto comment new lines
autocmd('BufEnter', {
  pattern = '*',
  command = 'set fo-=c fo-=r fo-=o'
})

-- BufEnter,BufRead,BufWinEnter,FileType,WinEnter
vim.cmd("autocmd BufEnter,BufRead,BufWinEnter,FileType,WinEnter * lua hide_statusline(statusline_hide)")


-- Restore cursor position?
-- autocmd("BufReadPost", {
--   callback = function()
--     local last_pos = vim.fn.line("'\"")
--     if last_pos > 0 and last_pos <= vim.fn.line("$") then
--       vim.api.nvim_win_set_cursor(0, {last_pos, 0})
--     end
--   end,
-- })


-- Jump to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroupm("last_loc"),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

------------------------------------
-- Events: Filetype
------------------------------------

-- Disable line length marker for:  xml, html, xhtml, css, scss, javascript, typescript, yaml, lua
autocmd('Filetype', {
  group = naugroup('setLineLength'),
  pattern = { 'text', 'markdown', 'html', 'xhtml', 'javascript', 'typescript' },
  command = 'setlocal cc=0'
})

-- Set indentation to 2 spaces for:  xml, html, xhtml, css, scss, javascript, typescript, yaml, lua
autocmd('Filetype', {
  group = naugroup('setIndent'),
  pattern = { 'xml', 'html', 'xhtml', 'css', 'scss', 'javascript', 'typescript', 'yaml', 'lua' },
  command = 'setlocal shiftwidth=2 tabstop=2'
})

-- Set line number for help files.
autocmd('Filetype', {
  group = naugroup('help_config'),
  pattern = { 'help' },
  command = 'setlocal number'
})

-- -- Using a file named .venv in your projects root folder, it will automatically set the virtual-env for such environment
-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = {"python"},
--     callback = function()
--         require('swenv.api').auto_venv()
--     end
-- })

vim.api.nvim_create_autocmd("FileType", {
    pattern = {"markdown"},
    callback = function()
      -- Currently using C-i as C-m does not work.
      vim.keymap.set("n", "<M-i>c", function() require("helpers.user.tools").md_block() end, { noremap = true, silent = true, desc = 'Make word Markdown Link' })
      vim.keymap.set("n", "<M-i>w", "<CMD>MakeWordMarkdownLink<CR>", { noremap = true, silent = true, desc = 'Make word Markdown Link' })
      vim.keymap.set("n", "<M-i>W", "<CMD>MakeNonWhitespaceWordMarkdownLink<CR>", { noremap = true, silent = true, desc = 'Make WORD Markdown Link' })
      vim.keymap.set("n", "<C-a>", function() require("helpers.user.tools").increase_header() end, { noremap = true, silent = true, desc = 'Increase Markdown Header' })
      vim.keymap.set("n", "<C-x>", function() require("helpers.user.tools").decrease_header() end, { noremap = true, silent = true, desc = 'Decrease Markdown Header' })
    end
})

------------------------------------
-- Terminal
------------------------------------

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

------------------------------------
-- Events: Insert
------------------------------------


autocmd("InsertEnter", {-- Toggle `relativenumber` on insert enter/leave
  pattern = "*",
  group = augroupm("enter_relativenumber"),
  command = "setlocal norelativenumber",
})

autocmd("InsertLeave", {-- Toggle `relativenumber` on insert enter/leave
  pattern = "*",
  group = augroupm("leave_relativenumber"),
  command = "setlocal relativenumber",
})


autocmd("InsertEnter", {-- Display diagnostics as virtual text only if not in insert mode
  pattern = "*",
  group = augroupm("insert_diagnostics"),
  callback = function()
    vim.diagnostic.config({
      virtual_text = false,
    })
  end,
})

autocmd("InsertLeave", {-- Display diagnostics as virtual text only if not in insert mode
  pattern = "*",
  group = augroupm("leaver_diagnostics"),
  callback = function()
    vim.diagnostic.config({
      virtual_text = true,
    })
  end,
})

autocmd({ "InsertLeave", "TextChanged" }, {-- Autosave on insert leave
  callback = function()
    if not _G.my.helpers.server:is_running() then
      return
    end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      -- Don't save while there's any 'nofile' buffer open.
      if vim.api.nvim_get_option_value("buftype", { buf = buf }) == 'nofile' then
        return
      end
    end
    if #vim.api.nvim_buf_get_name(0) ~= 0 and vim.bo.buflisted then
      vim.cmd "silent w"
      clear_cmdarea()
    end
  end,
})
