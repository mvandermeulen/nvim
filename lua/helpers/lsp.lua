--[[
-- LSP Helpers
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

function M.get_pkg_path(pkg, path, opts)
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
function M.organize_imports(client, bufnr)
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

function M.configure_signs()
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

function M.toggle_diagnostics()
  if not vim.g.diag_is_hidden then
    require("notify")("Diagnostic virtual text is now hidden.", vim.log.levels.INFO)
    vim.diagnostic.hide()
  else
    require("notify")("Diagnostic virtual text is now visible.", vim.log.levels.INFO)
    vim.diagnostic.show()
  end
  vim.g.diag_is_hidden = not vim.g.diag_is_hidden
end

function M.lsp_highlight_document(client)
  if client.server_capabilities.documentHighlightProvider then
    local status_ok, illuminate = pcall(require, "illuminate")
    if not status_ok then
      return
    end
    illuminate.on_attach(client)
  end
end

function M.attach_codelens(_, bufnr)
  vim.api.nvim_create_autocmd({ "BufReadPost", "CursorHold", "InsertLeave" }, {
    buffer = bufnr,
    callback = function()
      vim.lsp.codelens.refresh { bufnr = bufnr }
    end,
  })
end

function M.print_lsp_server_capabilities()
  local client_id = vim.lsp.get_clients()
  if next(client_id) == nil then
    print("No active LSP clients")
    return
  end
  local client = client_id[1]
  if client ~= nil then
    local cap = vim.inspect(client.server_capabilities)
    -- Print cap to buffer (it has newline)
    vim.api.nvim_command("new")
    for line in cap:gmatch("[^\r\n]+") do
      vim.api.nvim_buf_set_lines(0, -1, -1, false, { line })
    end
  end
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



return M
