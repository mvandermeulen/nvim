--[[
-- Modicator Plugin
-- Author: Mark van der Meulen
-- Updated: 2025-10-16
--]]


-- Cursor line number mode indicator.
-- Link: https://github.com/mawkler/modicator.nvim

return {
  'mawkler/modicator.nvim',
  dependencies = 'mawkler/onedark.nvim', -- Add your colorscheme plugin here
  event = { 'BufReadPost', 'BufNewFile', 'VeryLazy' },
  init = function()
    -- These are required for Modicator to work
    vim.o.cursorline = true
    vim.o.number = true
    vim.o.termguicolors = true
  end,
  opts = {
    -- Warn if any required option above is missing. May emit false positives
    -- if some other plugin modifies them, which in that case you can just
    -- ignore. Feel free to remove this line after you've gotten Modicator to
    -- work properly.
    show_warnings = true,
  },
}
