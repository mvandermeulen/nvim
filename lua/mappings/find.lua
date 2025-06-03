--[[
-- Mappings: Find
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

return {
  -- { '<leader>fff', "<cmd>lua require'telescope.builtin'.find_files({ find_command = {'fd', '--hidden', '--type', 'file', '--follow'}})<cr>", desc = 'Find File' },
  { '<leader>fff', '<cmd>lua require("helpers.plugins.telescope").find_files()<CR>', desc = 'Find File' },
  { '<leader>ffg', '<cmd>lua require("helpers.plugins.telescope").live_grep()<CR>', desc = 'Live Grep' },
}
