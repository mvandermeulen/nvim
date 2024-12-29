return {
  "haringsrob/nvim_context_vt",
  lazy = false,
  dependencies = "nvim-treesitter/nvim-treesitter",
  opts = {
    enabled = false,
    prefix = " 󱞷",
    highlight = "NonText",
    min_rows = 7,
    disable_ft = { "markdown", "css" },
    disable_virtual_lines_ft = { "yaml" },
  },
  keys = {
    { "<leader>aTv", "<cmd>NvimContextVtToggle<CR>", desc = "VT Context: Toggle" },
  },
}
