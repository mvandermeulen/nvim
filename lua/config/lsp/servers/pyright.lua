--[[
-- LSP Server: python
--
-- Author: Mark van der Meulen
-- Updated: August 09, 2023
--]]

local log = require('plenary.log').new({ plugin = 'lsp', level = 'debug', use_console = true })
local function mylog(msg, level)
  local level = level or 'debug'
  log.debug(msg)
  if level == 'info' or level == 'warn' or level == 'error' then
    vim.notify(msg, vim.log.levels.INFO, { title = 'LSP' })
  end
end


-- local opts = {}

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

local settings = {
  enabled = true,
  filetypes = { "python" },
  single_file_support = true,
  disableOrganizeImports = true,
  -- disableLanguageServices = false,
  -- openFilesOnly = true,
  analysis = {
    typeCheckingMode = "off",
    autoImportCompletions = true,
    diagnosticMode = "openFilesOnly",
    autoSearchPaths = true,
    useLibraryCodeForTypes = true,
    indexing = true,
    -- ignore = { "*" },
    diagnosticSeverityOverrides = {
      strictListInference = true,
      strictDictionaryInference = true,
      strictSetInference = true,
      reportUnusedImport = "information",
      reportUnusedClass = "information",
      reportUnusedFunction = "information",
      reportUnusedVariable = "information",
      reportUnusedCoroutine = "information",
      reportDuplicateImport = "warning",
      reportPrivateUsage = "none",
      reportUnusedExpression = "warning",
      reportConstantRedefinition = "warning",
      reportUndefinedVariable = "error",
      reportAssertAlwaysTrue = "error",
      reportMissingTypeStubs = "none",
      reportIncompleteStub = "none",
      reportInvalidStubStatement = "none",
      reportMissingModuleSource = "none",
      reportMissingImports = "information",
      reportIncompatibleMethodOverride = "warning",
    },
  },
  exclude = { "./examples", "./notes" },
}

local opts = {
  root_dir = function(p)
    local path = root_pattern(lsputils.root_files)(p)
    return path
  end,
  before_init = function(_, config)
    config.settings.python.pythonPath = lsputils.get_python_path(config.root_dir)
  end,
  -- on_attach = function(client, _)
  --   -- disable capabilities that are better handled by pylsp
  --   client.server_capabilities.renameProvider = false -- rope is ok
  --   client.server_capabilities.hoverProvider = false -- pylsp includes also docstrings
  --   client.server_capabilities.signatureHelpProvider = false -- pyright typing of signature is weird
  --   client.server_capabilities.definitionProvider = false -- pyright does not follow imports correctly
  --   client.server_capabilities.referencesProvider = false -- pylsp does it
  --   -- client.server_capabilities.completionProvider = false -- missing when dep is untyped
  --   client.server_capabilities.completionProvider = {
  --     resolveProvider = true,
  --     triggerCharacters = { "." },
  --   }
  -- end,
  handlers = {
    ["textDocument/publishDiagnostics"] = vim.lsp.with(lsputils.filter_publish_diagnostics, {
      ignore_diagnostic_message = lsputils.ignore_diagnostic_message,
    }),
  },
  settings = {
    python = settings,
  },
  on_new_config = function(config, new_workspace)
    local python_path = lsputils.get_python_path(new_workspace)
    local new_workspace_name = utils.to_workspace_name(new_workspace)

    if python_path == "python" then
      local msg = "LSP python (pyright) - keeping previous python path '%s' for new_root_dir '%s'"
      vim.notify(msg:format(config.cmd[1], new_workspace), vim.log.levels.DEBUG)
      return config
    else
      local msg = "LSP python (pyright) - '%s' using path %s"
      vim.notify(msg:format(new_workspace_name, python_path), vim.log.levels.DEBUG)
      config.settings.python.pythonPath = python_path
      return config
    end
  end,
}

return opts
