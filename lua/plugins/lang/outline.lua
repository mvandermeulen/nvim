--[[
-- Outline Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-20
--]]


local status_ok, outline = pcall(require, 'outline')
if not status_ok then
  return
end

vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle Outline" })

outline.setup()
