--[[
-- LSP Server: bashls
--
-- Author: Mark van der Meulen
-- Updated: 2025-02-10
--]]

local log = require('plenary.log').new({ plugin = 'shell_lsp', level = 'debug', use_console = true })
local function mylog(msg, level)
  local level = level or 'debug'
  log.debug(msg)
  if level == 'info' or level == 'warn' or level == 'error' then
    vim.notify(msg, vim.log.levels.INFO, { title = 'LSP: Shell' })
  end
end



local lsputils_status, lsputils = pcall(require, 'config.lsp.utils')
if not lsputils_status then
  mylog('Error loading helper: lsputils', 'error')
  return M
end


local util_status, utils = pcall(require, 'helpers.utils')
if not util_status then
  mylog('Error loading helper: utils', 'error')
  return M
end

local root_pattern = require('lspconfig.util').root_pattern
-- local bin_name = "bash-language-server"
-- local cmd = { bin_name, "start" }

return {
  settings = {
    -- cmd = cmd,
    cmd_env = {
      -- Prevent recursive scanning which will cause issues when opening a file
      -- directly in the home directory (e.g. ~/foo.sh).
      GLOB_PATTERN = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
    },
    filetypes = { "sh", "zsh", "bash" },
    single_file_support = true,
    root_dir = function(p)
      local path = root_pattern(lsputils.root_files)(p)
      return path
    end,
  },
}
