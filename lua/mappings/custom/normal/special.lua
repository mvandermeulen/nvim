--[[
-- Mappings: Normal - Local Leader
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-25
--]]



local function dfo(desc)
  if desc then
    return { noremap = true, silent = true, desc = desc }
  else
    return { noremap = true, silent = true }
  end
end

------------------------
-- Function Key Bindings
------------------------

-- <F1>: Show help
vim.keymap.set("n", "<F1>", "<cmd>Telescope help_tags<CR>", dfo())
-- vim.keymap.set("n", "<F1>", "<Esc>")
-- <S-F1>: Show keymaps
vim.keymap.set("n", "<F3>", "<cmd>Telescope keymaps<CR>", dfo())

-- <F2>: Rename (check lspconfig)
vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", dfo())
-- <S-F2>: Show task list
-- vim.keymap.set("n", "<F14>", "<cmd>TodoTelescope<CR>", dfo())

-- <F3>: Show file tree explorer
-- vim.keymap.set("n", "<F3>", "<cmd>NvimTreeToggle<CR>", default_dfo())
-- vim.keymap.set("n", "<F3>", "<cmd>Neotree toggle<CR>", dfo())
-- <F3>: Show file tree at the current file
-- vim.keymap.set("n", "<F15>", "<cmd>Neotree reveal<CR>", dfo())

-- <F4>: Show tags of current buffer
-- vim.keymap.set("n", "<F4>", ":Telescope current_buffer_tags<CR>", default_dfo())
vim.keymap.set("n", "<F4>", "<cmd>Outline!<CR>", dfo())
-- <S-F4>: Show diagnostics
vim.keymap.set("n", "<F6>", "<cmd>Telescope diagnostics<CR>", dfo())
-- <S-F4>: Generate tags
-- vim.keymap.set("n", "<F16>", ":!ctags -R --links=no . <CR>", default_dfo())

-- <F5>: Show and switch buffer
vim.keymap.set("n", "<F5>", "<cmd>Telescope buffers<CR>", dfo())
-- <S-F5>: Show and switch tab
vim.keymap.set("n", "<F13>", "<cmd>tabs<CR>", dfo())

-- <F6>: Prev buffer
-- vim.keymap.set("n", "<F6>", "<cmd>BufferPrevious<CR>", dfo())
-- <S-F6>: Prev tab
-- vim.keymap.set("n", "<F18>", "<cmd>tabprevious<CR>", dfo())

-- <F7>: Next buffer
-- vim.keymap.set("n", "<F7>", "<cmd>BufferNext<CR>", dfo())
-- <S-F7>: Next tab
-- vim.keymap.set("n", "<F19>", "<cmd>tabnext<CR>", dfo())

-- <F14>: Close current buffer and switch to previous buffer
vim.keymap.set("n", "<F14>", "<cmd>BufferDelete<CR>", dfo())
-- <S-F8>: Close current tab
-- vim.keymap.set("n", "<F20>", "<cmd>tabclose<CR>", dfo())

-- <F9>: Remove trailing spaces
-- vim.keymap.set("n", "<F9>", [[<cmd>%s/\s\+$//e<CR>]], dfo())
-- <S-F9>: Clear registers
-- vim.keymap.set("n", "<F21>", "<cmd>ClearAllRegisters<CR>", dfo())

-- <F10>: Run make file
-- vim.keymap.set("n", "<F10>", "<cmd>make<CR>", dfo())
-- <S-F10>: Run make clean
-- vim.keymap.set("n", "<F22>", "<cmd>make clean<CR>", dfo())

-- <F11>: Toggle zoom the current window (from custom functions)
vim.keymap.set("n", "<F16>", function() require("snacks").zen.zoom() end, dfo())
-- <S-F11>: Toggle colorizer
-- vim.keymap.set("n", "<F17>", "<cmd>ColorizerToggle<CR>", dfo())

-- <F12>: Toggle relative number
-- vim.keymap.set("n", "<F12>", "<cmd>set nu rnu!<CR>", dfo())
-- <S-F11>: Toggle welcome screen
-- vim.keymap.set("n", "<F19>", function() require("snacks").dashboard() end, dfo())



-- vim.keymap.set('n', '<D-s>', ':w<CR>')        -- Save
-- vim.keymap.set('v', '<D-c>', '"+y')           -- Copy
-- vim.keymap.set('n', '<D-v>', '"+P')           -- Paste normal mode
-- vim.keymap.set('v', '<D-v>', '"+P')           -- Paste visual mode
-- vim.keymap.set('c', '<D-v>', '<C-R>+')        -- Paste command mode
-- vim.keymap.set('i', '<D-v>', '<ESC>l"+Pli')   -- Paste insert mode

-- Allow clipboard copy paste in neovim
-- vim.keymap.set('', '<D-v>', '+p<CR>', { noremap = true, silent = true })
-- vim.keymap.set('!', '<D-v>', '<C-R>+', { noremap = true, silent = true })
-- vim.keymap.set('t', '<D-v>', '<C-R>+', { noremap = true, silent = true })
-- vim.keymap.set('v', '<D-v>', '<C-R>+', { noremap = true, silent = true })









