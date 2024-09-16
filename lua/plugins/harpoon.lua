--[[
-- Harpoon
--
-- Author: Mark van der Meulen
-- Updated: 09-05-2022
--]]

local status_ok, harpoon = pcall(require, 'harpoon')
if not status_ok then
  return
end

harpoon.setup {
  global_settings = {
    save_on_toggle = false,
    save_on_change = true,
    enter_on_sendcmd = false,
    tmux_autoclose_windows = false,
    excluded_filetypes = { 'harpoon' },
    mark_branch = false,
  },
}

vim.keymap.set("n", "<leader>hn", "<cmd>lua require('harpoon.ui').nav_next()<cr>", { desc = "Next Harpoon Mark" })
vim.keymap.set("n", "<leader>hp", "<cmd>lua require('harpoon.ui').nav_prev()<cr>", { desc = "Prev Harpoon Mark" })

require('telescope').load_extension('harpoon')
