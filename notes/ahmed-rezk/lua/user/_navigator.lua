local M = {}

function M.setup()
	require("navigator").setup({
		keymaps = {
			{ key = "gr", func = "require('navigator.reference').reference()" },
			{ mode = "i", key = "<M-k>", func = "signature_help()" },
			{ key = "<c-k>", func = "signature_help()" },
			{ key = "g0", func = "require('navigator.symbols').document_symbols()" },
			{ key = "gW", func = "workspace_symbol()" },
			{ key = "<leader>P", func = "require('navigator.definition').definition()" },
			{ key = "gD", func = "declaration({ border = 'rounded', max_width = 80 })" },
			{ key = "gp", func = "require('navigator.definition').definition_preview()" },
			{ key = "gT", func = "require('navigator.treesitter').buf_ts()" },
			{ key = "gt", func = "require('navigator.treesitter').bufs_ts()" },
			{ key = "K", func = "hover({ popup_opts = { border = single, max_width = 80 }})" },
			{ key = "ca", mode = "n", func = "require('navigator.codeAction').code_action()" },
			{ key = "cA", mode = "v", func = "range_code_action()" },
			{ key = "re", func = "rename()" },
			{ key = "<leader>R", func = "require('navigator.rename').rename()" },
			{ key = "<Leader>gi", func = "incoming_calls()" },
			{ key = "<Leader>go", func = "outgoing_calls()" },
			{ key = "gi", func = "implementation()" },
			{ key = "<leader>D", func = "type_definition()" },
			{ key = "gL", func = "require('navigator.diagnostics').show_diagnostics()" },
			{ key = "gG", func = "require('navigator.diagnostics').show_buf_diagnostics()" },
			{ key = "<Leader>dt", func = "require('navigator.diagnostics').toggle_diagnostics()" },
			{ key = "]d", func = "diagnostic.goto_next({ border = 'rounded', max_width = 80})" },
			{ key = "[d", func = "diagnostic.goto_prev({ border = 'rounded', max_width = 80})" },
			{ key = "]r", func = "require('navigator.treesitter').goto_next_usage()" },
			{ key = "[r", func = "require('navigator.treesitter').goto_previous_usage()" },
			{ key = "<C-LeftMouse>", func = "definition()" },
			{ key = "g<LeftMouse>", func = "implementation()" },
			{ key = "<leader>k", func = "require('navigator.dochighlight').hi_symbol()" },
			{ key = "<leader>wa", func = "add_workspace_folder()" },
			{ key = "<leader>wr", func = "remove_workspace_folder()" },
			{ key = "<leader>ff", func = "formatting()", mode = "n" },
			{ key = "<leader>ff", func = "range_formatting()", mode = "v" },
			{ key = "<leader>wl", func = "print(vim.inspect(vim.lsp.buf.list_workspace_folders()))" },
			{ key = "<leader>la", mode = "n", func = "require('navigator.codelens').run_action()" },
		},
		icons = {
			code_action_icon = "💡",
		},
		transparency = 50,
		lsp = {
			code_action = { enable = true, sign = true, sign_priority = 40, virtual_text = true },
			code_lens_action = { enable = true, sign = true, sign_priority = 40, virtual_text = true },
			format_on_save = false, -- set to false to disasble lsp code format on save (if you are using prettier/efm/formater etc)
			disable_format_cap = { "sqls", "sumneko_lua", "gopls" }, -- a list of lsp disable format capacity (e.g. if you using efm or vim-codeformat etc), empty {} by default
			disable_lsp = { "pylsd", "sqlls" }, -- a list of lsp server disabled for your project, e.g. denols and tsserver you may
			-- only want to enable one lsp server
			-- to disable all default config and use your own lsp setup set
			-- disable_lsp = 'all'
			-- Default {}
			diagnostic_scrollbar_sign = { "▃", "▆", "█" }, -- experimental:  diagnostic status in scroll bar area; set to false to disable the diagnostic sign,
			-- for other style, set to {'╍', 'ﮆ'} or {'-', '='}
			diagnostic_virtual_text = true, -- show virtual for diagnostic message
			diagnostic_update_in_insert = false, -- update diagnostic message in insert mode
			disply_diagnostic_qf = true, -- always show quickfix if there are diagnostic errors, set to false if you  want to
		},
	})
end
return M
