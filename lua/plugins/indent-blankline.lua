--[[
-- Indent Blankline
--
-- Author: Mark van der Meulen
-- Updated: 09-05-2022
--]]

local status_ok, indent_blankline = pcall(require, "indent_blankline")
if not status_ok then
	return
end

vim.g.indent_blankline_buftype_exclude = { "terminal", "nofile" }
vim.g.indent_blankline_filetype_exclude = {
	"help",
	"startify",
	"dashboard",
	"packer",
	"neogitstatus",
	"NvimTree",
	"Trouble",
}
vim.g.indentLine_enabled = 1
-- vim.g.indent_blankline_char = "│"
vim.g.indent_blankline_char = "▏"
-- vim.g.indent_blankline_char = "▎"
vim.g.indent_blankline_show_trailing_blankline_indent = false
vim.g.indent_blankline_show_first_indent_level = true
vim.g.indent_blankline_use_treesitter = true
vim.g.indent_blankline_show_current_context = true
vim.g.indent_blankline_context_patterns = {
	"class",
	"return",
	"function",
	"method",
	"^if",
	"^while",
	"jsx_element",
	"^for",
	"^object",
	"^table",
	"block",
	"arguments",
	"if_statement",
	"else_clause",
	"jsx_element",
	"jsx_self_closing_element",
	"try_statement",
	"catch_clause",
	"import_statement",
	"operation_type",
}

indent_blankline.setup({
	-- show_end_of_line = true,
	-- space_char_blankline = " ",
	show_current_context = true,
	use_treesitter = true,
	-- show_current_context_start = true,
	-- char_highlight_list = {
	--   "IndentBlanklineIndent1",
	--   "IndentBlanklineIndent2",
	--   "IndentBlanklineIndent3",
	-- },
})

-- require("indent_blankline").setup {
-- indentLine_enabled = 1,
-- char = "▏",
-- filetype_exclude = {
-- "startify", "dashboard", "dotooagenda", "log", "fugitive", "gitcommit",
-- "packer", "vimwiki", "markdown", "json", "txt", "vista", "help",
-- "todoist", "NvimTree", "peekaboo", "git", "TelescopePrompt", "undotree",
-- "flutterToolsOutline", "" -- for all buffers without a file type
-- },
-- buftype_exclude = {"terminal", "nofile"},
-- show_trailing_blankline_indent = false,
-- show_first_indent_level = true,
-- show_current_context = true,
-- char_list = {"|", "¦", "┆", "┊"},
-- space_char = " ",
-- context_patterns = {
-- "class", "function", "method", "block", "list_literal", "selector",
-- "^if", "^table", "if_statement", "while", "for"
-- }
-- }
