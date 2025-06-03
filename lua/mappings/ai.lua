--[[
-- Mappings: AI
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

return {
  { '<leader>ACn', '<cmd>AvanteConflictNextConflict<CR>', desc = 'Avante: Next Conflict' },
  { '<leader>ACp', '<cmd>AvanteConflictPrevConflict<CR>', desc = 'Avante: Prev Conflict' },
  { '<leader>ASo', '<cmd>AvanteSwitchProvider openai<CR>', desc = 'Avante Use: OpenAI' },
  { '<leader>ASa', '<cmd>AvanteSwitchProvider claude<CR>', desc = 'Avante Use: Claude' },
  { '<leader>ASc', '<cmd>AvanteSwitchProvider copilot<CR>', desc = 'Avante Use: Copilot' },
  { '<leader>ASg', '<cmd>AvanteSwitchProvider gemini<CR>', desc = 'Avante Use: Gemini' },
  { '<leader>AR', '<cmd>AvanteShowRepoMap<CR>', desc = 'Avante: Repo Map' },
  { '<leader>At', "<cmd>AvanteToggle<CR>", desc = "Avante: Toggle" },
  { '<leader>Af', "<cmd>AvanteFocus<CR>", desc = "Avante: Focus" },
  { '<leader>Ac', "<cmd>AvanteChat<CR>", desc = "Avante: Chat" },
  { '<leader>Ab', "<cmd>AvanteBuild<CR>", desc = "Avante: Build" },
  { '<leader>A<BS>', '<cmd>AvanteClear<CR>', desc = "Avante: Clear" },
  { '<M-.>', "<cmd>AvanteToggle<CR>", desc = "Avante: Toggle" },
}
