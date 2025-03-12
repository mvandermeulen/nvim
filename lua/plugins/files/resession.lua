--[[
-- Resession
--
-- Author: Mark van der Meulen
-- Updated: 2025-03-12
--]]

local resession_path = vim.fn.expand(vim.fn.stdpath 'data' .. '/resession')
if vim.fn.isdirectory(resession_path) == 0 then
  vim.fn.mkdir(resession_path, 'p')
end

local status_ok, resession = pcall(require, 'resession')
if not status_ok then
  return
end

resession.setup({
  autosave = {
    enabled = true,
    interval = 30,
    notify = true,
  },
  dir = "resession",
})

-- Resession does NOTHING automagically, so we have to set up some keymaps
vim.keymap.set("n", "<leader>Ss", resession.save, { noremap = true, silent = true, desc = 'Resession: Save' })
vim.keymap.set("n", "<leader>St", resession.save_tab, { noremap = true, silent = true, desc = 'Resession: Save Tab' })
vim.keymap.set("n", "<leader>Sl", resession.load, { noremap = true, silent = true, desc = 'Resession: Load' })
vim.keymap.set("n", "<leader>Sd", resession.delete, { noremap = true, silent = true, desc = 'Resession: Delete' })
