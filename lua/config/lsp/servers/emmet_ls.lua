--[[
-- LSP Server: emmet_ls
--
-- Author: Mark van der Meulen
-- Updated: August 09, 2023
--]]

-- npm i -g ls_emmet
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local settings = {
  cmd = { "ls_emmet", "--stdio" },
}

local opts = {
  capabilities = capabilities,
  filetypes = {
    "html",
    "css",
    "scss",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "haml",
    "xml",
    "xsl",
    "pug",
    "slim",
    "sass",
    "stylus",
    "less",
    "pug",
    "sass",
    "scss",
    "svelte",
    "hbs",
    "handlebars",
    "vue",
  },
  settings = {
    emmet_ls = settings,
  },
  init_options = {
    html = {
      options = {
        -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
        ["bem.enabled"] = true,
      },
    },
  },
}

-- opts.capabilities = require("cmp_nvim_lsp").default_capabilities()
-- opts.capabilities.textDocument.completion.completionItem.snippetSupport = true

return opts
