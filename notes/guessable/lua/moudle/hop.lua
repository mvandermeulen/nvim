-- hop
require "hop".setup {
  keys = "etovxqpdygfblzhckisuran"
}

vim.api.nvim_set_keymap("n", "<leader>w", "<cmd>HopWord<cr>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>s", "<cmd>HopChar2<cr>", {noremap = true, silent = true})
