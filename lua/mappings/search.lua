local M = {}

M.mappings = {
  name = 'Search',
  a = { '<cmd>Telescope autocommands<cr>', 'Auto Commands' },
  b = { '<cmd>Telescope git_branches<cr>', 'Checkout branch' },
  c = { '<cmd>Telescope commands<cr>', 'Commands' },
  C = { '<cmd>Telescope colorscheme<cr>', 'Colorscheme' },
  f = {
    "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>",
    'Find files',
  },
  h = { '<cmd>Telescope help_tags<cr>', 'Find Help' },
  H = { '<cmd>Telescope heading<cr>', 'Find Header' },
  i = { "<cmd>lua require('telescope').extensions.media_files.media_files()<cr>", 'Media' },
  j = { '<cmd>Telescope jumplist<cr>', 'Jumplist' },
  k = { '<cmd>Telescope keymaps<cr>', 'Keymaps' },
  l = { '<cmd>Telescope resume<cr>', 'Last Search' },
  m = { '<cmd>require("telescope").extensions.macroscope.default()<cr>', 'Macros' },
  M = { '<cmd>Telescope man_pages<cr>', 'Man Pages' },
  n = { "<cmd>lua require('telescope').extensions.neoclip.default()<cr>", 'Neoclip' },
  N = { '<cmd>Telescope notify<cr>', ' Notifications' },
  p = { '<cmd>Telescope projects<cr>', 'Projects' },
  P = {
    "<cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<cr>",
    'Colorscheme with Preview',
  },
  r = { '<cmd>Telescope oldfiles<cr>', 'Recent File' },
  R = { '<cmd>Telescope registers<cr>', 'Registers' },
  s = { '<cmd>Telescope grep_string<cr>', 'Text under cursor' },
  S = { '<cmd>Telescope symbols<cr>', 'Search Emoji' },
  t = { '<cmd>Telescope live_grep<cr>', 'Text' },
  T = { '<cmd>Telescope treesitter<cr>', 'Treesitter' },
}

M.options = {
  mode = "n",
  silent = true,
  noremap = true,
  prefix = "<leader>s",
  nowait = true,
}

return M


