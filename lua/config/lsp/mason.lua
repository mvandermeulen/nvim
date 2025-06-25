--[[
-- Mason LSP Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2025-06-17
--]]


local _name = 'mason'
local _log = require('plenary.log').new({ plugin = _name, level = 'debug', use_console = true })
local function mylog(msg, level)
  local level = level or 'debug'
  if level == 'error' then
    vim.api.nvim_err_writeln(msg)
    _log.error(msg)
  elseif level == 'notify' then
    vim.notify(msg, vim.log.levels.INFO, { title = _name })
    _log.info(msg)
  elseif level == 'info' then
    _log.info(msg)
  else
    _log.debug(msg)
  end
end

local mason_status, mason = pcall(require, 'mason')
local mason_lspconfig_status, mason_lspconfig = pcall(require, 'mason-lspconfig')
local mason_null_ls_status, mason_null_ls = pcall(require, 'mason-null-ls')
local lang_status, lang = pcall(require, 'config.lsp.lang')
local lsputils_status, lsputils = pcall(require, 'config.lsp.utils')
local handlers_status, handlers = pcall(require, 'config.lsp.handlers')
local lspconfig_status, lspconfig = pcall(require, 'lspconfig')

if not mason_status or not mason_lspconfig_status or not mason_null_ls_status then
  mylog('Mason, Mason Tool Installer, Completion, or LSP Format not installed!', 'error')
  return
end

if not lang_status then
  mylog('Language servers not found', 'error')
  return
end

if not lsputils_status or not handlers_status or not lspconfig_status then
  mylog('LSP Utils, Handlers, Config not found', 'error')
  return
end


local opts = {}

local settings = {
  ui = {
    border = "rounded",
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
  log_level = vim.log.levels.INFO,
  max_concurrent_installers = 4,
}

mason.setup(settings)
mylog('Mason setup complete', 'info')
mason_lspconfig.setup({ ensure_installed = lang.servers, automatic_installation = true, })
mylog('Mason LSPConfig setup complete', 'info')
mason_null_ls.setup({ ensure_installed = lang.parsers, automatic_installation = true, })
mylog('Mason Null LS setup complete', 'info')
handlers.setup()
mylog('LSP Handlers setup complete', 'info')


-- mylog('Mason LSP Config per handler setup complete', 'info')
for _, server in pairs(lang.servers) do
  opts = {
    on_attach = handlers.on_attach,
    capabilities = handlers.capabilities,
  }
  mylog('Setting up server: ' .. server, 'info')

  server = vim.split(server, "@")[1]
  local require_ok, conf_opts = pcall(require, 'config.lsp.servers.' .. server)
  if require_ok then
    opts = vim.tbl_deep_extend("force", conf_opts, opts)
  else
    mylog('Server config not found: ' .. server, 'warn')
  end
  lspconfig[server].setup(opts)
end
