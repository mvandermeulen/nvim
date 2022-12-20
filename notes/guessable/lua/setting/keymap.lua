local map = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}

-- Leader key
map("n", "<Space>", "<NOP>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- plug
map("n", "<leader>ud", ":UndotreeToggle<CR>", opts)
map("n", "<leader>tm", ":TableModeToggle<CR>", opts)
map("n", "<leader>ts", ":TranslateW --engines=bing<CR>", opts)
map("v", "<leader>ts", ":TranslateW --engines=bing<CR>", opts)

map("n", "<Leader>db", ":DB<CR>", opts)
map("n", "<Leader>pw", ":pwd<CR>", opts)
map("n", "<Leader>fv", ":e ~/.config/nvim/init.lua<CR>", opts)

-- disable
map("i", "<Up>", "<NOP>", opts)
map("i", "<Down>", "<NOP>", opts)
map("i", "<Left>", "<NOP>", opts)
map("i", "<Right>", "<NOP>", opts)

-- save
map("n", "<C-s>", ":w<CR>", opts)
map("i", "<C-s>", "<Esc>:w<CR>a", opts)

-- term
map("n", "<Leader>tv", ":vnew term://zsh<CR> i", opts)
map("n", "<Leader>th", ":new term://zsh<CR>:res -5<CR> i", opts)
map("t", "<C-\\>", "<C-\\><C-N>", opts)
map("t", ":q", "<C-\\><C-N>:bd!<CR>", opts)

-- windows movement
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)
map("n", "<C-o>", "<C-w>o", opts)
map("t", "<C-h>", "<C-\\><C-N><C-w>h", opts)
map("t", "<C-j>", "<C-\\><C-N><C-w>j", opts)
map("t", "<C-k>", "<C-\\><C-N><C-w>k", opts)
map("t", "<C-l>", "<C-\\><C-N><C-w>l", opts)

-- emacs style
map("n", "<C-a>", "0", opts)
map("n", "<C-e>", "$", opts)
map("i", "<C-e>", "<End>", opts)
map("i", "<C-a>", "<Home>", opts)
map("i", "<C-p>", "<Up>", opts)
map("i", "<C-n>", "<Down>", opts)
map("i", "<C-b>", "<Left>", opts)
map("i", "<C-f>", "<Right>", opts)
map("i", "<M-f>", "<S-Right>", opts)
map("i", "<M-b>", "<S-Left>", opts)

-- resize
map("n", "<Up>", ":resize +3<CR>", opts)
map("n", "<Down>", ":resize -3<CR>", opts)
map("n", "<Left>", ":vertical res +3<CR>", opts)
map("n", "<Right>", ":vertical res -3<CR>", opts)
