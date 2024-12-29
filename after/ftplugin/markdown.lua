vim.keymap.set("n", "<C-m>w", "<CMD>MakeWordMarkdownLink<CR>", { noremap = true, silent = true, desc = 'Make word Markdown Link' })
vim.keymap.set("n", "<C-m>W", "<CMD>MakeNonWhitespaceWordMarkdownLink<CR>", { noremap = true, silent = true, desc = 'Make WORD Markdown Link' })
