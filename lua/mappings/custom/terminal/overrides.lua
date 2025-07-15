--[[
-- Mappings: Terminal - Overrides
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-15
--]]


---------- Helpers ----------
local keys = require('helpers.utils.keys')
local function map(key, action, desc)
  keys:tmap(key, action, desc)
end


-- Escape terminal view
-- map("<Esc>", "<C-\\><C-n>", 'Exit Terminal Mode')
-- map('<Esc><Esc>', '<C-\\><C-n>', 'Exit Terminal Mode')
map("<Esc><Esc>", vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), 'Exit Terminal Mode')

-- Terminal Mappings
-- map("<C-h>", "<cmd>wincmd h<cr>", "Go to Left Window")
-- map("<C-j>", "<cmd>wincmd j<cr>", "Go to Lower Window")
-- map("<C-k>", "<cmd>wincmd k<cr>", "Go to Upper Window")
-- map("<C-l>", "<cmd>wincmd l<cr>", "Go to Right Window")

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
-- map('<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
