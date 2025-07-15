--[[
-- Mappings: Visual - Overrides
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-15
--]]


---------- Helpers ----------
local keys = require('helpers.utils.keys')
local map = keys.safe_keymap_set
local kmo = keys.kmo


-- better indenting
map("v", "<", "<gv", kmo())
map("v", ">", ">gv", kmo())

map("v", "p", '"_dP', kmo()) -- paste over currently selected text without yanking it

-- Move selected line / block of text in visual mode
map("v", "K", ":move '<-2<CR>gv-gv", kmo())
map("v", "J", ":move '>+1<CR>gv-gv", kmo())




