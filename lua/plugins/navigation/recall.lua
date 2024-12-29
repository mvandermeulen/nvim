--[[
-- Recall Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-21
--]]


local status_ok, recall = pcall(require, 'recall')
if not status_ok then
  return
end

recall.setup({
  sign = "",
  sign_highlight = "@comment.note",
  telescope = {
    autoload = true,
    mappings = {
      unmark_selected_entry = {
        normal = "dd",
        insert = "<M-d>",
      },
    },
  },
  wshada = vim.fn.has("nvim-0.10") == 0,
})


-- Key Mappings

vim.keymap.set("n", "<leader>Mm", recall.toggle, { noremap = true, silent = true, desc = "Toggle Recall" })
vim.keymap.set("n", "<leader>Mn", recall.goto_next, { noremap = true, silent = true, desc = "Go to next Recall" })
vim.keymap.set("n", "<leader>Mp", recall.goto_prev, { noremap = true, silent = true, desc = "Go to previous Recall" })
vim.keymap.set("n", "<leader>Mc", recall.clear, { noremap = true, silent = true, desc = "Clear Recall" })
vim.keymap.set("n", "<leader>Ml", "<CMD>Telescope recall<CR>", { noremap = true, silent = true, desc = "List Recall" })
