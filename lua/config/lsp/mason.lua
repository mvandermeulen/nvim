--[[
-- Mason LSP Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-20
--]]


local log = require('plenary.log').new({ plugin = 'mason', level = 'debug', use_console = true })
local function mylog(msg, level)
  local level = level or 'debug'
  log.debug(msg)
  if level == 'info' or level == 'warn' or level == 'error' then
    vim.notify(msg, vim.log.levels.INFO, { title = 'Mason' })
  end
end

local mason_status, mason = pcall(require, 'mason')
if not mason_status then
  mylog('Mason not found', 'error')
  return
end

local mason_lspconfig_status, mason_lspconfig = pcall(require, 'mason-lspconfig')
if not mason_lspconfig_status then
  mylog('Mason LSPConfig not found', 'error')
  return
end

local mason_null_ls_status, mason_null_ls = pcall(require, 'mason-null-ls')
if not mason_null_ls_status then
  mylog('Mason Null LS not found', 'error')
  return
end

local lang_status, lang = pcall(require, 'config.lsp.lang')
if not lang_status then
  mylog('Language servers not found', 'error')
  return
end

local lsputils_status, lsputils = pcall(require, 'config.lsp.utils')
if not lsputils_status then
  mylog('LSP Utils not found', 'error')
  return
end

local handlers_status, handlers = pcall(require, 'config.lsp.handlers')
if not handlers_status then
  mylog('LSP Handlers not found', 'error')
  return
end

local lspconfig_status, lspconfig = pcall(require, 'lspconfig')
if not lspconfig_status then
  mylog('LSP Config not found', 'error')
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
-- mylog('Mason setup complete', 'info')
mason_lspconfig.setup({ ensure_installed = lang.servers, automatic_installation = true, })
-- mylog('Mason LSPConfig setup complete', 'info')
mason_null_ls.setup({ ensure_installed = lang.parsers, automatic_installation = true, })
-- mylog('Mason Null LS setup complete', 'info')
handlers.setup()
-- mylog('LSP Handlers setup complete', 'info')

mason_lspconfig.setup_handlers({
  function(server_name)
    lspconfig[server_name].setup({
    on_attach = handlers.common_on_attach,
    capabilities = handlers.capabilities,
    before_init = function(_, config)
      if lsp == 'pyright' then
        config.settings.python.pythonPath = lsputils.get_python_path(config.root_dir)
      end
    end,
    flags = { debounce_text_changes = 150 },
    })
  end,
})

-- mylog('LSP common setup complete', 'info')
for _, server in pairs(lang.servers) do
  opts = {
    on_attach = handlers.on_attach,
    capabilities = handlers.capabilities,
  }
  mylog('Setting up server: ' .. server, 'info')

  server = vim.split(server, "@")[1]
  -- conf_opts = require('config.lsp.servers.' .. server)
  -- opts = vim.tbl_deep_extend("force", conf_opts, opts)
  -- mylog('Server config found: ' .. server, 'info')
  local require_ok, conf_opts = pcall(require, 'config.lsp.servers.' .. server)
  if require_ok then
    opts = vim.tbl_deep_extend("force", conf_opts, opts)
  else
    mylog('Server config not found: ' .. server, 'warn')
  end
  lspconfig[server].setup(opts)
end
