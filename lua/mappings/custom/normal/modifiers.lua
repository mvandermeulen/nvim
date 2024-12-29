--[[
-- Mappings: Normal - Modifiers
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


-- Easier pane jumping
-- vim.keymap.set("n", "<C-h>", "<C-w>h")
-- vim.keymap.set("n", "<C-j>", "<C-w>j")
-- vim.keymap.set("n", "<C-k>", "<C-w>k")
-- vim.keymap.set("n", "<C-l>", "<C-w>l")
-- Quickly switch window {{{
vim.keymap.set("n", "<M-h>", [[<C-W>h]], { desc = "Switch to left window" })
vim.keymap.set("n", "<M-j>", [[<C-W>j]], { desc = "Switch to below window" })
vim.keymap.set("n", "<M-k>", [[<C-W>k]], { desc = "Switch to above window" })
vim.keymap.set("n", "<M-l>", [[<C-W>l]], { desc = "Switch to right window" })


-- tmux sessionizer in nvim
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer.sh<CR>")


-- vim.keymap.set('n', '<C-q>', '<C-w><C-w>', { desc = 'Switch window' })
-- vim.keymap.set("n", "<C-q>", "<cmd>q<cr>", { desc = "Quit" })
vim.keymap.set("n", "<C-c><C-c>", function()
  require('snacks').bufdelete()
end, { desc = "Delete Buffer" })

-- Buffer movement instead of tab's
-- vim.keymap.set('n', 'gt', vim.cmd.bnext, { silent = true, desc = 'Go to the next buffer' })
-- vim.keymap.set('n', 'gT', vim.cmd.bprevious, { silent = true, desc = 'Go to the previous buffer' })
-- vim.keymap.set('n', '<C-Tab>', 'gt', { remap = true, silent = true, desc = 'Alias for `gt`' })
-- vim.keymap.set('n', '<C-S-Tab>', 'gT', { remap = true, silent = true, desc = 'Alias for `gT`' })

-- tab movement
vim.keymap.set('n', ']<M-t>', vim.cmd.tabnext, { silent = true, desc = 'Go to the next tab' })
vim.keymap.set('n', '[<M-t>', vim.cmd.tabprevious, { silent = true, desc = 'Go to the previous tab' })


----------------------
-- Option Key Bindings
----------------------


-- Window swapping
vim.keymap.set("n", "<M-S-h>", "<C-w>h<C-w>x", dfo('Swap Window Left'))
vim.keymap.set("n", "<M-S-j>", "<C-w>j<C-w>x", dfo('Swap Window Below'))
vim.keymap.set("n", "<M-S-k>", "<C-w>k<C-w>x", dfo('Swap Window Above'))
vim.keymap.set("n", "<M-S-l>", "<C-w>l<C-w>x", dfo('Swap Window Right'))
-- vim.keymap.set("n", "<M-m>", "<C-W>x", dfo('Swap Window')) -- swap window



