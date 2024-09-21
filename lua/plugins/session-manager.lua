--[[
-- Session Manager Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-08-22
--]]

local sessions_path = vim.fn.expand(vim.fn.stdpath 'data' .. '/session_manager')
if vim.fn.isdirectory(sessions_path) == 0 then
  vim.fn.mkdir(sessions_path, 'p')
end

local Path = require('plenary.path')
local config = require('session_manager.config')
local session_manager = require('session_manager')

session_manager.setup({
  sessions_dir = Path:new(vim.fn.stdpath('data'), 'session_manager'), -- The directory where the session files will be saved.
  autoload_mode = config.AutoloadMode.CurrentDir, -- Define what to do when Neovim is started without arguments. See "Autoload mode" section below.
  autosave_last_session = true, -- Automatically save last session on exit and on session switch.
  autosave_ignore_not_normal = true, -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
  autosave_ignore_dirs = {}, -- A list of directories where the session will not be autosaved.
  autosave_ignore_filetypes = { -- All buffers of these file types will be closed before the session is saved.
    'gitcommit',
    'gitrebase',
  },
  autosave_ignore_buftypes = {}, -- All buffers of these bufer types will be closed before the session is saved.
  autosave_only_in_session = false, -- Always autosaves session. If true, only autosaves after a session is active.
  max_path_length = 80,  -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
})


-- Auto save session
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  callback = function ()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      -- Don't save while there's any 'nofile' buffer open.
      if vim.api.nvim_get_option_value("buftype", { buf = buf }) == 'nofile' then
        return
      end
    end
    session_manager.save_current_session()
  end
})
