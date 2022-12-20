local lsp = vim.lsp
local cmd = vim.cmd
local api = vim.api
local g = vim.g

local utils = require('fymyte.utils')

-- Use rounded corners for lsp too
local border = 'rounded'
local orig_util_open_floating_preview = lsp.util.open_floating_preview
function lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

lsp.set_log_level(g.log_level)

--- Goto definition in split window, see
--- [lspconfig wiki](https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#go-to-definition-in-a-split-window)
--vim.lsp.handlers["textDocument/definition"] = goto_definition('vsplit')

--- Provide additional key mappings when a lsp server is attached
local function custom_attach(client, bufnr)
  -- Mappings.
  utils.buf_map(bufnr, { 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>' } )
  utils.buf_map(bufnr, { 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>' } )
  utils.buf_map(bufnr, { 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>' } )
  utils.buf_map(bufnr, { 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>' } )
  utils.buf_map(bufnr, { 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>' } )
  utils.buf_map(bufnr, { 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>' } )
  utils.buf_map(bufnr, { 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>' } )
  utils.buf_map(bufnr, { 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>' } )
  utils.buf_map(bufnr, { 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>' } )
  utils.buf_map(bufnr, { 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>' } )
  utils.buf_map(bufnr, { 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>' } )
  utils.buf_map(bufnr, { 'v', '<space>ca', '<cmd>lua vim.lsp.buf.range_code_action()<CR>' } )
  utils.buf_map(bufnr, { 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>' } )
  utils.buf_map(bufnr, { 'n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>' } )
  utils.buf_map(bufnr, { 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>' } )
  utils.buf_map(bufnr, { 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>' } )
  utils.buf_map(bufnr, { 'n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>' } )
  utils.buf_map(bufnr, { 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>' } )

  -- Show line diagnostic on cursor hold
  -- vim.cmd([[autocmd CursorHold <buffer> lua vim.diagnostic.open_float()]])

  utils.log('info', string.format("Language server %s attached", client.name))
end

-- Setup lspconfig.
-- Provide settings first!
local has_lsp_installer, lsp_installer = pcall(require, 'nvim-lsp-installer')
if not has_lsp_installer then
  return
end

lsp_installer.settings {
    ui = {
        icons = {
            server_installed = "",
            server_pending = "",
            server_uninstalled = "",
        }
    }
}
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local default_opts = {
  on_attach = custom_attach,
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = capabilities,
  log_level = vim.log.levels.TRACE,
}

local function ensure_lsp_installed(servers)
  for _, name in pairs(servers) do
    local server_is_found, server = lsp_installer.get_server(name)
    if server_is_found then
      if not server:is_installed() then
        utils.log('warn', 'Server ' .. name .. ' not installed. Installing...')
        server:install()
      end
    end
  end
end

--local custom_pylsp_name = 'pylsp-full'
--local lspconfig_configs = require('lspconfig.configs')
--local lspconfig_util = require('lspconfig.util')
--local pip3 = require('nvim-lsp-installer.installers.pip3')
--local lsp_installer_servers = require('nvim-lsp-installer.servers')
--local lsp_installer_server = require('nvim-lsp-installer.server')
--local root_dir = lsp_installer_server.get_server_root_path(custom_pylsp_name)
--lspconfig_configs[custom_pylsp_name] = {
--  default_config = {
--    cmd = { 'pylsp' },
--    filetypes = { 'python' },
--    root_dir = function(fname)
--      local root_files = {
--        'pyproject.toml',
--        'setup.py',
--        'setup.cfg',
--        'requirements.txt',
--        'Pipfile',
--      }
--      return lspconfig_util.root_pattern(unpack(root_files))(fname) or lspconfig_util.find_git_ancestor(fname)
--    end,
--    single_file_support = true,
--  },
--}
--local custom_pylsp_server = lsp_installer_server.Server:new( {
--  name = custom_pylsp_name,
--  root_dir = root_dir,
--  installer = pip3.packages( { 'python-lsp-server[all]', 'pylsp-mypy', 'pylsp-rope', 'pyls-isort', 'pyls-flake8' } ),
--  default_options = { pip3.executable(root_dir, "pylsp") },
--} )
--lsp_installer_servers.register(custom_pylsp_server)
local servers = { 'rust_analyzer', 'clangd', 'sumneko_lua', 'vimls', 'bashls', 'cmake' }
--local servers = { 'pylsp' }
ensure_lsp_installed(servers)

lsp_installer.on_server_ready(function(server)
  local runtime_path = vim.split(package.path, ";")
  table.insert(runtime_path, "lua/?.lua")
  table.insert(runtime_path, "lua/?/init.lua")
  local server_opts = {
    ['sumneko_lua'] = function ()
      default_opts.settings = {
        Lua = {
          runtime = {
            version = "LuaJIT", -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
            path = runtime_path, -- Setup your lua path
          },
          diagnostics = { globals = { "vim" }, }, -- Get the language server to recognize the `vim` global
          workspace = { library = api.nvim_get_runtime_file("", true) }, -- Make the server aware of Neovim runtime files
          telemetry = { enable = false },
          hint = { setType = true },
        }
      }
      return default_opts
    end,
    ['pylsp'] = function ()
      default_opts.settings = {
        pylsp = {
          configurationSources = { 'pylsp_flake8', 'pylsp_mypy' },
          plugins = {
            yapf = { enabled = true },
            autopep8 = { enabled = false },
            pylint = { enabled = true },
            jedi_completion = { fuzzy = true },
            pyls_isort = { enabled = true },
            pyls_flake8 = { enabled = true },
            pylsp_mypy = { enabled = true, strict = true },
            pylsp_rope = { enabled = true },
          },
        },
      }
      return default_opts
    end,
  }

  server:setup(server_opts[server.name] and server_opts[server.name]() or default_opts)
  vim.cmd([[do User LspAttachBuffers]])
  utils.log('info', ('Language server %q is ready'):format(server.name))
end)

require('lspconfig').als.setup{
    settings = {
      ada = {
        projectFile = "morpion.gpr";
        scenarioVariables = { ... };
      }
    }
}


-- setup rust-tools
require('rust-tools').setup({})


