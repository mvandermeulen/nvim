local M = {}

M.mappings = {
    name = ' Find',
    b = { '<cmd>Telescope git_branches<cr>', 'Checkout branch' },
    c = { '<cmd>Telescope colorscheme<cr>', 'Colorscheme' },
    f = {
      "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>",
      'Find files',
    },
    t = { '<cmd>Telescope live_grep theme=ivy<cr>', 'Find Text' },
    h = { '<cmd>Telescope help_tags<cr>', 'Help' },
    i = { "<cmd>lua require('telescope').extensions.media_files.media_files()<cr>", 'Media' },
    l = { '<cmd>Telescope resume<cr>', 'Last Search' },
    M = { '<cmd>Telescope man_pages<cr>', 'Man Pages' },
    r = { '<cmd>Telescope oldfiles<cr>', 'Recent File' },
    R = { '<cmd>Telescope registers<cr>', 'Registers' },
    k = { '<cmd>Telescope keymaps<cr>', 'Keymaps' },
    C = { '<cmd>Telescope commands<cr>', 'Commands' },
}

M.options = {
  mode = "n",
  silent = true,
  noremap = true,
  prefix = "<leader><leader>",
  nowait = false,
}

return M
