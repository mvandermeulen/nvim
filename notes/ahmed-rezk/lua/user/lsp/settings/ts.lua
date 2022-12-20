return {
	settings = {
		typescript = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/ts")] = true,
					[vim.fn.stdpath("config") .. "/ts"] = true,
				},
			},
		},
	},
}
