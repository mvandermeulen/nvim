-- Done
-- https://github.com/DetachHead/basedpyright

local root_pattern = require('lspconfig.util').root_pattern
local lsputils_status, lsputils = pcall(require, 'config.lsp.utils')
if not lsputils_status then
  vim.notify('Error loading helpers: lsputils', vim.log.levels.ERROR)
  return M
end


return {
  enabled = false,
  filetypes = { "python" },
  single_file_support = true,
  cmd = { "basedpyright-langserver", "--stdio" },
  ---@diagnostic disable-next-line: deprecated
  root_dir = function(p)
    local path = root_pattern(lsputils.root_files)(p)
    return path
  end,
  handlers = {
    -- If you want to disable pyright's diagnostic prompt, open the code below
    ["textDocument/publishDiagnostics"] = function(...) end,
  },
  settings = {
    basedpyright = {
      disableLanguageServices = true,
      disableOrganizeImports = true,
      openFilesOnly = true,
      analysis = {
        ignore = { "*" },
        autoImportCompletions = true,
        autoSearchPaths = true,
        -- diagnosticMode = "openFilesOnly",
        diagnosticMode = 'workspace',
        useLibraryCodeForTypes = true,
        -- typeCheckingMode = "off",
        typeCheckingMode = 'standard', -- standard, strict, all, off, basic
      },
    },
  },
}
