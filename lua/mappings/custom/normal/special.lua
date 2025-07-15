--[[
-- Mappings: Normal - Special
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-16
--]]


---------- Helpers ----------
local keys = require('helpers.utils.keys')
local map = keys.safe_keymap_set
local kmo = keys.kmo


-------------------------------
-- Function Keys
-------------------------------

-- <F1>: Show help
-- vim.keymap.set("n", "<F1>", "<cmd>Telescope help_tags<CR>", kmo())
-- vim.keymap.set("n", "<F1>", "<Esc>")

-- <F2>: Rename (check lspconfig)
map("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", kmo())

-- <F3>: Show keymaps
map("n", "<F3>", "<cmd>Telescope keymaps<CR>", kmo())
-- <F3>: Show file tree explorer
-- vim.keymap.set("n", "<F3>", "<cmd>NvimTreeToggle<CR>", default_kmo())
-- vim.keymap.set("n", "<F3>", "<cmd>Neotree toggle<CR>", kmo())
-- <F3>: Show file tree at the current file

-- <F4>: Show tags of current buffer
-- vim.keymap.set("n", "<F4>", ":Telescope current_buffer_tags<CR>", default_kmo())
map("n", "<F4>", "<cmd>Outline!<CR>", kmo())

-- <F5>: Show and switch buffer
map("n", "<F5>", "<cmd>Telescope buffers<CR>", kmo())

-- <F6>: Show diagnostics
map("n", "<F6>", "<cmd>Telescope diagnostics<CR>", kmo())

-- <F7>: Next buffer
-- vim.keymap.set("n", "<F7>", "<cmd>BufferNext<CR>", kmo())


-- <F9>: Remove trailing spaces
-- vim.keymap.set("n", "<F9>", [[<cmd>%s/\s\+$//e<CR>]], kmo())

-- <F10>: Run make file
-- vim.keymap.set("n", "<F10>", "<cmd>make<CR>", kmo())

-- <F11>: Toggle zoom the current window (from custom functions)

-- <F12>: Toggle relative number
-- vim.keymap.set("n", "<F12>", "<cmd>set nu rnu!<CR>", kmo())

-- <S-F1>: Show tabs
-- <S-F1>: <F13>
map("n", "<F13>", "<cmd>tabs<CR>", kmo())
-- map("n", "<F13>", ":NvimTreeToggle<cr>", kmo())

-- <S-F2>: <F14>
-- <S-F2>: Show task list
-- vim.keymap.set("n", "<F14>", "<cmd>TodoTelescope<CR>", kmo())
-- <F14>: Close current buffer and switch to previous buffer
map("n", "<F14>", "<cmd>BufferDelete<CR>", kmo('Close Buffer'))

-- <S-F3>: <F15>
-- <F15>: 
-- vim.keymap.set("n", "<F15>", "<cmd>Neotree reveal<CR>", kmo())

-- <S-F4>: <F16>
-- <F16>: Snacks Zen Mode
-- <S-F4>: Generate tags
-- vim.keymap.set("n", "<F16>", ":!ctags -R --links=no . <CR>", default_kmo())
map("n", "<F16>", function() require("snacks").zen.zoom() end, kmo('Zen Mode'))

-- <S-F5>: <F17>
-- <F17>: 
-- <S-F5>: Toggle colorizer
-- vim.keymap.set("n", "<F17>", "<cmd>ColorizerToggle<CR>", kmo())


-- <S-F6>: <F18>
-- <F18>: 
-- <S-F6>: Prev tab
-- vim.keymap.set("n", "<F18>", "<cmd>tabprevious<CR>", kmo())


-- <S-F7>: <F19>
-- <F19>: 
-- <S-F7>: Next tab
-- vim.keymap.set("n", "<F19>", "<cmd>tabnext<CR>", kmo())


-- <S-F8>: <F20>
-- <F20>: 
-- <S-F8>: Close current tab
-- vim.keymap.set("n", "<F20>", "<cmd>tabclose<CR>", kmo())


-- <S-F9>: <F21>
-- <F21>: 
-- <S-F9>: Clear registers
-- vim.keymap.set("n", "<F21>", "<cmd>ClearAllRegisters<CR>", kmo())


-- <S-F10>: <F22>
-- <F22>: 
-- <S-F10>: Run make clean
-- vim.keymap.set("n", "<F22>", "<cmd>make clean<CR>", kmo())


-- <S-F11>: <F23>
-- <F23>: 
-- <S-F11>: Toggle welcome screen
-- vim.keymap.set("n", "<F19>", function() require("snacks").dashboard() end, kmo())


-- <S-F12>: <F24>
-- <F24>: 


-- <backspace>: Replace indented line
map("n", "<backspace>", function() require("helpers.user.tools").replace_indented_line() end, kmo())
-- <S-Backspace> is UNUSED


