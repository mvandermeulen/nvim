--[[
-- Persisted Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-26
--]]


local persisted_path = vim.fn.expand(vim.fn.stdpath 'data' .. '/persisted')
if vim.fn.isdirectory(persisted_path) == 0 then
  vim.fn.mkdir(persisted_path, 'p')
end

require("persisted").setup({
  save_dir = persisted_path, -- Resolves to ~/.local/share/nvim/sessions/
  autosave = true,
  autostart = true,
  autoload = false,
  allowed_dirs = {
    '~/projects',
    '~/resources',
    "~/Documents",
    "~/dots",
    "~/scripts",
    "~/vdm",
    "~/working",
    "~/w",
  },
})
