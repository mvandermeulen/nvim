vim.o.timeoutlen = 300

vim.cmd([[ let maplocalleader = "," ]])

vim.api.nvim_set_keymap("n", "<C-k>", ":wincmd k<CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-j>", ":wincmd j<CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-h>", ":wincmd h<CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-l>", ":wincmd l<CR>", { silent = true, noremap = true })

vim.api.nvim_set_keymap("n", "<C-q>", ":q<CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-a>", ":bd<CR>", { silent = true, noremap = true })

-- https://www.reddit.com/r/neovim/comments/um3epn/what_are_your_prizedfavorite_lua_functions/
local async = require("plenary.async")
local packer_sync = function()
	async.run(function()
		vim.notify.async("Syncing packer.", "info", {
			title = "Packer",
		})
	end)
	local snap_shot_time = os.date("!%Y-%m-%dT%TZ")
	vim.cmd("PackerSnapshot " .. snap_shot_time)
	vim.cmd("PackerSync")
end

vim.api.nvim_set_keymap("n", "<Leader>ps", "", { callback = packer_sync })
