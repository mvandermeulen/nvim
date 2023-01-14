local M = {}

M.mappings = {
  name = 'Files',
  b = { '<cmd>Telescope file_browser<cr>', 'File browser' },
  f = {
    "<cmd>lua require'telescope.builtin'.find_files({ find_command = {'fd', '--hidden', '--type', 'file', '--follow'}})<cr>",
    'Find File',
  },
  p = { '<cmd>NvimTreeToggle<cr>', 'Toogle Tree' },
  r = { '<cmd>Telescope oldfiles<cr>', 'Open Recent File' },
  T = { '<cmd>NvimTreeFindFile<CR>', 'Find in Tree' },
}

M.options = {
  mode = "n",
  silent = true,
  noremap = true,
  prefix = "<leader>",
  nowait = false,
}

return M
