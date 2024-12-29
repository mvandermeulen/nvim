--[[
-- LSP Handlers
--
-- Author: Mark van der Meulen
-- Updated: 2023-08-10
--]]
local _log = require('plenary.log').new({ plugin = 'LSP', level = 'debug', use_console = true })
local function mlog(msg, level)
  local level = level or 'debug'
  _log.debug(msg)
  if level == 'info' or level == 'warn' or level == 'error' then
    vim.notify(msg, vim.log.levels.INFO)
  end
end


local M = {}

local navic_status, navic = pcall(require, 'nvim-navic')
if not navic_status then
  mlog('Navic not found', 'error')
  return
end

-- local present_lsp_signature, lsp_signature = pcall(require, "lsp_signature")
local present_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")

M.capabilities = vim.lsp.protocol.make_client_capabilities()
if present_cmp_lsp then
  M.capabilities = cmp_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
end
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
-- M.capabilities.textDocument.completion.completionItem = {
--   documentationFormat = { "markdown", "plaintext" },
--   snippetSupport = true,
--   preselectSupport = true,
--   insertReplaceSupport = true,
--   labelDetailsSupport = true,
--   deprecatedSupport = true,
--   commitCharactersSupport = true,
--   tagSupport = { valueSet = { 1 } },
--   resolveSupport = {
--     properties = {
--       "documentation",
--       "detail",
--       "additionalTextEdits",
--     },
--   },
-- }

local function get_pkg_path(pkg, path, opts)
  local root = vim.env.MASON or (vim.fn.stdpath "data" .. "/mason")
  opts = opts or {}
  opts.warn = opts.warn == nil and true or opts.warn
  path = path or ""
  local ret = root .. "/packages/" .. pkg .. "/" .. path
  return ret
end

---gopls_organize_imports will organize imports for the provided buffer
---@param client vim.lsp.Client gopls instance
---@param bufnr number buffer to organize imports for
local function organize_imports(client, bufnr)
  local params = vim.lsp.util.make_range_params()
  params.context = { only = { "source.organizeImports" } }

  local resp = client.request_sync("textDocument/codeAction", params, 3000, bufnr)
  for _, r in pairs(resp and resp.result or {}) do
    if r.edit then
      vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding or "utf-16")
    else
      vim.lsp.buf.execute_command(r.command)
    end
  end
end


local function attach_codelens(_, bufnr)
  vim.api.nvim_create_autocmd({ "BufReadPost", "CursorHold", "InsertLeave" }, {
    buffer = bufnr,
    callback = function()
      vim.lsp.codelens.refresh { bufnr = bufnr }
    end,
  })
end


local function configure_signs()
  local icons = require('helpers.ui.icons')
  local signs = {
    { name = "DiagnosticSignError", text = icons.diagnostics.Error },
    { name = "DiagnosticSignWarn", text = icons.diagnostics.Warning },
    { name = "DiagnosticSignHint", text = icons.diagnostics.Hint },
    { name = "DiagnosticSignInfo", text = icons.diagnostics.Information },
  }
  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end
  return signs
end

local function toggle_diagnostics()
  if not vim.g.diag_is_hidden then
    require("notify")("Diagnostic virtual text is now hidden.", vim.log.levels.INFO)
    vim.diagnostic.hide()
  else
    require("notify")("Diagnostic virtual text is now visible.", vim.log.levels.INFO)
    vim.diagnostic.show()
  end
  vim.g.diag_is_hidden = not vim.g.diag_is_hidden
end

local function lsp_highlight_document(client)
  if client.server_capabilities.documentHighlightProvider then
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
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
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

local function common_keymaps(bufnr)
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
  bufnnoremap("<M-k>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>")
  -- Rename all references of symbol
  bufnnoremap("<localleader>R", "<Cmd>lua vim.lsp.buf.rename()<CR>")
  -- Navigate diagnostics
  bufnnoremap("<localleader>N", "<Cmd>lua vim.diagnostic.goto_next()<CR>")
  bufnnoremap("<localleader>P", "<Cmd>lua vim.diagnostic.goto_prev()<CR>")
end

M.setup = function()
  local signs = configure_signs()
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
  lsp_highlight_document(client)
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
      attach_codelens(client, bufnr)
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

M.toggle_inlay_hints = function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {})
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

vim.cmd [[ command! LspToggleAutoFormat execute 'lua require("config.lsp.handlers").toggle_format_on_save()' ]]
-- Switch to git root or file parent dir
vim.api.nvim_create_user_command('LspToggleDiagnostics', function()
    toggle_diagnostics()
end, {})


return M
