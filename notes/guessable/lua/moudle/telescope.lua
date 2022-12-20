-- telescope
local actions = require("telescope.actions")
require("telescope").setup {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case"
    },
    mappings = {
      n = {
        ["<Esc>"] = actions.close
      },
      i = {
        ["<Esc>"] = actions.close,
        ["<Leader>vv"] = actions.select_vertical,
        ["<Leader>hh"] = actions.select_horizontal,
        ["<Leader>tt"] = actions.select_tab
      }
    },
    prompt_prefix = "   ",
    selection_caret = " ",
    path_display = {"truncate"},
    color_devicons = true,
    use_less = true,
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        prompt_position = "bottom",
        preview_width = 0.5,
        results_width = 0.5
      },
      vertical = {
        mirror = false
      },
      width = 0.9,
      height = 0.9,
      preview_cutoff = 120
    },
    borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
    file_sorter = require("telescope.sorters").get_fuzzy_file,
    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new
  }
}
require("telescope").load_extension("neoclip")

vim.api.nvim_set_keymap(
  "n",
  "<Leader>fh",
  "<cmd>lua require('telescope.builtin').oldfiles()<cr>",
  {noremap = true, silent = true}
)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>ff",
  "<cmd>lua require('telescope.builtin').find_files()<cr>",
  {noremap = true, silent = true}
)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fw",
  "<cmd>lua require('telescope.builtin').live_grep()<cr>",
  {noremap = true, silent = true}
)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fb",
  "<cmd>lua require('telescope.builtin').buffers()<cr>",
  {noremap = true, silent = true}
)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fm",
  "<cmd>lua require('telescope.builtin').marks()<cr>",
  {noremap = true, silent = true}
)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fs",
  "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>",
  {noremap = true, silent = true}
)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fr",
  "<cmd>lua require('telescope.builtin').lsp_references()<cr>",
  {noremap = true, silent = true}
)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fd",
  "<cmd>lua require('telescope.builtin').lsp_definitions()<cr>",
  {noremap = true, silent = true}
)
vim.api.nvim_set_keymap("n", "<Leader>fc", ":Telescope neoclip<cr>", {noremap = true, silent = true})
