--[[
-- Precognition Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-21
--]]


local status_ok, precognition = pcall(require, 'precognition')
if not status_ok then
  return
end

precognition.setup()

-- vim.keymap.set("n", "<leader>mP", function() precognition_toggle() end, { noremap = true, silent = true, desc = "Toggle precognition" })
vim.keymap.set("n", "<leader>Pp", function() require("precognition").peek() end, { noremap = true, silent = true, desc = "Peek precognition" })
