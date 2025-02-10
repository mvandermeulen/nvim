--[[
-- Helpers: Notes
--
-- Author: Mark van der Meulen
-- Updated: 2025-02-10
--]]


local M = {}

function M.insert_todo_and_comment()
  -- Insert the TODO text at the current cursor position
  local line = vim.api.nvim_get_current_line()
  print("Original line: ", line)

  vim.api.nvim_put({ "TODO:(mvandermeulen)" }, "", true, true)
  vim.cmd [[execute "normal gcc"]]
  -- Uncomment the line
  -- vim.cmd [[execute "normal \<Plug>(comment_toggle_linewise)"]]
end

function M.record_was_doing()
  local doing = vim.ui.input("What were you doing? ")
  vim.cmd("Was " .. doing)
end

return M
