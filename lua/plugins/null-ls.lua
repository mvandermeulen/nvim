--[[
-- Language Server
--
-- Author: Mark van der Meulen
-- Updated: 09-05-2022
--]]

local null_ls_status_ok, null_ls = pcall(require, 'null-ls')
if not null_ls_status_ok then
  return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

-- https://github.com/prettier-solidity/prettier-plugin-solidity
-- npm install --save-dev prettier prettier-plugin-solidity
null_ls.setup {
  debug = false,
  sources = {
    formatting.prettier.with {
      extra_filetypes = { 'toml', 'solidity' },
      extra_args = { '--no-semi', '--single-quote', '--jsx-single-quote' },
    },
    formatting.black.with { extra_args = { '--fast' } },
    diagnostics.golangci_lint,
    formatting.stylua,
    diagnostics.eslint,
    formatting.terraform_fmt,
  },
  -- on_attach = function(client)
  -- 	if client.resolved_capabilities.document_formatting then
  -- 		-- auto format on save (not asynchronous)
  -- 		vim.cmd([[
  --            augroup LspFormatting
  --                autocmd! * <buffer>
  --                autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
  --            augroup END
  --            ]])
  -- 	end
  -- end,
}
