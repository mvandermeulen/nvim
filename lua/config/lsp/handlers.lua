--[[
-- LSP Handlers
--
-- Author: Mark van der Meulen
-- Updated: 2023-08-10
--]]

local M = {}

local navic_status, navic = pcall(require, 'nvim-navic')
if not navic_status then
  return
end

local notify_status_ok, notify = pcall(require, "notify")
if not notify_status_ok then
  return
end

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
  return
end

local present_lsp_signature, lsp_signature = pcall(require, "lsp_signature")
local present_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")

M.capabilities = vim.lsp.protocol.make_client_capabilities()
if present_cmp_lsp then
  M.capabilities = cmp_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
end
M.capabilities.textDocument.completion.completionItem.snippetSupport = true



M.setup = function()
  local icons = require('helpers.icons')
  local signs = {
    { name = "DiagnosticSignError", text = icons.diagnostics.Error },
    { name = "DiagnosticSignWarn", text = icons.diagnostics.Warning },
    { name = "DiagnosticSignHint", text = icons.diagnostics.Hint },
    { name = "DiagnosticSignInfo", text = icons.diagnostics.Information },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    -- disable virtual text
    virtual_text = false,
    -- show signs
    signs = {
      active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

local function lsp_highlight_document(client)
  if client.resolved_capabilities.document_highlight then
    local status_ok, illuminate = pcall(require, "illuminate")
    if not status_ok then
      return
    end
    illuminate.on_attach(client)
  end
end

local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<M-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>Telescope lsp_references<CR>", opts)-- Uses Telescope
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<localleader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>df", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>dL", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gpd", "<cmd>lua require('goto-preview').goto_preview_definition({})<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation({})<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gpc", "<cmd>lua require('goto-preview').close_all_win()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gpr", "<cmd>lua require('goto-preview').goto_preview_references({})<CR>", opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "", "<cmd>lua <CR>", opts)
  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

M.on_attach = function(client, bufnr)
  vim.notify(client.name .. " starting...")
  client.server_capabilities.document_formatting = false
  client.server_capabilities.document_range_formatting = false
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
  if present_lsp_signature then
    lsp_signature.on_attach({ floating_window = false, timer_interval = 500 })
  end
  lsp_keymaps(bufnr)
  -- lsp_highlight_document(client)
end

-- This function defines the on_attach function for several languages which share the same key-bindings
function M.common_on_attach(client, bufnr)
  vim.notify("LSP Server: " .. client.name .. " starting...")
  -- Set omnifunc
  -- vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  -- Helper function
  local opts = {noremap = true, silent = true}
  local function bufnnoremap(lhs, rhs)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', lhs, rhs, opts)
  end
  -- Keymaps: we need to define keymaps for each of the LSP functionalities manually
  -- Go to definition and declaration (use leader to presever standard use of 'gd')
  bufnnoremap("<localleader>gd", "<Cmd>lua vim.lsp.buf.definition()<CR>")
  bufnnoremap("<localleader>gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>")

  -- Go to implementation
  bufnnoremap("<localleader>gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>")

  -- List symbol uses
  -- bufnnoremap("<leader>gr", "<cmd>lua vim.lsp.buf.references()<CR>")  -- Uses quickfix
  bufnnoremap("<localleader>gr", "<cmd>Telescope lsp_references<CR>")  -- Uses Telescope

  -- Inspect function
  bufnnoremap("K", "<Cmd>lua vim.lsp.buf.hover()<CR>")

  -- Signature help
  bufnnoremap("<A-k>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>")

  -- Rename all references of symbol
  bufnnoremap("<localleader>R", "<Cmd>lua vim.lsp.buf.rename()<CR>")

  -- Navigate diagnostics
  bufnnoremap("<localleader>N", "<Cmd>lua vim.diagnostic.goto_next()<CR>")
  bufnnoremap("<localleader>P", "<Cmd>lua vim.diagnostic.goto_prev()<CR>")

  -- Markdown preview TODO: make this conditional, but I also don't use it all that much
  -- bufnnnoremap("<leader>P", "<Cmd>Glow<CR>")

  if client.server_capabilities.document_formatting then
    vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
  end
end


function M.enable_format_on_save()
  vim.cmd [[
    augroup format_on_save
      autocmd! 
      autocmd BufWritePre * lua vim.lsp.buf.formatting()
    augroup end
  ]]
  vim.notify "Enabled format on save"
end

function M.disable_format_on_save()
  M.remove_augroup "format_on_save"
  vim.notify "Disabled format on save"
end

function M.toggle_format_on_save()
  if vim.fn.exists "#format_on_save#BufWritePre" == 0 then
    M.enable_format_on_save()
  else
    M.disable_format_on_save()
  end
end

function M.remove_augroup(name)
  if vim.fn.exists("#" .. name) == 1 then
    vim.cmd("au! " .. name)
  end
end

vim.cmd [[ command! LspToggleAutoFormat execute 'lua require("user.lsp.handlers").toggle_format_on_save()' ]]

return M
