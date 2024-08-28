--[[
-- Mason LSP Plugin
--
-- Author: Mark van der Meulen
-- Updated: 12-02-2023
--]]


-- Taken from: https://github.com/felipe300/Nvim-setup/blob/main/lua/base/plugins/lsp/mason.lua
local mason_status, mason = pcall(require, 'mason')
if not mason_status then
  return
end

local mason_lspconfig_status, mason_lspconfig = pcall(require, 'mason-lspconfig')
if not mason_lspconfig_status then
  return
end

local mason_null_ls_status, mason_null_ls = pcall(require, 'mason-null-ls')
if not mason_null_ls_status then
  return
end

local lang_status, lang = pcall(require, 'config.lsp.lang')
if not lang_status then
  return
end

local lsputils_status, lsputils = pcall(require, 'config.lsp.utils')
if not lsputils_status then
  return
end

local handlers_status, handlers = pcall(require, 'config.lsp.handlers')
if not handlers_status then
  return
end

local lspconfig_status, lspconfig = pcall(require, 'lspconfig')
if not lspconfig_status then
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
mason_lspconfig.setup({ ensure_installed = lang.servers, automatic_installation = true, })
mason_null_ls.setup({ ensure_installed = lang.parsers, automatic_installation = true, })
handlers.setup()
-- handlers.setup()

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
    })
  end,
})


for _, server in pairs(lang.servers) do
  opts = {
    on_attach = handlers.on_attach,
    capabilities = handlers.capabilities,
  }

  server = vim.split(server, "@")[1]
  local require_ok, conf_opts = pcall(require, 'config.lsp.servers.' .. server)
  if require_ok then
    opts = vim.tbl_deep_extend("force", conf_opts, opts)
  end
  lspconfig[server].setup(opts)
end




