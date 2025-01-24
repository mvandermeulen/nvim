--[[
-- LSP Handlers
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-31
--]]

local _log = require('plenary.log').new({ plugin = 'LSP', level = 'debug', use_console = true })
local function mlog(msg, level)
  local level = level or 'debug'
  _log.debug(msg)
end


local M = {}

local navic_status, navic = pcall(require, 'nvim-navic')
if not navic_status then
    mlog('Navic not found', 'error')
    return
end

local helper_status, helper = pcall(require, 'helpers.lsp')
if not helper_status then
    mlog('LSP helpers not found!', 'error')
    return
end


-- local present_lsp_signature, lsp_signature = pcall(require, "lsp_signature")
local present_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")

M.capabilities = vim.lsp.protocol.make_client_capabilities()
if present_cmp_lsp then
  M.capabilities = cmp_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
end
M.capabilities.textDocument.completion.completionItem.snippetSupport = true

local function opts(desc)
  if desc then
    return { noremap = true, silent = true, desc = desc }
  else
    return { noremap = true, silent = true }
  end
end


local function lsp_keymaps(bufnr)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts('Declaration'))
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts('Definition'))
  vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts('Hover'))
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts('Implementation'))
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<M-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts('Signature Help'))
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts(''))
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts(''))
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>Telescope lsp_references<CR>", opts('LSP References'))-- Uses Telescope
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<localleader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts('Code Action'))
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>df", "<cmd>lua vim.diagnostic.open_float()<CR>", opts('Diagnostics Float'))
  vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts('Previous Diagnostic'))
  vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts('Next Diagnostic'))
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts('Diagnostics Float'))
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>dL", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts('Diagnostics Loclist'))
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gpd", "<cmd>lua require('goto-preview').goto_preview_definition({})<CR>", opts('Preview Definition'))
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation({})<CR>", opts('Preview Implementation'))
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gpc", "<cmd>lua require('goto-preview').close_all_win()<CR>", opts('Close Preview'))
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gpr", "<cmd>lua require('goto-preview').goto_preview_references({})<CR>", opts('Preview References'))
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "", "<cmd>lua <CR>", opts(''))
  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

local function common_keymaps(bufnr)
  local function bufnnoremap(lhs, rhs, desc)
    if desc then
      vim.api.nvim_buf_set_keymap(bufnr, 'n', lhs, rhs, opts(desc))
    else
      vim.api.nvim_buf_set_keymap(bufnr, 'n', lhs, rhs, opts())
    end
  end
  -- Keymaps: we need to define keymaps for each of the LSP functionalities manually
  -- Go to definition and declaration (use leader to presever standard use of 'gd')
  bufnnoremap("<localleader>gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", 'Definition')
  bufnnoremap("<localleader>gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", 'Declaration')
  -- Go to implementation
  bufnnoremap("<localleader>gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>", 'Implementation')
  -- List symbol uses
  -- bufnnoremap("<leader>gr", "<cmd>lua vim.lsp.buf.references()<CR>")  -- Uses quickfix
  bufnnoremap("<localleader>gr", "<cmd>Telescope lsp_references<CR>", 'LSP References')  -- Uses Telescope
  -- Inspect function
  bufnnoremap("K", "<Cmd>lua vim.lsp.buf.hover()<CR>", 'Hover')
  -- Signature help
  bufnnoremap("<M-k>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", 'Signature Help')
  -- Rename all references of symbol
  bufnnoremap("<localleader>R", "<Cmd>lua vim.lsp.buf.rename()<CR>", 'Rename')
  -- Navigate diagnostics
  bufnnoremap("<localleader>N", "<Cmd>lua vim.diagnostic.goto_next()<CR>", 'Next Diagnostic')
  bufnnoremap("<localleader>P", "<Cmd>lua vim.diagnostic.goto_prev()<CR>", 'Previous Diagnostic')
end

M.setup = function()
  local signs = helper.configure_signs()
  -- mlog("LSP Handlers setup: Signs", "info")
  local config = {
    virtual_text = false, -- disable virtual text
    signs = { -- show signs
      active = signs,
    },
    update_in_insert = false,
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
  mlog("LSP Handlers setup: Diagnostics", "info")
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
  mlog("LSP Handlers setup: Hover", "info")
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
  mlog("LSP Handlers setup: Signature Help", "info")
  require("lspconfig.ui.windows").default_options.border = "rounded"
  -- Customize windows for Hover and Signature
  -- local float_win_opts = {
  --   border = "rounded",
  --   relative = "cursor",
  --   style = "minimal",
  -- }
  -- vim.lsp.handlers["textDocument/hover"] =
  --   vim.lsp.with(vim.lsp.handlers.hover, vim.tbl_extend("keep", float_win_opts, { focusable = true }))
  -- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  --   vim.lsp.handlers.signature_help,
  --   vim.tbl_extend("keep", float_win_opts, { max_height = 3, focusable = false })
  -- )
end

M.on_attach = function(client, bufnr)
  vim.notify(client.name .. " starting...")
  mlog("LSP Server: " .. client.name .. " starting...", "info")
  client.server_capabilities.document_formatting = false
  client.server_capabilities.document_range_formatting = false
  lsp_keymaps(bufnr)
  helper.lsp_highlight_document(client)
end

-- This function defines the on_attach function for several languages which share the same key-bindings
function M.common_on_attach(client, bufnr)
  vim.notify("LSP Server: " .. client.name .. " starting...")
  -- mlog("common_on_attach LSP Server: " .. client.name .. " starting...", "info")
  -- Set omnifunc
  -- vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  -- Helper function
  common_keymaps(bufnr)
  -- mlog("common_on_attach LSP Server: " .. client.name .. " keymaps set", "info")
  if client.server_capabilities.documentSymbolProvider then
    mlog("LSP Server: " .. client.name .. " has documentSymbolProvider", "info")
    navic.attach(client, bufnr)
  end
  if client.server_capabilities.signatureHelpProvider then
    mlog("LSP Server: " .. client.name .. " has signatureHelpProvider", "info")
    vim.lsp.handlers["textDocument/signatureHelp"] = require("noice").signature
  end
  -- mlog("LSP Server: " .. client.name .. " keymaps set", "info")

  if client.server_capabilities.document_formatting then
    vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
  end
  if client.server_capabilities.textDocument then
    if client.server_capabilities.textDocument.codeLens then
      mlog("LSP Server: " .. client.name .. " has codeLens", "info")
      require("virtualtypes").on_attach(client, bufnr)
      helper.attach_codelens(client, bufnr)
    end
  end
  if client.supports_method "textDocument/inlayHint" then
    mlog("LSP Server: " .. client.name .. " has inlay hints", "info")
    vim.lsp.inlay_hint.enable(true)
  end
  if client.server_capabilities.documentHighlightProvider then
    mlog("LSP Server: " .. client.name .. " has documentHighlightProvider", "info")
    vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
    vim.api.nvim_clear_autocmds { buffer = bufnr, group = "lsp_document_highlight" }
    vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
      desc = "Highlight references under the cursor",
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
      desc = "Clear highlight references",
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
  -- mlog("LSP Server: " .. client.name .. " setup complete", "info")

  -- Markdown preview TODO: make this conditional, but I also don't use it all that much
  -- bufnnnoremap("<leader>P", "<Cmd>Glow<CR>")
  -- if client.server_capabilities.documentSymbolProvider then
  --   navic.attach(client, bufnr)
  -- end
  -- if present_lsp_signature then
  --   lsp_signature.on_attach({ floating_window = false, timer_interval = 500 })
  -- end
  -- require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
end

require('config.lsp.autocmd')

return M
