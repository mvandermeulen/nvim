--[[
-- Mappings: Settings
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]


-- local log = require('plenary.log').new({ plugin = 'editor-settings', level = 'debug', use_console = true })
-- local function mylog(msg, level)
--   local level = level or 'debug'
--   log.debug(msg)
--   if level == 'info' or level == 'warn' or level == 'error' then
--     vim.notify(msg, vim.log.levels.INFO, { title = 'editor-settings' })
--   end
-- end

-- local helper_status, helper = pcall(require, 'helpers.user.settings')
-- if not helper_status then
--   mylog('Failed to load helper: user.settings', 'error')
--   return
-- end


return {
  { '<leader>esb', '<cmd>:Gitsigns toggle_current_line_blame<cr>', desc = 'Toggle Blame' },
  { '<leader>esl', '<cmd>:Gitsigns toggle_linehl<cr>', desc = 'Toggle modified line highlighting' },
  { '<leader>ess', '<cmd>:Gitsigns toggle_signs<cr>', desc = 'Toggle Git Signs' },
  { "<leader>esw", "<cmd>:Gitsigns toggle_word_diff<CR>", desc = "Toggle Word Diff"},
  { "<leader>esh", "<cmd>:nohlsearch<CR>", desc = "No Highlight" },
  { "<leader>esi", "<CMD>LspToggleInlayHints<CR>", desc = "Toggle Inlay Hints"},
  { '<leader>esv', function() _G.my.settings.toggle_virtual_edit() end, desc = 'Toggle virtualedit' },
  { '<leader>esV', function() _G.my.settings.toggle_virtual_text() end, desc = 'LSP: Toggle virtual text of diagnostics' },
  { '<leader>esW', function() _G.my.settings.toggle_word_wrap() end, desc = 'Toggle Word Wrap' },
  { '<leader>esr', function() _G.my.settings:toggle_setting('auto_resize_splits') end, desc = 'Toggle Auto-Splits Resize' },
}
