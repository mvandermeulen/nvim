--[[
-- Mappings: Other - Overrides
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-25
--]]




-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
vim.keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
vim.keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
vim.keymap.set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

vim.keymap.set({ 'n', 's', 'i' }, '<C-s>', function()
	vim.lsp.buf.signature_help({
		title = ' Lsp: Signature Help ',
		border = require('utils.common').floatwinborder,
		max_width = require('utils.lsp').float_max_width,
		max_height = require('utils.lsp').float_max_height,
	})
end, { desc = 'LSP: Signature Help' })


