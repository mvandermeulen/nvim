-- FTerm
require "FTerm".setup(
  {
    border = "rounded", -- single double rounded solid shadow
    dimensions = {
      height = 0.7,
      width = 0.7,
      x = 0.5,
      y = 0.5
    }
  }
)
vim.api.nvim_set_keymap("n", "<leader>ft", '<CMD>lua require("FTerm").toggle()<CR>', {silent = true, noremap = true})
vim.api.nvim_set_keymap(
  "t",
  "<Esc>",
  '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>',
  {silent = true, noremap = true}
)
