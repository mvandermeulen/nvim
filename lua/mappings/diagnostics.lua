local M = {}

M.mappings = {
  name = 'Diagnostics',
  d = { '<cmd>Trouble document_diagnostics<cr>', 'Document Diagnostic' },
  i = { '<cmd>LspInstallInfo<cr>', 'LSP Install Info' },
  l = { '<cmd>Trouble loclist<cr>', 'Loclist' },
  q = { '<cmd>Trouble quickfix<cr>', 'Quickfix' },
  r = { '<cmd>Trouble lsp_references<cr>', 'LSP References' },
  s = { "<cmd>lua _G.server:vdm_start_server()<cr>", 'Start Server' },
  t = { '<cmd>TodoTrouble<cr>', 'Todos' },
  T = { '<cmd>TroubleToggle<cr>', 'Toggle Trouble' },
  w = { '<cmd>Trouble workspace_diagnostics<cr>', 'Workspace Diagnostics' },
}

return M

-- vim:ft=lua

