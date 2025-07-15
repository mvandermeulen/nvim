--[[
-- Mappings: Normal - Leader
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-25
--]]


---------- Helper Functions ----------
local keys = require('helpers.utils.keys')
local function map(key, action, desc)
  keys:nlmap(key, action, desc)
  -- if type(action) == 'function' then
  -- end
end



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



-------------------------------
-- Leader Keys
-------------------------------

-- NOTE: These should be mapped in the which-key plugin configuration

-- Easier save/open/close
--keymap("n", "<Leader>w", ":w<CR>")                                      -- write with w
--keymap("n", "<Leader>q", ":q<CR>")                                      -- quit with q
--keymap("n", "<Leader>qq", ":q!<CR>")                                    -- space + qq to force quit
--map('n', '<leader>j', [[<cmd>m-2|j<cr>]])                                 -- Join line above at end of current
-- map("n", "<leader><leader>M", ":lua require'telegraph'.telegraph({how='tmux_popup', cmd='man '})<Left><Left><Left>", kmo(''))
-- Map <leader>mr in normal mode to the ranger_popup_in_tmux function
map("n", "<leader>mr", "<Cmd>lua require('helpers.user.shell').ranger_popup_in_tmux()<CR>", kmo('Ranger in Tmux'))
-- map("n", "<leader>mp", "<Cmd>lua require('helpers.precognition').toggle()<CR>", kmo('Toggle Precognition'))

map("n", "<leader>pj[", "<cmd>Portal jumplist backward<cr>", kmo('Portal Jumplist Backward'))
map("n", "<leader>pj]", "<cmd>Portal jumplist forward<cr>", kmo('Portal Jumplist Forward'))

-- map("n", "<leader>pj[", "<cmd>Portal jumplist backward<cr>", kmo('Portal Jumplist Backward'))
-- map("n", "<leader>pj]", "<cmd>Portal jumplist forward<cr>", kmo('Portal Jumplist Forward'))

map("n", "<leader><S-Tab>", ":BufferLineCyclePrev<CR>", kmo('Previous Buffer'))
map("n", "<leader><Tab>", ":BufferLineCycleNext<CR>", kmo('Next Buffer'))





-- TOGGLES
--------------------------------

---------- Editor Tools ----------
----- <leader>e
----- Mappings: k, K, G
map("n", "<leader>ek", function() require("helpers.user.tools").cursor_lock(true) end, { noremap = true, silent = true, desc = 'Cursor LocK' })
map("n", "<leader>eK", function() require("helpers.user.tools").cursor_lock(false) end, { noremap = true, silent = true, desc = 'Cursor LocK Disable' })
map("n", "<leader>eG", function() require("helpers.user.tools").open_log("NvimLog") end, { noremap = true, silent = true, desc = 'Open Neovim Logs' })

---------- Diagnostic Tools ----------
----- <leader>d
----- Mappings: c, C
map("n", "<leader>dc", function() require("helpers.user.tools").cursor_diagnostics() end, { noremap = true, silent = true, desc = 'Copy Diagnostics [Cursor]' })
map("n", "<leader>dC", function() require("helpers.user.tools").all_diagnostics() end, { noremap = true, silent = true, desc = 'Copy Diagnostics [All]' })

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

-- Set up keymaps
vim.api.nvim_set_keymap('n', '<leader>we', ':lua add_snippet_normal()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>we', ':<C-U>lua add_snippet_visual()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>wr', ':lua view_snippets()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>wq', ':lua clear_snippets()<CR>', { noremap = true, silent = true })
