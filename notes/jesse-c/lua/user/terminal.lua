local o = vim.o -- For the globals options

-- Enable mouse support
o.mouse = "a"
vim.api.nvim_create_autocmd("VimLeave", {
	pattern = "*",
	callback = function(_args)
		vim.cmd([[ set guicursor=a:ver100-blinkon0 ]])
	end,
	desc = "Restore cursor on exit",
})
