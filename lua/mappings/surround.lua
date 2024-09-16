local M = {}

M.mappings = {
  name = 'Surround',
  ['.'] = { "<cmd>lua require('surround').repeat_last()<cr>", 'Repeat' },
  a = { "<cmd>lua require('surround').surround_add(true)<cr>", 'Add' },
  d = { "<cmd>lua require('surround').surround_delete()<cr>", 'Delete' },
  r = { "<cmd>lua require('surround').surround_replace()<cr>", 'Replace' },
  q = { "<cmd>lua require('surround').toggle_quotes()<cr>", 'Quotes' },
  b = { "<cmd>lua require('surround').toggle_brackets()<cr>", 'Brackets' },
}

M.options = {
  mode = "n",
  silent = true,
  noremap = true,
  prefix = "<leader>/",
  nowait = true,
}

return M
