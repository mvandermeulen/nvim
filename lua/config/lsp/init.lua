--[[
-- Language Server
--
-- Author: Mark van der Meulen
-- Updated: 02-05-2022
--]]

local nvim_lsp = require 'lspconfig'
local util = require 'lspconfig/util'

local function get_python_path(workspace)
  -- Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then
    return util.path.join(vim.env.VIRTUAL_ENV, 'bin', 'python3')
  end
  -- Find and use virtualenv in workspace directory.
  for _, pattern in ipairs { '*', '.*' } do
    local match = vim.fn.glob(util.path.join(workspace, pattern, 'pyvenv.cfg'))
    if match ~= '' then
      return util.path.join(util.path.dirname(match), 'bin', 'python3')
    end
  end
  -- Fallback to system Python.
  return vim.fn.exepath 'python3' or vim.fn.exepath 'python' or 'python'
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local hs_version = vim.fn.system('hs -c _VERSION'):gsub('[\n\r]', '')
local hs_path = vim.split(vim.fn.system('hs -c package.path'):gsub('[\n\r]', ''), ';')

local servers = {
  'gopls',
  'bashls',
  'pyright',
  'dockerls',
  'terraformls',
  'sumneko_lua',
  'tsserver',
  'texlab',
  'yamlls',
  'jsonls',
}
-- Use a loop to conveniently call 'setup' on multiple servers
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = function(client)
      -- disable formatting for LSP clients as this is handled by null-ls
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
    end,
    before_init = function(_, config)
      if lsp == 'pyright' then
        config.settings.python.pythonPath = get_python_path(config.root_dir)
      end
    end,
    capabilities = capabilities,
    settings = {
      gopls = { analyses = { unusedparams = true }, staticcheck = true },
      json = {
        format = { enabled = false },
        schemas = {
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
        },
      },
      Lua = {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        format = { enabled = false }, -- HACK: Hoping this will prevent automatic lua formatting at the moment.
        runtime = {
          version = 'LuaJIT',
          path = vim.split(package.path, ';'),
        },
        completion = { enable = true, callSnippet = 'Both' },
        diagnostics = {
          enable = true,
          globals = { 'vim', 'describe', 'hs', 'spoons' },
          disable = { 'lowercase-global' },
        },
        workspace = {
          library = {
            vim.api.nvim_get_runtime_file('', true),
            [vim.fn.expand '$VIMRUNTIME/lua'] = true,
            [vim.fn.expand '$VIMRUNTIME/lua/vim/lsp'] = true,
            [vim.fn.expand '/usr/share/awesome/lib'] = true,
            ['/Users/vandem/.hammerspoon/Spoons/EmmyLua.spoon/annotations'] = true,
          },
          -- adjust these two values if your performance is not optimal
          maxPreload = 2000,
          preloadFileSize = 1000,
        },
        telemetry = { enable = false },
      },
      redhat = { telemetry = { enabled = false } },
      texlab = {
        auxDirectory = '.',
        bibtexFormatter = 'texlab',
        build = {
          args = {
            '--keep-intermediates',
            '--keep-logs',
            '--synctex',
            '%f',
          },
          executable = 'tectonic',
          forwardSearchAfter = false,
          onSave = false,
        },
        chktex = { onEdit = false, onOpenAndSave = false },
        diagnosticsDelay = 300,
        formatterLineLength = 80,
        forwardSearch = { args = {} },
        latexFormatter = 'latexindent',
        latexindent = { modifyLineBreaks = false },
      },
      yaml = {
        schemaStore = {
          enable = true,
          url = 'https://www.schemastore.org/api/json/catalog.json',
        },
        schemas = {
          kubernetes = '*.yaml',
          ['http://json.schemastore.org/github-workflow'] = '.github/workflows/*',
          ['http://json.schemastore.org/github-action'] = '.github/action.{yml,yaml}',
          ['http://json.schemastore.org/ansible-stable-2.9'] = 'roles/tasks/*.{yml,yaml}',
          ['http://json.schemastore.org/prettierrc'] = '.prettierrc.{yml,yaml}',
          ['http://json.schemastore.org/kustomization'] = 'kustomization.{yml,yaml}',
          ['http://json.schemastore.org/ansible-playbook'] = '*play*.{yml,yaml}',
          ['http://json.schemastore.org/chart'] = 'Chart.{yml,yaml}',
          ['https://json.schemastore.org/dependabot-v2'] = '.github/dependabot.{yml,yaml}',
          ['https://json.schemastore.org/gitlab-ci'] = '*gitlab-ci*.{yml,yaml}',
          ['https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json'] = '*api*.{yml,yaml}',
          ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = '*docker-compose*.{yml,yaml}',
          ['https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json'] = '*flow*.{yml,yaml}',
        },
        format = { enabled = false },
        validate = false, -- TODO: conflicts between Kubernetes resources and kustomization.yaml
        completion = true,
        hover = true,
      },
    },
    flags = { debounce_text_changes = 150 },
  }
end

-- Configs gleaned elsewhere


-- Diagnostics symbols for display in the sign column.
-- local signs = { Error = "", Warn = "", Hint = "", Info = "" }
-- for type, icon in pairs(signs) do
--   local hl = "DiagnosticSign" .. type
--   vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
-- end
-- vim.cmd('setlocal omnifunc=v:lua.vim.lsp.omnifunc')

-- require'lspconfig'.html.setup {
--   filetypes = {"html", "eruby"},
--   capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- }
-- require'lspconfig'.tsserver.setup{
--   capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- }
-- require'lspconfig'.solargraph.setup{
--   capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- }
-- require'lspconfig'.cssls.setup{
--   capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- }
-- require'lspconfig'.dockerls.setup{
--   capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- }
-- require'lspconfig'.jsonls.setup{
--   commands = {
--     Format = {
--       function()
--         vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line("$"),0})
--       end
--     }
--   },
--   capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- }
-- require'lspconfig'.yamlls.setup{
--   capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- }
-- require'lspconfig'.vimls.setup{
--   capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- }
-- require'lspconfig'.dartls.setup{
--   capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- }
-- require'lspconfig'.rust_analyzer.setup {
--   on_attach = on_attach,
--   settings = {
--     ["rust-analyzer"] = {
--       assist = {
--         importMergeBehavior = "last",
--         importPrefix = "by_self",
--       },
--       diagnostics = {
--         disabled = { "unresolved-import" }
--       },
--       cargo = {
--         loadOutDirsFromCheck = true
--       },
--       procMacro = {
--         enable = true
--       },
--       checkOnSave = {
--         command = "clippy"
--       },
--     }
--   },
--   capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- }
--
-- return nvim_lsp
