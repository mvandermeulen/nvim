--[[
-- LSP Server: JSON
--
-- Author: Mark van der Meulen
-- Updated: August 09, 2023
--]]

local local_schemas = {
  {
    description = 'ESLint config',
    fileMatch = { '.eslintrc.json', '.eslintrc' },
    url = 'http://json.schemastore.org/eslintrc',
  },
  {
    description = 'Package config',
    fileMatch = { 'package.json' },
    url = 'https://json.schemastore.org/package',
  },
  {
    description = 'Packer config',
    fileMatch = { 'packer.json' },
    url = 'https://json.schemastore.org/packer',
  },
  {
    description = 'Renovate config',
    fileMatch = {
      'renovate.json',
      'renovate.json5',
      '.github/renovate.json',
      '.github/renovate.json5',
      '.renovaterc',
      '.renovaterc.json',
    },
    url = 'https://docs.renovatebot.com/renovate-schema',
  },
  {
    description = 'OpenApi config',
    fileMatch = { '*api*.json' },
    url = 'https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json',
  },
}

local config = {
  format = { enabled = false },
  schemas = local_schemas,
}

local status_ok, schemastore = pcall(require, "schemastore")
if status_ok then
  config.schemas = vim.tbl_deep_extend("force", local_schemas, schemastore.json.schemas())
end

local opts = {
  init_options = {
    provideFormatter = false,
  },
  settings = {
    json = config,
  },
  setup = {
    commands = {
      Format = {
        function()
          vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line "$", 0 })
        end,
      },
    },
  },
}

return opts
