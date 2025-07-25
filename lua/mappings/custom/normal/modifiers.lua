--[[
-- Mappings: Normal - Modifiers
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-15
--]]


---------- Helpers ----------
local keys = require('helpers.utils.keys')
local map = keys.safe_keymap_set
local kmo = keys.kmo


--------------------
-- Ctrl Modifier
--------------------

map("n", "<C-c><C-c>", function() require('snacks').bufdelete() end, kmo('Delete Buffer'))
map("n", "<C-Q>", "<cmd>:NvimTreeClose<cr><cmd>:qa<cr>", kmo('Quit All'))
map("n", "<C-s>", "<CMD>:update<cr><esc>", kmo('Save')) -- write with w
map("n", "<C-t>", "<CMD>lua require('telescope').extensions.tele_tabby.list()<CR>", kmo()) -- write with w

map("n", "<C-\\>", "<Plug>(comment_toggle_linewise_current)", kmo('Comment Line'))
map("n", "<C-\">",  function() require("helpers.ui.windows").zoom.toggle() end, kmo('Toggle Zoom'))
map("n", "<C-CR>", "<CMD>:NvimTreeToggle<CR>", kmo('Explorer'))
-- <C-;>: Copilot Chat Toggle
map({ "i", "x", "n", "s" }, "<C-;>", "<cmd>CopilotChatToggle<cr>", kmo('Copilot Chat: Toggle'))


-- <C-->: UNUSED
-- map("n", "<C-->", "<cmd>Cheatsheet<cr>", kmo('Cheatsheet'))

-- <C-Esc>: UNUSED
-- map("n", "<C-Esc>", "<cmd>:YankBank<cr>", kmo('YankBank'))

-- <C-/>: FZF Document Symbols
-- map("n", "<C-/>", "", kmo())

-- <C-.>: FZF Oldfiles
-- map("n", "<C-.>", "", kmo())

-- <C-:>: UNUSED
-- map("n", "<C-:>", "", kmo())

-- <C-'> is used by FZF Workspace Symbols
-- map("n", "<C-'>", "", kmo()) -- write with w

-- <C-[> is Copilot Chat Actions -- REMOVED AS MISTAKEN FOR ESCAPE

-- <C-]> is FZF Buffers
-- map("n", "<C-_>",'<CMD>lua require("arrow.persist").toggle<CR>', kmo())
-- vim.api.nvim_set_keymap('n','<C-\\>',"<Plug>(comment_toggle_linewise_current)", kmo())
-- map("n", "<C-]>", "", kmo())
-- map("n", "<C-/>", "<Plug>(comment_toggle_linewise_current)", kmo(''))

-- : UNUSED

--------------------
-- Ctrl + Shift Modifier
--------------------

-- vim.keymap.set('n', '<C-S-Tab>', 'gT', { remap = true, silent = true, desc = 'Alias for `gT`' })


--------------------
-- Meta Modifier
--------------------


-- <M-.> is Avante Ask
map({ "i", "x", "n", "s"}, "<M-.>", "<cmd>AvanteToggle<CR>", kmo('Avante: Toggle'))

-- <M-,>: Copilot Chat Prompt Actions
-- map("n", "<M-,>", "<CMD>lua require('helpers.user.notes').record_was_doing()<CR>", kmo())

-- <M-CR>: UNUSED
-- <M-CR> is Telescope Smart Open
-- map("n", "<M-CR>", function () require("telescope").extensions.smart_open.smart_open() end, kmo('Smart Open'))

-- tab movement
map('n', ']<M-t>', vim.cmd.tabnext, kmo('Next Tab'))
map('n', '[<M-t>', vim.cmd.tabprevious, kmo('Previous Tab'))

-- <M-m>: UNUSED
-- vim.keymap.set("n", "<M-m>", "<C-W>x", kmo('Swap Window')) -- swap window


--------------------
-- Meta + Shift Modifier
--------------------

-- Window swapping
map("n", "<M-S-h>", "<C-w>h<C-w>x", kmo('Swap Window Left'))
map("n", "<M-S-j>", "<C-w>j<C-w>x", kmo('Swap Window Below'))
map("n", "<M-S-k>", "<C-w>k<C-w>x", kmo('Swap Window Above'))
map("n", "<M-S-l>", "<C-w>l<C-w>x", kmo('Swap Window Right'))


--------------------
-- Shift Modifier
--------------------

map("n", "<S-Right>", ":tabnext<CR>", kmo('Next Tab'))
map("n", "<S-Left>", ":tabprev<CR>", kmo('Previous Tab'))
map("n", "<S-Up>", ":BufferLineCyclePrev<CR>", kmo('Previous Buffer'))
map("n", "<S-Down>", ":BufferLineCycleNext<CR>", kmo('Next Buffer'))

map("n", "<S-L>", ":tabnext<CR>", kmo('Next Tab'))
map("n", "<S-H>", ":tabprev<CR>", kmo('Previous Tab'))

map("n", "<S-CR>w'", "<CMD>ReplaceInSingleQuotesWord<CR>", kmo('Wrap in Single Quotes'))
map("n", "<S-CR>W'", "<CMD>ReplaceInSingleQuotesNonWhitespaceWord<CR>", kmo('Wrap WORD in Single Quotes'))
map("n", "<S-CR>w\"", "<CMD>ReplaceInDoubleQuotesWord<CR>", kmo('Wrap in Double Quotes'))
map("n", "<S-CR>W\"", "<CMD>ReplaceInDoubleQuotesNonWhitespaceWord<CR>", kmo('Wrap WORD in Double Quotes'))
map("n", "<S-CR>w[", "<CMD>ReplaceInBracketsWord<CR>", kmo('Wrap in Brackets'))
map("n", "<S-CR>W[", "<CMD>ReplaceInBracketsNonWhitespaceWord<CR>", kmo('Wrap WORD in Brackets'))
map("n", "<S-CR>w(", "<CMD>ReplaceInParenthesesWord<CR>", kmo('Wrap word in Parentheses'))
map("n", "<S-CR>W(", "<CMD>ReplaceInParenthesesNonWhitespaceWord<CR>", kmo('Wrap WORD in Parentheses'))
-- map("n", "<S-CR>wm", "<CMD>MakeWordMarkdownLink<CR>", kmo('Markdown Link'))
-- map("n", "<S-CR>Wm", "<CMD>MakeNonWhitespaceWordMarkdownLink<CR>", kmo('Markdown Link from Non-Whitespace Word'))

-- <S-Space>: Scratchpad Toggle
map("n", "<S-Space>", function() require('snacks').scratch() end, kmo('Scratchpad Toggle'))

-- <S-Esc>: UNUSED

