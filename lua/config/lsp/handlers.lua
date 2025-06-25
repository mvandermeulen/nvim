--[[
-- LSP Handlers
--
-- Author: Mark van der Meulen
-- Updated: 2025-06-17
--]]


local _name = 'LSP Handlers'
local _log = require('plenary.log').new({ plugin = _name, level = 'debug', use_console = true })
local function mlog(msg, level)
  local level = level or 'debug'
  if level == 'error' then
    vim.api.nvim_err_writeln(msg)
    _log.error(msg)
  elseif level == 'notify' then
    vim.notify(msg, vim.log.levels.INFO, { title = _name })
    _log.info(msg)
  elseif level == 'info' then
    _log.info(msg)
  else
    _log.debug(msg)
  end
end


local M = {}

local navic_status, navic = pcall(require, 'nvim-navic')
-- local present_lsp_signature, lsp_signature = pcall(require, "lsp_signature")
local present_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
local helper_status, helper = pcall(require, 'helpers.lsp')
-- local autocmd_load_status, autocmds = require('config.lsp.autocmd')

if not navic_status or not helper_status then
    mlog('Navic, LSP Helpers, Autocommands, Completion Plugin not found', 'error')
    return
end

if present_cmp_lsp then
    M.capabilities = cmp_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
else
    M.capabilities = vim.lsp.protocol.make_client_capabilities()
end

M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}


local function opts(desc)
  if desc then
    return { noremap = true, silent = true, buffer = true, desc = desc }
  else
    return { noremap = true, silent = true, buffer = true }
  end
end

local function bufnnoremap(lhs, rhs, desc)
  if desc then
    vim.keymap.set('n', lhs, rhs, opts(desc))
  else
    vim.keymap.set('n', lhs, rhs, opts())
  end
end

local function lsp_keymaps(bufnr)
  bufnnoremap("gss", function()
    vim.cmd.vsplit()
    vim.lsp.buf.definition()
  end, 'go-to-definition-vsplit')
  bufnnoremap("gsv", function()
    vim.cmd.split()
    vim.lsp.buf.definition()
  end, 'go-to-definition-split')
  bufnnoremap("gd", vim.lsp.buf.definition, 'go-to-definition')
  bufnnoremap("gD", vim.lsp.buf.declaration, 'go-to-declaration')
  bufnnoremap("gl", vim.diagnostic.open_float, 'show-diagnostics-float')
  bufnnoremap("gm", vim.lsp.buf.implementation, 'go-to-implementation')
  bufnnoremap("gy", vim.lsp.buf.type_definition, 'go-to-type-definition')
  bufnnoremap("gI", vim.lsp.buf.incoming_calls, 'go-to-incoming-calls')
  bufnnoremap("<localleader>gR", vim.lsp.buf.rename, 'lsp-rename')
  bufnnoremap("<localleader>gs", vim.lsp.buf.signature_help, 'show-signature-help')
  bufnnoremap("<localleader>gr", "<cmd>Telescope lsp_references<CR>", 't-lsp-references')
  bufnnoremap("ge", function() require("telescope.builtin").diagnostics({ bufnr = bufnr }) end, 't-lsp-diagnostics')
  bufnnoremap("<localleader>gE", "<cmd>Telescope diagnostics<CR>", "t-lsp-diagnostics")
  bufnnoremap("<localleader>gd", "<cmd>Telescope lsp_definitions<CR>", "t-lsp-definition")
  bufnnoremap("<localleader>gw", "<cmd>Telescope lsp_document_symbols<CR>", "t-lsp-document-symbols")
  bufnnoremap("K", vim.lsp.buf.hover, 'show-hover')
  bufnnoremap("<M-k>", vim.lsp.buf.signature_help, 'show-signature')
  bufnnoremap("<localleader>ca", vim.lsp.buf.code_action, 'lsp-code-action')
  bufnnoremap("<leader>df", vim.diagnostic.open_float, 'show-diagnostics-float')
  bufnnoremap("<leader>dL", vim.diagnostic.setloclist, 'diagnostics-loclist')

  bufnnoremap("gpd", function() require('goto-preview').goto_preview_definition({}) end , 'goto-preview-definition')
  bufnnoremap("gpi", function() require('goto-preview').goto_preview_implementation({}) end , 'goto-preview-implementation')
  bufnnoremap("gpc", function() require('goto-preview').close_all_win() end , 'goto-preview-close')
  bufnnoremap("gpr", function() require('goto-preview').goto_preview_references({}) end , 'goto-preview-references')

  bufnnoremap("<localleader>lr", function() require('fzf-lua').lsp_references() end, 'fzf-lsp-references')
  bufnnoremap("<localleader>ld", function() require('fzf-lua').lsp_definitions() end, 'fzf-lsp-definitions')
  bufnnoremap("<localleader>lD", function() require('fzf-lua').lsp_declarations() end, 'fzf-lsp-declarations')
  bufnnoremap("<localleader>lt", function() require('fzf-lua').lsp_typedefs() end, 'fzf-lsp-typedefs')
  bufnnoremap("<localleader>li", function() require('fzf-lua').lsp_implementations() end, 'fzf-lsp-implementations')
  bufnnoremap("<localleader>ls", function() require('fzf-lua').lsp_document_symbols() end, 'fzf-lsp-document-symbols')
  bufnnoremap("<localleader>lw", function() require('fzf-lua').lsp_live_workspace_symbols() end, 'fzf-lsp-live-workspace-symbols')
  bufnnoremap("<localleader>lW", function() require('fzf-lua').lsp_workspace_symbols() end, 'fzf-lsp-workspace-symbols')
  bufnnoremap("<localleader>lc", function() require('fzf-lua').lsp_incoming_calls() end, 'fzf-lsp-incoming-calls')
  bufnnoremap("<localleader>lC", function() require('fzf-lua').lsp_outgoing_calls() end, 'fzf-lsp-outgoing-calls')
  bufnnoremap("<localleader>la", function() require('fzf-lua').lsp_code_actions() end, 'fzf-lsp-code-actions')
  bufnnoremap("<localleader>lf", function() require('fzf-lua').lsp_finder() end, 'fzf-lsp-finder')
  bufnnoremap("<localleader>lx", function() require('fzf-lua').diagnostics_document() end, 'fzf-lsp-diagnostics-document')
  bufnnoremap("<localleader>lX", function() require('fzf-lua').diagnostics_workspace() end, 'fzf-lsp-diagnostics-workspace')

  -- Already defined in `lua/mappings/custom/normal/overrides.lua`
  -- bufnnoremap("[d", function() vim.diagnostic.goto_prev({ border = "rounded" }) end , 'go-to-previous-diagnostic')
  -- bufnnoremap("]d", function() vim.diagnostic.goto_next({ border = "rounded" }) end , 'go-to-next-diagnostic')
  -- bufnnoremap("gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", 'Declaration')
  -- bufnnoremap("gd", "<cmd>lua vim.lsp.buf.definition()<CR>", 'Definition')
  -- bufnnoremap("K", "<cmd>lua vim.lsp.buf.hover()<CR>", 'Hover')
  -- bufnnoremap("gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", 'Implementation')
  -- bufnnoremap("<M-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", 'Signature')
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts(''))
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts(''))
  -- bufnnoremap("<localleader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", 'Code Action')
  -- bufnnoremap("<leader>df", "<cmd>lua vim.diagnostic.open_float()<CR>", 'Diagnostics Float')
  -- bufnnoremap("[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', 'Previous Diagnostic')
  -- bufnnoremap("]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', 'Next Diagnostic')
  -- bufnnoremap("gl", "<cmd>lua vim.diagnostic.open_float()<CR>", 'Diagnostics Float')
  -- bufnnoremap("<leader>dL", "<cmd>lua vim.diagnostic.setloclist()<CR>", 'Diagnostics Loclist')
  -- bufnnoremap("gpd", "<cmd>lua require('goto-preview').goto_preview_definition({})<CR>", 'Preview Definition')
  -- bufnnoremap("gpi", "<cmd>lua require('goto-preview').goto_preview_implementation({})<CR>", 'Preview Implementation')
  -- bufnnoremap("gpc", "<cmd>lua require('goto-preview').close_all_win()<CR>", 'Close Preview')
  -- bufnnoremap("gpr", "<cmd>lua require('goto-preview').goto_preview_references({})<CR>", 'Preview References')
  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

local function common_keymaps(bufnr)
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

local function client_capabilities(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then
      mlog("LSP Server: " .. client.name .. " has documentSymbolProvider", "debug")
      navic.attach(client, bufnr)
    end
    if client.server_capabilities.signatureHelpProvider then
      mlog("LSP Server: " .. client.name .. " has signatureHelpProvider", "debug")
      vim.lsp.handlers["textDocument/signatureHelp"] = require("noice").signature
    end
    -- if client.server_capabilities.document_formatting then
    --   vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
    -- end
    client.server_capabilities.document_formatting = false
    client.server_capabilities.document_range_formatting = false
    -- if client.server_capabilities.documentFormattingProvider then
    --     client.server_capabilities.documentFormattingProvider = false
    -- end
    if client.server_capabilities.documentRangeFormattingProvider then
        client.server_capabilities.documentRangeFormattingProvider = false
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
    -- if client.server_capabilities.documentHighlightProvider then
    --   mlog("LSP Server: " .. client.name .. " has documentHighlightProvider", "info")
    --   vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
    --   vim.api.nvim_clear_autocmds { buffer = bufnr, group = "lsp_document_highlight" }
    --   vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
    --     desc = "Highlight references under the cursor",
    --     buffer = bufnr,
    --     callback = vim.lsp.buf.document_highlight,
    --   })
    --   vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
    --     desc = "Clear highlight references",
    --     buffer = bufnr,
    --     callback = vim.lsp.buf.clear_references,
    --   })
    -- end
    if client.server_capabilities.semanticTokensProvider then
        client.server_capabilities.semanticTokensProvider = nil
    end

    if client.server_capabilities.goto_definition == true then
        vim.api.nvim_set_option_value("tagfunc", "v:lua.vim.lsp.tagfunc", { buf = bufnr })
    end
end


M.setup = function()
  -- mlog("LSP Handlers setup: Signs", "info")
  local icons = require('helpers.ui.icons')
  local config = {
    virtual_text = false, -- disable virtual text
    signs = { -- show signs
      priority = 20,
      text = {
        [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
        [vim.diagnostic.severity.WARN] = icons.diagnostics.Warning,
        [vim.diagnostic.severity.INFO] = icons.diagnostics.Information,
        [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
      },
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
      relative = "cursor",
    },
  }
  vim.diagnostic.config(config)
  mlog("LSP Handlers setup: Diagnostics", "info")
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
  mlog("LSP Handlers setup: Hover", "info")
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
  mlog("LSP Handlers setup: Signature Help", "info")
  require("lspconfig.ui.windows").default_options.border = "rounded"
end

M.on_attach = function(client, bufnr)
  mlog("LSP Server: " .. client.name .. " starting...", "info")
  common_keymaps(bufnr)
  client_capabilities(client, bufnr)
  lsp_keymaps(bufnr)
  require('config.lsp.autocmd').setup_autocommands(client, bufnr)
  helper.lsp_highlight_document(client)
  -- Set omnifunc
  -- buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
end

return M
