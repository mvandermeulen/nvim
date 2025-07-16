-- local M = {}
-- M.mappings = {
--   ["<F9>"] = { "<CMD>BookmarkToggle<CR>", " Add/Remove bookmark" },
-- }

--[[
-- Mappings: Inserts
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

return {
  { "<leader>Ie", "<CMD>lua EscapePair()<CR>", desc = "Escape Pair" },
  { "<leader>If", "<CMD>lua require('helpers.user.editing').insert_file_path()<CR>", desc = "File Path" },
  { "<leader>It", "<CMD>lua require('helpers.user.editing').insert_todo_and_comment()<CR>", desc = "Todo with Comment" },
  { "<leader>Ip", "<CMD>lua require('helpers.user.editing').add_project_from_line(vim.fn.getline('.'))<CR>", desc = "Project" },
  -- { "<leader>I", "", desc = "" },
  -- { "<leader>I", "", desc = "" },
}
