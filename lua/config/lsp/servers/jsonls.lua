--[[
-- LSP Server: JSON
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-28
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

-- https://github.com/hrsh7th/vscode-langservers-extracted
-- npm i -g vscode-langservers-extracted or yay -S vscode-langservers-extracted (for arch)

local config = {
  format = { enabled = false },
  schemas = local_schemas,
  validate = { enable = false },
}

local status_ok, schemastore = pcall(require, "schemastore")
if status_ok then
  config.schemas = vim.tbl_deep_extend("force", local_schemas, schemastore.json.schemas())
end


return {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  init_options = {
    provideFormatter = false,-- better handled by JQ
  },
  single_file_support = true,
  on_new_config = function(new_config)
    new_config.settings.json.schemas = new_config.settings.json.schemas or {}
    vim.list_extend(new_config.settings.json.schemas, config.schemas)
    -- vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
  end,
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
