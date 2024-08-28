local M = {}

M.mappings = {
  name = ' Workspaces',
  c = { '<cmd>lua require("persistence").stop()<cr>', 'Cancel Persistence' },
  l = { '<cmd>lua require("sessions").load()<cr>', ' Load Session' },
  L = { '<cmd>lua require("persistence").load({ last = true })<cr>', ' Latest Persisted' },
  s = { '<cmd>lua require("sessions").save()<cr>', ' Save Session' },
  S = { '<cmd>lua require("sessions").stop_autosave()<cr>', 'Stop Session' },
  p = { "<cmd>lua require('telescope').extensions.projects.projects()<cr>", 'Projects' },
  P = { '<cmd>lua require("persistence").load()<cr>', '  Persisted' },
  o = { '<cmd>lua require("persistence").select()<cr>', '  Open Persisted' },
}

--[[ M.options = { ]]
--[[   mode = "n", ]]
--[[   silent = true, ]]
--[[   noremap = true, ]]
--[[   prefix = "<leader>/", ]]
--[[   nowait = true, ]]
--[[ } ]]

return M
