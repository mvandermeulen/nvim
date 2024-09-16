local M = {}

M.mappings = {
  name = 'Focus',
  z = { ':ZenMode<cr>', 'Toggle Zen Mode' },
  t = { ':Twilight<cr>', 'Toggle Twilight' },
}

M.options = {
  mode = "n",
  silent = true,
  noremap = true,
  prefix = "<leader>/",
  nowait = true,
}

return M
