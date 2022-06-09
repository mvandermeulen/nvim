local M = {}

M.mappings = {
  name = 'Search',
  a = { '<cmd>Telescope autocommands<cr>', 'Auto Commands' },
  c = { '<cmd>Telescope commands<cr>', 'Commands' },
  C = { '<cmd>Telescope colorscheme<cr>', 'Colorscheme' },
  h = { '<cmd>Telescope help_tags<cr>', 'Find Help' },
  H = { '<cmd>Telescope heading<cr>', 'Find Header' },
  j = { '<cmd>Telescope jumplist<cr>', 'Jumplist' },
  k = { '<cmd>Telescope keymaps<cr>', 'Keymaps' },
  m = { '<cmd>require("telescope").extensions.macroscope.default()<cr>', 'Macros' },
  M = { '<cmd>Telescope man_pages<cr>', 'Man Pages' },
  n = { "<cmd>lua require('telescope').extensions.neoclip.default()<cr>", 'Neoclip' },
  N = { '<cmd>Telescope notify<cr>', ' Notifications' },
  p = { '<cmd>Telescope projects<cr>', 'Projects' },
  P = {
    "<cmd>lua require('telescope.builtin.internal').colorscheme({enable_preview = true})<cr>",
    'Colorscheme with Preview',
  },
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
  prefix = "<leader>/",
  nowait = true,
}

return M


