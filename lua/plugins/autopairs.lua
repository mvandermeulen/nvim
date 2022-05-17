--[[
-- Auto Pairs
--
-- Author: Mark van der Meulen
-- Updated: 09-05-2022
--]]

enable_check_bracket_line = false
local status_ok, npairs = pcall(require, "nvim-autopairs")
if not status_ok then
	return
end

npairs.setup({
	check_ts = true,
	ts_config = {
		lua = { "string", "source" },
		javascript = { "string", "template_string" },
		java = false, -- don't check treesitter on java
	},
	disable_filetype = { "TelescopePrompt", "spectre_panel" },
})
