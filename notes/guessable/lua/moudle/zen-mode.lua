-- zen-mode
require("zen-mode").setup {
  window = {
    backdrop = 1,
    width = 1,
    height = 1,
    options = {
      signcolumn = "no",
      number = true
    }
  }
}
vim.api.nvim_set_keymap("n", "<Leader>zm", ":ZenMode<cr>", {noremap = true, silent = true})
