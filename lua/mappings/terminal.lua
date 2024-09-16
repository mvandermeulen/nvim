local M = {}

M.mappings = {
  ["name"] = "Terminal",
  -- ["name"] = " Terminal",
  ['1'] = { ':1ToggleTerm<cr>', '1' },
  ['2'] = { ':2ToggleTerm<cr>', '2' },
  ['3'] = { ':3ToggleTerm<cr>', '3' },
  ['4'] = { ':4ToggleTerm<cr>', '4' },
  c = { "<cmd>:ToggleTermSendCurrentLine<cr>", 'Send Current Line' },
  f = { "<CMD>ToggleTerm direction=float<CR>", " Float" },
  h = { 'Htop' },
  H = { "<CMD>ToggleTerm size=10 direction=horizontal<CR>", " Horizontal" },
  i = { "<cmd>ToggleTasksInfo<cr>", 'Tasks Info' },
  p = { ' Python' },
  n = { 'Node' },
  s = { "<cmd>:ToggleTermSendVisualSelection<cr>", 'Send Selection' },
  t = { "<cmd>Telescope toggletasks spawn<cr>", 'Spawn Task' },
  T = { "<cmd>Telescope toggletasks select<cr>", 'Select Task' },
  u = { 'NCDU' },
  v = { "<CMD>ToggleTerm size=80 direction=vertical<CR>", " Vertical" },
}

M.options = {
  mode = "n",
  silent = true,
  noremap = true,
  prefix = "<leader>t",
  nowait = true,
}

return M
