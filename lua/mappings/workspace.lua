--[[
-- Mappings: Workspace
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

return {
  { '<leader>Wa', '<cmd>SessionStart<cr>', desc = 'Persistence: Start' },
  { '<leader>Wc', '<cmd>SessionStop<cr>', desc = ' Cancel Persistence' },
  { '<leader>Wm', '<cmd>SessionManager<cr>', desc = 'Session Manager' },
  { '<leader>Wd', '<cmd>SessionDelete<cr>', desc = ' Delete Persistence' },
  { '<leader>Wl', '<cmd>lua require("sessions").load()<cr>', desc = ' Load Session' },
  { '<leader>WL', '<cmd>SessionLoadLast<cr>', desc = ' Latest Persisted' },
  { '<leader>Wr', '<cmd>SessionLoad<cr>', desc = ' Resume Persisted (directory based)' },
  { '<leader>Ws', '<cmd>lua require("sessions").save()<cr>', desc = ' Save Session' },
  { '<leader>Wx', '<cmd>lua require("sessions").stop_autosave()<cr>', desc = 'Stop Session' },
  { '<leader>Wp', "<cmd>lua require('telescope').extensions.projects.projects()<cr>", desc = ' Projects' },
  { '<leader>WP', function() require('telescope').extensions.persisted.persisted() end, desc = '  Persisted' },
  { '<leader>Wo', '<cmd>SessionSelect<cr>', desc = '  Open Persisted' },
  { '<leader>WS', '<cmd>SessionSave<cr>', desc = '󰆓 Save Persistence' },
}
