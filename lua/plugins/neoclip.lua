--[[
-- Clipboard Plugin
--
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]

local opts = {
  history = 2000,
  enable_persistent_history = true,
  length_limit = 1048576,
  db_path = vim.fn.stdpath 'data' .. '/databases/neoclip.sqlite3',
  preview = true,
  enable_macro_history = true,
  keys = {
    telescope = {
      i = {
        select = '<cr>',
        paste = '<c-p>',
        paste_behind = '<c-l>',
        custom = {},
      },
      n = {
        select = '<cr>',
        paste = 'p',
        paste_behind = 'P',
        custom = {},
      },
    },
  },
}

require('neoclip').setup(opts)
