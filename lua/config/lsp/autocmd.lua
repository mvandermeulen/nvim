--[[
-- LSP Autocmd
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-31
--]]

-- local _log = require('plenary.log').new({ plugin = 'LSP', level = 'debug', use_console = true })
-- local function mlog(msg, level)
--   local level = level or 'debug'
--   _log.debug(msg)
-- end

vim.api.nvim_create_user_command('LspToggleAutoFormat', function()
  require('helpers.lsp').toggle_format_on_save()
end, {})

vim.api.nvim_create_user_command('LspToggleDiagnostics', function()
  require('helpers.lsp').toggle_diagnostics()
end, {})

vim.api.nvim_create_user_command('LspToggleInlayHints', function()
  require('helpers.lsp').toggle_inlay_hints()
end, {})


