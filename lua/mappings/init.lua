--[[
-- Key Mappings
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-15
--]]



---------- Helpers ----------
local keys = require('helpers.utils.keys')
local map = keys.safe_keymap_set
local kmo = keys.kmo

require("helpers.user.unimpaired")

-----------------------------------------------
-- Map Leader Key & Local Leader
-----------------------------------------------
map("n", "<Space>", "<NOP>", kmo()) -- map the leader key
vim.g.mapleader = " "
--vim.g.maplocalleader = "\\"
vim.g.maplocalleader = ","


require("mappings.wk")
require("mappings.custom")
