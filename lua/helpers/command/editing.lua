--[[
-- Commands: Editing
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-25
--]]


vim.api.nvim_create_user_command("Pretty", "Prettier", { bang = true })

vim.api.nvim_create_user_command("StartEmpty", function()
  vim.cmd "enew"
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "hide"
  vim.bo.swapfile = false
end, {})

vim.api.nvim_create_user_command("WS", function()
  vim.cmd "write | source %"
end, { bang = false })


vim.api.nvim_create_user_command("BufferDelete", function(opts)
  local bufnr = opts[1] or vim.fn.bufnr() or vim.api.nvim_get_current_buf()
  vim.cmd "TSContextDisable"
  vim.cmd "TSBufDisable rainbow"
  vim.cmd "TSBufDisable highlight"
  require("snacks").bufdelete()
end, { nargs = '?' })


local function replace_with(motion, replacement, paste)
  vim.api.nvim_feedkeys(string.format('"kci%s%s', motion, replacement), 'n', true)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
  if paste then
    vim.api.nvim_feedkeys('"kP', 'n', true)
  end
end

vim.api.nvim_create_user_command("ReplaceInSingleQuotesWord", function()
  replace_with('w', "''", true)
end, {})

vim.api.nvim_create_user_command("ReplaceInSingleQuotesNonWhitespaceWord", function()
  replace_with('W', "''", true)
end, {})

vim.api.nvim_create_user_command("ReplaceInDoubleQuotesWord", function()
  replace_with('w', '""', true)
end, {})

vim.api.nvim_create_user_command("ReplaceInDoubleQuotesNonWhitespaceWord", function()
  replace_with('W', '""', true)
end, {})

vim.api.nvim_create_user_command("ReplaceInBracketsWord", function()
  replace_with('w', '[]', true)
end, {})

vim.api.nvim_create_user_command("ReplaceInBracketsNonWhitespaceWord", function()
  replace_with('W', '[]', true)
end, {})

vim.api.nvim_create_user_command("ReplaceInParenthesesWord", function()
  replace_with('w', '()', true)
end, {})

vim.api.nvim_create_user_command("ReplaceInParenthesesNonWhitespaceWord", function()
  replace_with('W', '()', true)
end, {})


vim.api.nvim_create_user_command("MakeWordMarkdownLink", function()
  replace_with('W', '[]', true)
  vim.api.nvim_feedkeys("la()", 'n', true)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
  vim.api.nvim_feedkeys("P", 'n', true)
end, {})

vim.api.nvim_create_user_command("MakeNonWhitespaceWordMarkdownLink", function()
  replace_with('W', '[]', true)
  vim.api.nvim_feedkeys("la()", 'n', true)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
  vim.api.nvim_feedkeys("P", 'n', true)
end, {})


