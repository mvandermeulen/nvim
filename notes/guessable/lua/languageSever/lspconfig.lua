local nvim_lsp = require "lspconfig"

-- attch
local key_attach = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end
  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
  local opts = {noremap = true, silent = true}
  buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
end

local servers = {"pyright", "clangd", "texlab"}
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = doc_attach,
    flags = {
      debounce_text_changes = 150
    }
  }
end

-- lspsaga
local map = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}
map("n", "<leader>e", "<cmd>Lspsaga show_line_diagnostics<cr>", opts)
map("n", "<leader>pd", "<cmd>Lspsaga preview_definition<cr>", opts)
map("n", "<leader>jk", "<cmd>Lspsaga diagnostic_jump_prev<cr>", opts)
map("n", "<leader>jj", "<cmd>Lspsaga diagnostic_jump_next<cr>", opts)
map("n", "<leader>D", "<cmd>Lspsaga hover_doc<cr>", opts)
map("n", "<leader>na", "<cmd>Lspsaga rename<cr>", opts)
