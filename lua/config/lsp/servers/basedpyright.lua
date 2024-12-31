--[[
-- LSP Server: python
--
-- Author: Mark van der Meulen
-- Updated: 2025-01-01
--]]


local log = require('plenary.log').new({ plugin = 'lsp', level = 'debug', use_console = true })
local function mylog(msg, level)
  local level = level or 'debug'
  log.debug(msg)
  if level == 'info' or level == 'warn' or level == 'error' then
    vim.notify(msg, vim.log.levels.INFO, { title = 'LSP' })
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


return {
  enabled = true,
  filetypes = { "python" },
  single_file_support = true,
  cmd = { "basedpyright-langserver", "--stdio" },
  ---@diagnostic disable-next-line: deprecated
  root_dir = function(p)
    local path = root_pattern(lsputils.root_files)(p)
    return path
  end,
  before_init = function(_, config)
    config.settings.python.pythonPath = lsputils.get_python_path(config.root_dir)
  end,
  -- handlers = {
  --   -- If you want to disable pyright's diagnostic prompt, open the code below
  --   ["textDocument/publishDiagnostics"] = function(...) end,
  -- },
  settings = {
    python = {
      disableLanguageServices = false,
      disableOrganizeImports = true,
      openFilesOnly = true,
      analysis = {
        -- ignore = { "*" },
        autoImportCompletions = true,
        autoSearchPaths = true,
        -- diagnosticMode = "openFilesOnly",
        diagnosticMode = 'workspace',
        useLibraryCodeForTypes = true,
        indexing = true,
        -- typeCheckingMode = 'standard', -- standard, strict, all, off, basic
        typeCheckingMode = "off",
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
          reportConstantRedefinition = "error",
          reportUndefinedVariable = "error",
          reportAssertAlwaysTrue = "error",
          reportMissingTypeStubs = "none",
          reportIncompleteStub = "none",
          reportInvalidStubStatement = "none",
          reportMissingModuleSource = "information",
          reportMissingImports = "information",
          reportIncompatibleMethodOverride = "warning",
          reportUnannotatedClassAttribute = "none",
          reportDeprecated = "none",
          reportImplicitOverride = "none",
          reportCallInDefaultInitializer = "none",
          reportUnknownArgumentType = "none",
          reportUnknownMemberType = "none",
        },
      },
      exclude = { "./examples", "./notes" },
    },
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
