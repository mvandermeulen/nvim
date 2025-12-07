--[[
-- UV Integration Plugin
-- Author: Mark van der Meulen
-- Updated: 2025-10-16
--]]


-- Link: 

return {
  {
    "neovim/nvim-lspconfig",
    ft = "python",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    priority = 100,
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Setup clean diagnostic display with signs only
      vim.diagnostic.config({
        virtual_text = false,
        float = {
          source = "always",
          border = "rounded",
          max_width = 80,
          max_height = 20,
          wrap = true,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Set updatetime for faster CursorHold trigger
      vim.opt.updatetime = 500

      -- Show diagnostic float when cursor is on error line
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          local opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = "rounded",
            source = false,
            prefix = "",
            scope = "cursor",
            header = "",
            format = function(diagnostic)
              return diagnostic.message
            end,
          }
          vim.diagnostic.open_float(nil, opts)
        end
      })

      -- Configure LSP hover handler
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
        max_width = 80,
        max_height = 20,
        wrap = true,
      })

      -- BasedPyright configuration
      vim.lsp.config['basedpyright'] = {
        capabilities = capabilities,
        filetypes = { "python" },
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              exclude = { "**/node_modules", "**/__pycache__" },
              ignore = { "**/migrations" },
            },
          },
        },
      }

      -- Ruff LSP configuration
      vm.lsp.config['ruff'] ={
        capabilities = capabilities,
        filetypes = { "python" },
        init_options = {
          settings = {
            logLevel = "error",
            args = {
              "--config", vim.fn.expand("~/ruff.toml")
            },
          }
        },
        on_attach = function(client, bufnr)
          -- Disable hover in favor of BasedPyright
          client.server_capabilities.hoverProvider = false
        end,
      }

      -- LSP keybindings
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }

          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        end,
      })
    end,
  }
}
