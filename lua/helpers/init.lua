--[[
-- Helpers
--
-- Author: Mark van der Meulen
-- Updated: 2024-09-22
--]]


_G.my.settings = require("helpers.user.settings")
_G.my.helpers.providers = require("helpers.user.providers")
_G.my.helpers.icons = require("helpers.ui.icons")
_G.my.helpers.server = require("helpers.user.server")
_G.my.helpers.Class = require('helpers.utils.class')
-- _G.my.helpers.Array = require('helpers.utils.array')
_G.my.helpers.List = require('helpers.utils.list')
_G.my.helpers.Colours = require('helpers.utils.colours')
_G.create_picker = require('plugins.navigation.telescope.picker')

require('helpers.user.auto')
require('helpers.ui.windows.zoom')
require('helpers.command')
require('helpers.user.clipboard').setup()
