--[[
-- Commands
--
-- Author: Mark van der Meulen
-- Updated: 2024-09-22
--]]


vim.api.nvim_create_user_command("Pretty", "Prettier", { bang = true })

vim.api.nvim_create_user_command("Browse", function(opts)
  vim.fn.system { "open", opts.fargs[1] }
end, { nargs = 1 })

vim.api.nvim_create_user_command("StartEmpty", function()
  vim.cmd "enew"
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "hide"
  vim.bo.swapfile = false
end, {})

vim.api.nvim_create_user_command("TmuxLayout", function()
  local layout = vim.fn.system "tmux list-windows | sed -n 's/.*layout \\(.*\\)] @.*/\\1/p'"
  layout = layout:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
  vim.api.nvim_put({ "      layout: " .. layout }, "l", true, true)
end, {})

vim.api.nvim_create_user_command("WS", function()
  vim.cmd "write | source %"
end, { bang = false })

