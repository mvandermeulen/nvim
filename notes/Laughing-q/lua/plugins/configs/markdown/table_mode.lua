local M = {}

M.setup = function()
	-- move to globel
	-- vim.g.table_mode_map_prefix = '<Leader>m'
	-- vim.g.table_mode_toggle_map = 'm'

	vim.g.table_mode_corner = "+"
	vim.g.table_mode_separator = "|"
	vim.g.table_mode_separator_map = "<Bar>"
	-- vim.g.table_mode_escaped_separator_regex = '\V\C\\\@1<!|'
	vim.g.table_mode_fillchar = "-"
	vim.g.table_mode_header_fillchar = "-"
	vim.g.table_mode_always_active = 0
	vim.g.table_mode_delimiter = ","
	vim.g.table_mode_corner_corner = "|"
	vim.g.table_mode_align_char = ":"
	vim.g.table_mode_disable_mappings = 0

	vim.g.table_mode_motion_up_map = "{<Bar>"
	vim.g.table_mode_motion_down_map = "}<Bar>"
	vim.g.table_mode_motion_left_map = "[<Bar>"
	vim.g.table_mode_motion_right_map = "]<Bar>"

	vim.g.table_mode_cell_text_object_a_map = "a<Bar>"
	vim.g.table_mode_cell_text_object_i_map = "i<Bar>"

	vim.g.table_mode_realign_map = "<Leader>mr"
	vim.g.table_mode_delete_row_map = "<Leader>mdd"
	vim.g.table_mode_delete_column_map = "<Leader>mdc"
	vim.g.table_mode_insert_column_before_map = "<Leader>miC"
	vim.g.table_mode_insert_column_after_map = "<Leader>mic"
	vim.g.table_mode_add_formula_map = "<Leader>mfa"
	vim.g.table_mode_eval_formula_map = "<Leader>mfe"
	vim.g.table_mode_echo_cell_map = "<Leader>m?"
	vim.g.table_mode_sort_map = "<Leader>ms"
	vim.g.table_mode_tableize_map = "<Leader>mt"
	vim.g.table_mode_tableize_d_map = "<Leader>M"

	vim.g.table_mode_syntax = 1
	vim.g.table_mode_auto_align = 1
	vim.g.table_mode_update_time = 500
	vim.g.table_mode_tableize_auto_border = 0
end
return M
