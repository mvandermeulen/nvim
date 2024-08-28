--[[
-- Auto Session Configuration
--
-- Author: Mark van der Meulen
-- Updated: 2024-08-22
--]]

-- plugin: auto-session
-- see: https://github.com/rmagatti/auto-session

local HOME = vim.fn.expand('$HOME')

require('auto-session').setup({
  log_level = 'error',
  auto_session_root_dir = vim.fn.stdpath('data') .. '/auto_sessions/',
  auto_session_enable_last_session = false,
  auto_session_enabled = true,
  auto_save_enabled = true,
  auto_restore_enabled = vim.g.auto_session_enabled or true,
  auto_session_suppress_dirs = { '/etc', '/tmp', HOME, HOME .. '/code', HOME .. '/dev' },

  pre_save_cmds = { 'lua require("helpers.interface").win.close_plugin_owned()' },
})
