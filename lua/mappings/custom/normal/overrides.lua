--[[
-- Mappings: Normal - Overrides
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-16
--]]



---------- Helpers ----------
local keys = require('helpers.utils.keys')
local map = keys.safe_keymap_set
local kmo = keys.kmo


-- diagnostic
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go { severity = severity, border = "rounded", wrap = true, float = true }
  end
end

-- map('n', 'K', vim.lsp.buf.hover, {}) -- This will allow us to Shift-K and get the Hover property to show

--- Always center Ctrl+U/D ---
map("n", "<C-u>", "<C-u>zz", kmo())
map("n", "<C-d>", "<C-d>zz", kmo())

-- bufnnoremap("]W", function()
--   vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
-- end, 'go-to-next-error')

-- bufnnoremap("[W", function()
--   vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
-- end, 'go-to-previous-error')

-- bufnnoremap("]w", function()
--   vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
-- end, 'go-to-next-warning')

-- bufnnoremap("[w", function()
--   vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
-- end, 'go-to-previous-warning')
map("n", "[q", vim.cmd.cprev, kmo('Prev Quickfix'))
map("n", "]q", vim.cmd.cnext, kmo('Next Quickfix'))
map("n", "]d", diagnostic_goto(true), kmo('Next Diagnostic'))
map("n", "[d", diagnostic_goto(false), kmo('Prev Diagnostic'))
map("n", "]e", diagnostic_goto(true, "ERROR"), kmo('Next Error'))
map("n", "[e", diagnostic_goto(false, "ERROR"), kmo('Prev Error'))
map("n", "]w", diagnostic_goto(true, "WARN"), kmo('Next Warning'))
map("n", "[w", diagnostic_goto(false, "WARN"), kmo('Prev Warning'))
map('n', ']j', '<C-i>zz', kmo('Next Jump'))
map('n', '[j', '<C-o>zz', kmo('Prev Jump'))


-- NOTE: Disabled mapping of <Tab> to switch windows
-- map('n', '<Tab>', '<C-w>w', { silent = true, noremap = true })
-- vim.api.nvim_set_keymap('n', '<bs>', '<c-^\'”zz', { silent = true, noremap = true })

-- Scroll with ',' and 'm', moving the marker key to 'M'
-- vim.keymap.map('', ',', '<C-u>', { noremap = true })
-- vim.keymap.map('', 'm', '<C-d>', { noremap = true })
-- vim.keymap.map('', 'M', 'm', { noremap = true })

-- vim.keymap.map('n', '<CR>', '<Cmd>noh<CR><Bar><Cmd>echon<CR><CR>', { silent = true, noremap = true })
map('n', '<c-c><c-q>', ':qa!<cr>', kmo('Quit All'))


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
map("n", "n", "nzz", kmo())
map("n", "N", "Nzz", kmo())
-- map("n", "<C-o>", "<C-o>zz", { noremap = true })
-- map("n", "<C-i>", "<C-i>zz", { noremap = true })
map("n", "*", "*zz", kmo())
map("n", "#", "#zz", kmo())
map("n", "0", "^", kmo())
map("n", "^", "0", kmo())


-- map("n", "<leader>gn", "]s")
-- map("n", "<leader>gp", "[s")
-- map("n", "<leader>gg", "zg")
-- map("n", "<ESC>", "<cmd> :noh <CR>")
-- map("x", "p", "P")

-------------------------------
-- Standard Keys
-------------------------------
-- map("n", ";", ":", kmo()) -- Remap semicolon for commands
-- map("n", ";;", ";", kmo()) -- Remap semicolon for commands
-- map("n", "0", "^", kmo()) -- use 0 to go to first char of line
map("n", "n", "nzz", kmo()) -- center search results
map("n", "N", "Nzz", kmo()) -- center search results
-- map("n", "k", "v:count == 0 ? 'gk' : 'k'", expr_options) -- Deal with visual line wraps
-- map("n", "j", "v:count == 0 ? 'gj' : 'j'", expr_options) -- Deal with visual line wraps
-- map("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>", kmo()) -- Cancel search highlighting with ESC
map("n", "m/", "<cmd>MarksListAll<CR>", kmo()) -- Marks from all opened buffers
map("n", "U", "<esc><C-r>", kmo('Redo'))


-------------------------------
-- Arrow Keys
-------------------------------
map("n", "<Left>", ":vertical resize +2<CR>", kmo())
map("n", "<Right>", ":vertical resize -2<CR>", kmo())
map("n", "<Up>", ":resize -2<CR>", kmo())
map("n", "<Down>", ":resize +2<CR>", kmo())



