--[[
-- Mappings: Normal - Leader
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-25
--]]



local map = require('helpers.utils.keys').safe_keymap_set

-- map('n', '<leader>-', function()
-- 	vim.cmd('Explore')
-- end, { desc = 'Explorer' })


-- copy current file name
-- vim.keymap.set(
--   "n",
--   "<leader>cf",
--   '<cmd>let @+ = fnamemodify(expand("%:p"), ":.")<cr>',
--   { desc = "Copy current file path" }
-- )

-- map('n', '<leader>cr', ':<C-u>%s///g<Left><Left>', { desc = 'Start substitution' })
-- map('x', '<leader>cr', ":<C-u>'<,'>s///g<Left><Left>", { desc = 'Start substitution' })


-- This will show us the Directory Strcuture
-- vim.keymap.set('n', '<leader>e', ':Neotree filesystem reveal left<CR>', { desc = 'Fil[E] Tree' })

-- new file
-- vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

--keywordprg
-- vim.keymap.set("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })


-- highlights under cursor
-- vim.keymap.set("n", "<leader>ni", vim.show_pos, { desc = "Inspect Pos" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
-- vim.keymap.set(
--   "n",
--   "<leader>nr",
--   "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
--   { desc = "Redraw / Clear hlsearch / Diff Update" }
-- )

-- blackhole delete
map({ "n", "v" }, "<leader>D", '"_dP', { desc = 'Blackhole Delete'})

-- Escape search highlight
-- vim.keymap.set("n", "<leader>s", "<cmd>set hlsearch!<CR>")

-- vim.keymap.set('n', '<Space>am', '<CMD>messages<CR>', { desc = 'History of messages' })

-- vim.keymap.set("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
-- vim.keymap.set("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })

-- quit
-- vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- Helpful for copy and paste
-- map('x', '<leader>p', '"_dP')
-- map('n', '<leader>y', '"+y')
-- map('v', '<leader>y', '"+y')
-- map('n', '<leader>Y', '"+Y')
-- map('n', '<leader>d', '"_d')
-- map('v', '<leader>d', '"_d')







-- TOGGLES
--------------------------------


-- map('n', '<Space>tw', function()
-- 	vim.opt.wrap = not vim.o.wrap
-- 	if vim.o.wrap then
-- 		vim.notify('Wrap enabled')
-- 	else
-- 		vim.notify('Wrap disabled')
-- 	end
-- end, { desc = 'Toggle wrap' })

-- map('n', '<Space>tS', function()
-- 	vim.opt.spell = not vim.o.spell
-- 	if vim.o.spell then
-- 		vim.notify('Spellcheck enabled')
-- 	else
-- 		vim.notify('Spellcheck disabled')
-- 	end
-- end, { desc = 'Toggle spell check' })

-- map('n', '<Space>ty', function()
-- 	vim.opt.cursorline = not vim.o.cursorline
-- end, { desc = 'Toggle cursorline' })

-- map('n', '<Space>tY', function()
-- 	vim.opt.cursorcolumn = not vim.o.cursorcolumn
-- end, { desc = 'Toggle cursorcolumn' })

-- map('n', '<Space>tL', function()
-- 	vim.opt.list = not vim.o.list
-- end, { desc = 'Toggle list' })

-- map('n', '<Space>ts', function()
-- 	vim.o.laststatus = vim.o.laststatus == 0 and 3 or 0
-- end, { desc = 'Toggle statusline' })

-- map('n', '<Space>tn', function()
-- 	vim.opt.number = not vim.o.number
-- end, { desc = 'Toggle number' })

-- map('n', '<Space>tN', function()
-- 	vim.opt.relativenumber = not vim.o.relativenumber
-- end, { desc = 'Toggle relnum' })

-- map('n', '<Space>tc', function()
-- 	if vim.o.clipboard == '' then
-- 		vim.o.clipboard = 'unnamedplus'
-- 	else
-- 		vim.o.clipboard = ''
-- 	end
-- 	vim.notify('clipboard=' .. vim.o.clipboard)
-- end, { desc = 'Toggle clipboard' })

-- local vedit_default
-- vim.keymap.set('n', '<leader>av', function()
--   if not vedit_default then
--     vedit_default = vim.o.virtualedit
--   end
--   if vim.o.virtualedit == vedit_default then
--     vim.opt.virtualedit = 'all'
--   else
--     vim.opt.virtualedit = vedit_default
--   end
--   vim.notify('virtualedit=' .. vim.o.virtualedit)
-- end, { desc = '' })

-- local vt_bak
-- vim.keymap.set('n', '<leader>lT', function()
--   vt_bak = vt_bak == nil and vim.diagnostic.config().virtual_text or vt_bak
--   if vim.diagnostic.config().virtual_text then
--     vim.diagnostic.config({ virtual_text = false })
--   else
--     vim.diagnostic.config({ virtual_text = vt_bak })
--   end
-- end, { desc = 'LSP: Toggle virtual text of diagnotics' })

