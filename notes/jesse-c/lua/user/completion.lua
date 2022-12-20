vim.g.coq_settings = {
	auto_start = "shut-up",
	keymap = {
		-- Set these to dummy values so that they don't conflict
		jump_to_mark = "<c-0>",
		bigger_preview = "<c-0>",
	},
}

vim.o.updatetime = 250
-- Don't give |ins-completion-menu| messages.
vim.cmd([[ set shortmess+=c ]])
