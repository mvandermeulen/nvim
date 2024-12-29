--[[
-- Dropbar Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-21
--]]


local status_ok, dropbar = pcall(require, 'dropbar.api')
if not status_ok then
  return
end

vim.keymap.set('n', '<Leader>;', dropbar.pick, { desc = 'Pick symbols in winbar' })
vim.keymap.set('n', '[;', dropbar.goto_context_start, { desc = 'Go to start of current context' })
vim.keymap.set('n', '];', dropbar.select_next_context, { desc = 'Select next context' })
