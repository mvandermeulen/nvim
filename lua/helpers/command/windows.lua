--[[
-- Commands: Windows
--
-- Author: Mark van der Meulen
-- Updated: 2025-02-07
--]]


vim.api.nvim_create_user_command("NewTabTiled", function()
  vim.cmd("tabnew")
  vim.cmd("new")
  vim.cmd("vnew")
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>k', true, false, true), 'n', false)
  vim.cmd("vnew")
end, {})


vim.api.nvim_create_user_command("NewTabHSplit", function()
  vim.cmd("tabnew")
  vim.cmd("new")
end, {})


vim.api.nvim_create_user_command("NewTabVSplit", function()
  vim.cmd("tabnew")
  vim.cmd("vnew")
end, {})


