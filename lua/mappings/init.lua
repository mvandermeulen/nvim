--[[
-- Key Mappings
--
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]

default_options = { noremap = true, silent = true }
expr_options = { noremap = true, expr = true, silent = true }

-- Function for make mapping easier.
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-----------------------------------------------
-- Normal Mode
-----------------------------------------------

-------------------------------
-- Standard Keys
-------------------------------

map("n", ";", ":") -- Remap semicolon for commands
map("n", ";;", ";") -- Remap semicolon for commands
map("n", "0", "^") -- use 0 to go to first char of line
map("n", "n", "nzz", default_options) -- center search results
map("n", "N", "Nzz", default_options) -- center search results
map("n", "k", "v:count == 0 ? 'gk' : 'k'", expr_options) -- Deal with visual line wraps
map("n", "j", "v:count == 0 ? 'gj' : 'j'", expr_options) -- Deal with visual line wraps
map("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>", default_options) -- Cancel search highlighting with ESC
-- Resizing panes
map("n", "<Left>", ":vertical resize +1<CR>", default_options)
map("n", "<Right>", ":vertical resize -1<CR>", default_options)
map("n", "<Up>", ":resize -1<CR>", default_options)
map("n", "<Down>", ":resize +1<CR>", default_options)

map("n", "<F13>", ":NvimTreeToggle<cr>", default_options)
map("n", "<F14>", ":Twilight<CR>", default_options)
map("n", "<F16>", ":ZenMode<CR>", default_options)

-------------------------------
-- Leader Keys
-------------------------------

map("n", "<Space>", "<NOP>", default_options) -- map the leader key
vim.g.mapleader = " "
--vim.g.maplocalleader = "\\"
vim.g.maplocalleader = ","

-- Easier save/open/close
--keymap("n", "<Leader>w", ":w<CR>")                                      -- write with w
--keymap("n", "<Leader>q", ":q<CR>")                                      -- quit with q
--keymap("n", "<Leader>qq", ":q!<CR>")                                    -- space + qq to force quit
--map('n', '<leader>j', [[<cmd>m-2|j<cr>]])                                 -- Join line above at end of current
map("n", "<localleader>1", "1gt", default_options)
map("n", "<localleader>2", "2gt", default_options)
map("n", "<localleader>3", "3gt", default_options)
map("n", "<localleader>4", "4gt", default_options)
map("n", "<localleader>5", "5gt", default_options)
map("n", "<localleader>6", "6gt", default_options)
map("n", "<localleader>7", "7gt", default_options)
map("n", "<localleader>8", "8gt", default_options)
map("n", "<localleader>9", "9gt", default_options)
map("n", "<localleader>pp", ":set paste<CR>", default_options)
map("n", "<localleader>po", ":set nopaste<CR>", default_options)

-------------------------------
-- Keys w Modifiers
-------------------------------

-- Buffer switching.
map("n", "<TAB>", ":bnext<CR>", default_options)
map("n", "<S-TAB>", ":bprevious<CR>", default_options)

--------------------
-- Shift Modifier
--------------------
-- Remap arrow keys
map("n", "<S-Left>", ":tabprev<CR>")
map("n", "<S-Right>", ":tabnext<CR>")
map("n", "<S-Up>", ":bnext<CR>")
map("n", "<S-Down>", ":bprev<CR>")
map("n", "<S-H>", "gT")
map("n", "<S-L>", "gt")

--------------------
-- Meta Modifier
--------------------
-- Move lines
map("n", "<M-j>", [[<cmd>m.+1<cr>==]])
map("n", "<M-k>", [[<cmd>m.-2<cr>==]])
map("i", "<M-j>", [[<esc><cmd>m.+1<cr>==]])
map("i", "<M-k>", [[<esc><cmd>m.-2<cr>==]])
-- Resize with arrows
map("n", "<M-S-Up>", ":resize -2<CR>")
map("n", "<M-S-Down>", ":resize +2<CR>")
map("n", "<M-S-Left>", ":vertical resize -2<CR>")
map("n", "<M-S-Right>", ":vertical resize +2<CR>")

--------------------
-- Ctrl Modifier
--------------------
-- Speed up viewport scrolling
map("n", "<C-e>", "2<C-e>")
map("n", "<C-y>", "2<C-y>")

map("n", "<C-CR>", ":NvimTreeToggle<CR>", default_options)
map("n", "<S-CR>", ":Twilight<CR>", default_options)
map("n", "<S-Space>", ":ZenMode<CR>", default_options)

map("n", "<C-S>", ":w<CR>") -- write with w
-- Term
--map('t', '<Esc>', '<C-\\><C-n>')

-- Tab switch buffer
-- Buffer switching.
--map("n", "<S-Tab>", ":BufferLineCyclePrev<CR>")
--map("n", "<Tab>", ":BufferLineCycleNext<CR>")

-- Buffer resizing.
--map("n", "<S-h>", ":call ResizeLeft(3)<CR><Esc>")
--map("n", "<S-l>", ":call ResizeRight(3)<CR><Esc>")
--map("n", "<S-k>", ":call ResizeUp(1)<CR><Esc>")
--map("n", "<S-j>", ":call ResizeDown(1)<CR><Esc>")

-- Split navigations.
--map("n", "<A-j>", "<C-w><C-j>")
--map("n", "<A-k>", "<C-w><C-k>")
--map("n", "<A-l>", "<C-w><C-l>")
--map("n", "<A-h>", "<C-w><C-h>")

-- Save and load session/Dashboard.
--map("n", "<Leader>db", ":Dashboard<CR>")
--map("n", "<C-s>l", ":SessionLoad<CR>")
--map("n", "<C-s>s", ":SessionSave<CR>")

-- ToggleTerm
--function _G.set_terminal_keymaps()
--map("t", "<esc>", "<C-\\><C-n>")
--map("t", "<A-h>", "<c-\\><c-n><c-w>h")
--map("t", "<A-j>", "<c-\\><c-n><c-w>j")
--map("t", "<A-k>", "<c-\\><c-n><c-w>k")
--map("t", "<A-l>", "<c-\\><c-n><c-w>l")

--map("t", "<S-h>", "<c-\\><C-n>:call ResizeLeft(3)<CR>")
--map("t", "<S-j>", "<c-\\><C-n>:call ResizeDown(1)<CR>")
--map("t", "<S-k>", "<c-\\><C-n>:call ResizeUp(1)<CR>")
--map("t", "<S-l>", "<c-\\><C-n>:call ResizeRight(3)<CR>")
--end
--vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

-- comment
--vim.g.kommentary_create_default_mappings = false
--vim.api.nvim_set_keymap("n", "<leader>ct", "<Plug>kommentary_line_default", {})
--vim.api.nvim_set_keymap("v", "<leader>ct", "<Plug>kommentary_visual_default", {})

-- starlite mappings
--map("n", "*", "<cmd>lua require'starlite'.star()<CR>", default_options)
--map("n", "g*", "<cmd>lua require'starlite'.g_star()<CR>", default_options)
--map("n", "#", "<cmd>lua require'starlite'.hash()<CR>", default_options)
--map("n", "g#", "<cmd>lua require'starlite'.g_hash()<CR>", default_options)

--map("n", "<C-,>", ":Files<CR>")

--map("n", "", "")

--map("n", "", "")
--map("n", "", "")

--map("n", "", "")
--map("n", "", "")

-----------------------------------------------
-- Visual Mode
-----------------------------------------------

-- better indenting
map("v", "<", "<gv", default_options)
map("v", ">", ">gv", default_options)

map("v", "p", '"_dP', default_options) -- paste over currently selected text without yanking it
--map("v", "p", '"_dP')                                                    -- Don't copy the replaced text after pasting.

-- Move selected line / block of text in visual mode
map("v", "K", ":move '<-2<CR>gv-gv", default_options)
map("v", "J", ":move '>+1<CR>gv-gv", default_options)

-----------------------------------------------
-- Insert Mode
-----------------------------------------------

function EscapePair()
	local closers = { ")", "]", "}", ">", "'", '"', "`", "," }
	local line = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local after = line:sub(col + 1, -1)
	local closer_col = #after + 1
	local closer_i = nil
	for i, closer in ipairs(closers) do
		local cur_index, _ = after:find(closer)
		if cur_index and (cur_index < closer_col) then
			closer_col = cur_index
			closer_i = i
		end
	end
	if closer_i then
		vim.api.nvim_win_set_cursor(0, { row, col + closer_col })
	else
		vim.api.nvim_win_set_cursor(0, { row, col + 1 })
	end
end

map("i", "<C-l>", "<cmd>lua EscapePair()<CR>", default_options)

-------------------------------
-- Keys w Modifiers
-------------------------------

-- Capitalize word on letter
map("i", "<c-u>", "<Esc>viwUi", default_options)
map("n", "<c-u>", "<Esc>viwUi", default_options)
