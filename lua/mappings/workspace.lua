local M = {}

M.mappings = {
  name = ' Workspaces',
  l = { '<cmd>lua require("sessions").load()<cr>', 'Load Session' },
  s = { '<cmd>lua require("sessions").save()<cr>', 'Save Session' },
  S = { '<cmd>lua require("sessions").stop_autosave()<cr>', 'Stop Session' },
  p = { "<cmd>lua require('telescope').extensions.projects.projects()<cr>", 'Projects' },
}

M.options = {
  mode = "n",
  silent = true,
  noremap = true,
  prefix = "<leader>/",
  nowait = true,
}

return M
