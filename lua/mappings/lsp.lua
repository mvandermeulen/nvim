-- local M = {}
-- M.setup = function(client, buffer)
--   local mappings = {
--     ["name"] = " LSP [" .. string.format(" %s", client.name) .. "]",
--     ["b"] = {
--       ["name"] = " Actions",
--       ["K"] = { "<CMD>lua lsb.hover()<CR>", " Hover" },
--       ["c"] = { "<CMD>lua require('telescope.builtin').lsp_code_actions()<CR>", " Code action" },
--       ["f"] = { "<CMD>lua lsb.formatting()<CR>", "ﯕ Format" },
--       ["r"] = { "<CMD>lua require('configs.lsp.handlers.rename').lsp_rename()<CR>", "ﯕ Format" },
--       ["F"] = { "<CMD>lua lsb.formatting_seq_sync()<CR>", "ﯕ Format Seq" },
--       ["T"] = { "<CMD>ToggleAutoFormat<CR>", "ﯕ  Auto formatting" },
--     },
--     ["d"] = {
--       ["name"] = " Diagnostics",
--       ["e"] = { "<CMD>lua diagnostic.open_float()<CR>", "ﭧ Diagnostics" },
--       ["["] = { "<CMD>lua diagnostic.goto_prev()<CR>", "ﭧ Previous errors" },
--       ["]"] = { "<CMD>lua diagnostic.goto_next()<CR>", "ﭧ Next errors" },
--       ["q"] = { "<CMD>lua diagnostic.setloclist()<CR>", " Set loclist" },
--     },
--     ["g"] = {
--       ["name"] = " Definitions",
--       ["D"] = { "<CMD>lua lsb.declaration()<CR>", " Goto declaration" },
--       ["d"] = { "<CMD>lua lsb.definition()<CR>", " Goto definiton" },
--       ["s"] = { "<CMD>lua lsb.signature_help()<CR>", "ﲀ Signature" },
--       ["i"] = { "<CMD>lua lsb.implementation()<CR>", "בּ Implementation" },
--       ["I"] = { "<CMD>lua require('telescope.builtin').lsp_implementations()<CR>", "בּ Implementation" },
--       ["t"] = { "<CMD>lua lsb.type_definition()<CR>", " Type definition" },
--       ["r"] = { "<CMD>lua lsb.references()<CR>", " References" },
--     },
--     i = { '<cmd>LspInfo<cr>', 'Info' },
--     ["w"] = {
--       ["name"] = " Workspaces",
--       ["a"] = { "<CMD>lua lsb.add_workspace_folder()<CR>", " Add workspace" },
--       ["r"] = { "<CMD>lua lsb.remove_workspace_folder()<CR>", " Remove workspace" },
--       ["l"] = { "<CMD>lua notify(inspect(lsb.list_workspace_folders()))<CR>", " Workspaces" },
--     },
--   }
-- end

--[[
-- Mappings: LSP
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

-- LSP Marks: <leader>lm
-- wk.add({
--   { "<leader>lmt", "<CMD>lua require('lspmark.bookmarks').toggle_bookmark({with_comment=false})<CR>", desc = "Toggle Mark" },
--   { "<leader>lmc", "<CMD>lua require('lspmark.bookmarks').toggle_bookmark({with_comment=true})<CR>", desc = "Toggle Comment Mark" },
--   { "<leader>lmm", "<CMD>lua require('lspmark.bookmarks').modify_comment()<CR>", desc = "Modify Comment" },
--   { "<leader>lms", "<CMD>lua require('lspmark.bookmarks').show_comment()<CR>", desc = "Show Comment" },
-- })

return {
  { '<leader>lA', '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', desc = 'Add Workspace Folder' },
  { '<leader>lD', '<cmd>lua vim.lsp.buf.declaration()<cr>', desc = 'Go To Declaration' },
  { '<leader>lF', '<cmd>LspToggleAutoFormat<cr>', desc = 'Toggle Autoformat' },
  { '<leader>lI', '<cmd>lua vim.lsp.buf.implementation()<cr>', desc = 'Show implementations' },
  { '<leader>lK', '<cmd>lua vim.lsp.buf.hover()<cr>', desc = 'Hover Commands' },
  { '<leader>lL', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>', desc = 'List Workspace_Folders' },
  { '<leader>lR', '<cmd>lua vim.lsp.buf.rename()<cr>', desc = 'Rename' },
  { '<leader>lS', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', desc = 'Workspace Symbols' },
  { '<leader>lW', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', desc = 'Remove Workspace Folder' },
  { '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<cr>', desc = 'Code Action' },
  { '<leader>ld', '<cmd>lua vim.lsp.buf.definition()<cr>', desc = 'Go To Definition' },
  { '<leader>le', '<cmd>Telescope diagnostics bufnr=0<cr>', desc = 'Document Diagnostics' },
  { '<leader>lf', '<cmd>lua vim.lsp.buf.formatting()<cr>', desc = 'Format' },
  { '<leader>lh', '<cmd>lua vim.lsp.buf.signature_help()<cr>', desc = 'Signature Help' },
  { '<leader>lj', '<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>', desc = 'Next Diagnostic in Buffer' },
  { '<leader>lk', '<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>', desc = 'Prev Diagnostic in Buffer' },
  { '<leader>ll', '<cmd>lua vim.diagnostic.open_float()<CR>', desc = 'Line diagnostics' },
  { '<leader>ln', '<cmd>lua vim.diagnostic.goto_next()<cr>', desc = 'Next Diagnostic' },
  { '<leader>lp', '<cmd>lua vim.diagnostic.goto_prev()<cr>', desc = 'Prev Diagnostic' },
  { '<leader>lq', '<cmd>lua vim.diagnostic.set_loclist()<cr>', desc = 'Quickfix' },
  { '<leader>lr', '<cmd>lua vim.lsp.buf.references()<cr>', desc = 'References' },
  { '<leader>ls', '<cmd>Telescope lsp_document_symbols<cr>', desc = 'Document Symbols' },
  { '<leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<cr>', desc = 'Type Definition' },
  { '<leader>lw', '<cmd>Telescope diagnostics<CR>', desc = 'Workspace Diagnostics' },
  { '<leader>lcr', '<cmd>LspRestart<cr>', desc = 'LSP: Restart' },
  { '<leader>lcs', '<cmd>LspStop<cr>', desc = 'LSP: Stop' },
  { '<leader>lci', '<cmd>LspInfo<cr>', desc = 'LSP: Info' },
  { '<leader>lcS', '<cmd>LspStart<cr>', desc = 'LSP: Start' },
  { '<leader>lcl', '<cmd>LspLog<cr>', desc = 'LSP: Logs' },
  { '<leader>l_', '<cmd>LspInfo<cr>', desc = 'LSP: Info' },
  { '<leader>l-', '<cmd>LspLog<cr>', desc = 'LSP: Logs' },
  -- LSP Python: <leader>lP
  { "<leader>lPg", function() require("helpers.lang.pyenv").get_current_venv(true) end, desc = "Get Current Venv" },
  { "<leader>lPv", function() require("helpers.lang.pyenv").select_venv() end, desc = "Select Venv" },
  { "<leader>lPl", function() require("helpers.lang.pyenv").set_venv(vim.fn.getcwd()) end, desc = "Set Venv to Local Directory" },
  { "<leader>lPh", function() require("helpers.lang.pyenv").set_venv(os.getenv("HOME")) end, desc = "Set Venv to Home Directory" },
}
