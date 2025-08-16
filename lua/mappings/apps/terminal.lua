--[[
-- Mappings: Terminal
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

return {
  { '<leader>at1', ':1ToggleTerm<cr>', desc = '1' },
  { '<leader>at2', ':2ToggleTerm<cr>', desc = '2' },
  { '<leader>at3', ':3ToggleTerm<cr>', desc = '3' },
  { '<leader>at4', ':4ToggleTerm<cr>', desc = '4' },
  { '<leader>atc', "<cmd>:ToggleTermSendCurrentLine<cr>", desc = 'Send Current Line' },
  { '<leader>atf', "<CMD>ToggleTerm direction=float<CR>", desc = "Float" },
  { '<leader>atH', "<CMD>ToggleTerm size=10 direction=horizontal<CR>", desc = "Horizontal" },
  { '<leader>ati', "<cmd>ToggleTasksInfo<cr>", desc = 'Tasks Info' },
  { '<leader>ats', "<cmd>:ToggleTermSendVisualSelection<cr>", desc = 'Send Selection' },
  { '<leader>att', "<cmd>Telescope toggletasks spawn<cr>", desc = 'Spawn Task' },
  { '<leader>atT', "<cmd>Telescope toggletasks select<cr>", desc = 'Select Task' },
  { '<leader>atv', "<CMD>ToggleTerm size=30 direction=vertical<CR>", desc = "Vertical 3rd" },
  { '<leader>atV', "<CMD>ToggleTerm size=50 direction=vertical<CR>", desc = "Vertical Half" },
}
