local M = {}

M.mappings = {
  name = 'Harpoon',
  a = { "<cmd>lua require('harpoon.mark').add_file()<cr>", 'Add file' },
  u = { "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", 'Open Menu' },
  ['1'] = { "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", 'Open File 1' },
  ['2'] = { "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", 'Open File 2' },
  ['3'] = { "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", 'Open File 3' },
  ['4'] = { "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", 'Open File 4' },
}

M.options = {
  mode = "n",
  silent = true,
  noremap = true,
  prefix = "<leader><leader>",
  nowait = false,
}

return M

