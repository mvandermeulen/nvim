--[[
-- Mappings: Terminal - Modifiers
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-15
--]]


---------- Helpers ----------
local keys = require('helpers.utils.keys')
local function map(key, action, desc)
  keys:tmap(key, action, desc)
end


--------------------
-- Shift Modifier
--------------------

--------------------
-- Meta Modifier
--------------------
-- Navigation from terminal
-- vim.keymap.set("t", "<C-esc>", [[<C-\><C-n>]], opts)
map("<M-h>", [[<C-\><C-n><C-w>h]], 'Window Left')
map("<M-j>", [[<C-\><C-n><C-w>j]], 'Window Down')
map("<M-k>", [[<C-\><C-n><C-w>k]], 'Window Up')
map("<M-l>", [[<C-\><C-n><C-w>l]], 'Window Right')

--------------------
-- Ctrl Modifier
--------------------


