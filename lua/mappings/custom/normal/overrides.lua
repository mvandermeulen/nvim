--[[
-- Mappings: Normal - Overrides
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-25
--]]


local map = require('helpers.utils.keys').safe_keymap_set

local function dfo(desc)
  if desc then
    return { noremap = true, silent = true, desc = desc }
  else
    return { noremap = true, silent = true }
  end
end

-- diagnostic
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go { severity = severity }
  end
end

map('n', 'K', vim.lsp.buf.hover, {}) -- This will allow us to Shift-K and get the Hover property to show

--- Always center Ctrl+U/D ---
map("n", "<C-u>", "<C-u>zz", dfo())
map("n", "<C-d>", "<C-d>zz", dfo())

map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })
map("n", "]D", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[D", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
map('n', ']j', '<C-i>zz', { silent = true, noremap = true, desc = 'Next Jump'})
map('n', '[j', '<C-o>zz', { silent = true, noremap = true, desc = 'Previous Jump'})


map('n', '<Tab>', '<C-w>w', { silent = true, noremap = true })
-- vim.api.nvim_set_keymap('n', '<bs>', '<c-^\'”zz', { silent = true, noremap = true })

-- Scroll with ',' and 'm', moving the marker key to 'M'
-- vim.keymap.map('', ',', '<C-u>', { noremap = true })
-- vim.keymap.map('', 'm', '<C-d>', { noremap = true })
-- vim.keymap.map('', 'M', 'm', { noremap = true })

-- vim.keymap.map('n', '<CR>', '<Cmd>noh<CR><Bar><Cmd>echon<CR><CR>', { silent = true, noremap = true })
map('n', '<c-c><c-q>', ':qa!<cr>', { silent = true, noremap = true })


-- Clear search with <esc>
-- vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })

-- vim.keymap.set('n', '<Esc>', function()
-- 	vim.cmd.nohlsearch()
-- 	vim.cmd.fclose({ bang = true })
-- 	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', false)
-- end, { silent = true })

-- LSP
-- neovim/runtime/lua/vim/lsp.lua > lsp._set_defaults
-- vim.keymap.set('n', 'K', '<Cmd>normal! K<CR>', { desc = 'K (Dummy to disable builtin behavior)' })
-- vim.keymap.set('n', 'gr', '<Nop>')
-- local vlb = vim.lsp.buf
-- map('n', 'grt', vlb.type_definition, { desc = 'LSP: Go to type definition' })
-- map('n', 'gri', vlb.implementation, { desc = 'LSP: Go to implementation' })
-- map('n', 'grd', vlb.declaration, { desc = 'LSP: Go to Declaration' })
-- map('n', 'grh', vlb.typehierarchy, { desc = 'LSP: Type hierarchy' })
-- map('n', 'grc', vlb.incoming_calls, { desc = 'LSP: Incoming calls' })
-- map('n', 'grg', vlb.outgoing_calls, { desc = 'LSP: Outgoing calls' })
-- map('n', 'grf', vlb.format, { desc = 'LSP: Format' })
-- map('n', '<M-e>', vim.diagnostic.open_float, { desc = 'LSP: Show diagnostics' })
-- map('n', 'grwa', vlb.add_workspace_folder, { desc = 'LSP: Add folder to workspace' })
-- map('n', 'grwr', vlb.remove_workspace_folder, { desc = 'LSP: Remove folder from workspace' })
-- map('n', 'grww', function()
-- 	vim.notify(vim.inspect(vlb.list_workspace_folders()))
-- end, { desc = 'LSP: List folders of workspaceh' })
-- map('n', 'grl', vim.diagnostic.setloclist, { desc = 'LSP: Set diagnostics into loclist' })

-- Make many of the jump commands also center on search term
map("n", "n", "nzz", { noremap = true })
map("n", "N", "Nzz", { noremap = true })
-- map("n", "<C-o>", "<C-o>zz", { noremap = true })
-- map("n", "<C-i>", "<C-i>zz", { noremap = true })
map("n", "*", "*zz", { noremap = true })
map("n", "#", "#zz", { noremap = true })


-- map("n", "<leader>gn", "]s")
-- map("n", "<leader>gp", "[s")
-- map("n", "<leader>gg", "zg")
-- map("n", "<ESC>", "<cmd> :noh <CR>")
-- map("x", "p", "P")

