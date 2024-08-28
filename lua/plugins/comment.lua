--[[
-- Commenting Plugin
--
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]

local status_ok, comment = pcall(require, "Comment")
if not status_ok then
	return
end

comment.setup({
	padding = true, ---Add a space b/w comment and the line
	ignore = "^$", ---Lines to be ignored while comment/uncomment.
	---Create basic (operator-pending) and extended mappings for NORMAL + VISUAL mode
	mappings = {
		---operator-pending mapping
		---Includes `gcc`, `gcb`, `gc[count]{motion}` and `gb[count]{motion}`
		basic = true,
		---extra mapping
		---Includes `gco`, `gcO`, `gcA`
		extra = true,
		---extended mapping
		---Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
		extended = true,
	},

	---LHS of toggle mapping in NORMAL + VISUAL mode
	---@type table
	toggler = {
		---line-comment keymap
		line = "gcc",
		---block-comment keymap
		block = "gbc",
	},

	---LHS of operator-pending mapping in NORMAL + VISUAL mode
	---@type table
	opleader = {
		---line-comment keymap
		line = "gc",
		---block-comment keymap
		block = "gb",
	},

	---Pre-hook, called before commenting the line
  --pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
	--[[ pre_hook = function(ctx) ]]
	--[[ 	local U = require("Comment.utils") ]]

	--[[ 	local location = nil ]]
	--[[ 	if ctx.ctype == U.ctype.block then ]]
	--[[ 		location = require("ts_context_commentstring.utils").get_cursor_location() ]]
	--[[ 	elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then ]]
	--[[ 		location = require("ts_context_commentstring.utils").get_visual_start_location() ]]
	--[[ 	end ]]

	--[[ 	return require("ts_context_commentstring.internal").calculate_commentstring({ ]]
	--[[ 		key = ctx.ctype == U.ctype.line and "__default" or "__multiline", ]]
	--[[ 		location = location, ]]
	--[[ 	}) ]]
	--[[ end, ]]

	---Post-hook, called after commenting is done
	---@type function|nil
	post_hook = nil,
})
