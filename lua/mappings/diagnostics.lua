-- local M = {}
-- M.mappings = {
--   name = 'Diagnostics',
--   d = { '<cmd>Trouble document_diagnostics<cr>', 'Document Diagnostic' },
--   i = { '<cmd>LspInstallInfo<cr>', 'LSP Install Info' },
--   l = { '<cmd>Trouble loclist<cr>', 'Loclist' },
--   q = { '<cmd>Trouble quickfix<cr>', 'Quickfix' },
--   r = { '<cmd>Trouble lsp_references<cr>', 'LSP References' },
--   s = { "<cmd>lua _G.server:vdm_start_server()<cr>", 'Start Server' },
--   t = { '<cmd>TodoTrouble<cr>', 'Todos' },
--   T = { '<cmd>TroubleToggle<cr>', 'Toggle Trouble' },
--   w = { '<cmd>Trouble workspace_diagnostics<cr>', 'Workspace Diagnostics' },
-- }

--[[
-- Mappings: Diagnostics
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

return {
  { '<leader>dd', '<cmd>Trouble diagnostics<cr>', desc = 'Document Diagnostic' },
  -- { '<leader>di', '<cmd>LspInfo<cr>', desc = 'LSP Info' },
  { '<leader>dl', vim.diagnostic.open_float, desc = 'Line Diagnostics' },
  { '<leader>dL', '<cmd>Trouble loclist<cr>', desc = 'Loclist' },
  { '<leader>dq', '<cmd>Trouble quickfix<cr>', desc = 'Quickfix' },
  { '<leader>dr', '<cmd>Trouble lsp_references<cr>', desc = 'LSP References' },
  -- { '<leader>ds', "<cmd>lua _G.my.helpers.server:vdm_start_server()<cr>", desc = 'Start Server' },
  { '<leader>dt', '<cmd>TodoTrouble<cr>', desc = 'Todos' },
  { '<leader>dT', '<cmd>TroubleToggle<cr>', desc = 'Toggle Trouble' },
  { '<leader>do', '<cmd>lua require("snacks").diagnostics.toggle()<cr>', desc = 'Toggle Diagnostics' },
  { '<leader>dp', '<cmd>lua require("snacks").profiler.toggle()<cr>', desc = 'Toggle Profiler' },
  -- { '<leader>dw', '<cmd>Trouble workspace_diagnostics<cr>', desc = 'Workspace Diagnostics' },
  -- { '<leader>dx', '<cmd>LspRestart<cr>', desc = 'LSP Restart' },
}

