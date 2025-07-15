--[[
-- Commands: Lang
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-15
--]]


vim.api.nvim_create_user_command("GetPythonPath", function(opts)
  local lsputils = require('config.lsp.utils')
  local python_path = lsputils.get_python_path(vim.fn.getcwd())
  local message = string.format("Python path: %s", python_path)
  print(message)
  if opts.fargs[1] == "copy" then
    vim.fn.setreg('+', python_path)
    vim.notify(message, vim.log.levels.INFO)
  elseif opts.fargs[1] == "notify" then
    vim.notify(message, vim.log.levels.INFO)
  end
end, { nargs = 1 })


