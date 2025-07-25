--[[
-- LSP Autocmd
--
-- Author: Mark van der Meulen
-- Updated: 2025-06-17
--]]


local _name = 'LSP Autocmd'
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

local fmt = string.format
local userapi_status_ok, userapi = pcall(require, 'helpers.user.api')
if not userapi_status_ok then
    mlog('Could not load user api', 'error')
    return
end

local M = {}


local FEATURES = {
    DIAGNOSTICS = { name = "diagnostics" },
    CODELENS = { name = "codelens", provider = "codeLensProvider" },
    FORMATTING = { name = "formatting", provider = "documentFormattingProvider" },
    REFERENCES = { name = "references", provider = "documentHighlightProvider" },
}

---@param bufnr integer
---@param capability string
---@return table[]
local function clients_by_capability(bufnr, capability)
    return vim.tbl_filter(function(c)
        return c.server_capabilities[capability]
    end, lsp.get_clients({ buffer = bufnr }))
end

--- Create augroups for each LSP feature and track which capabilities each client
--- registers in a buffer local table
---@param bufnr integer
---@param _client table
---@param events table
---@return fun(feature: table, commands: fun(string): Autocommand[])
local function augroup_factory(bufnr, _client, events)
    return function(feature, commands)
        local provider, name = feature.provider, feature.name
        if not provider or _client.server_capabilities[provider] then
            events[name].group_id = userapi.laugroup(fmt("LspCommands_%d_%s", bufnr, name), commands(provider))
            table.insert(events[name].clients, _client.id)
        end
    end
end


---@param opts table<string, any>
-- local function format(opts)
--     opts = opts or {}
--     vim.lsp.buf.format({
--         bufnr = opts.bufnr,
--         async = opts.async,
--         filter = formatting_filter,
--     })
-- end


--- Autocommands are created per buffer per feature, i.e. if buffer 8 attaches an LSP server
--- then an augroup with the pattern `LspCommands_8_{FEATURE}` will be created. These augroups are
--- localised to a buffer because the features are local to only that buffer and when we detach we need to delete
--- the augroups by buffer so as not to turn off the LSP for other buffers. The commands are also localised
--- to features because each autocommand for a feature e.g. formatting needs to be created in an idempotent
--- fashion because this is called n number of times for each client that attaches.
---
--- So if there are 3 clients and 1 supports formatting and another code lenses, and the last only references.
--- All three features should work and be setup. If only one augroup is used per buffer for all features then each time
--- a client detaches all lsp features will be disabled. Or the augroup will be recreated for the new client but
--- as a client might not support functionality that was already in place, the augroup will be deleted and recreated
--- without the commands for the features that that client does not support.
--- TODO: find a way to make this less complex...
---@param client table<string, any>
---@param bufnr number
M.setup_autocommands = function(bclient, bufnr)
    if not bclient then
        local msg = fmt("Unable to setup LSP autocommands, client for %d is missing", bufnr)
        return vim.notify(msg, 4, { title = "LSP Setup" })
    end

    local events = vim.F.if_nil(vim.b.lsp_events, {
        [FEATURES.CODELENS.name] = { clients = {}, group_id = nil },
        [FEATURES.FORMATTING.name] = { clients = {}, group_id = nil },
        [FEATURES.DIAGNOSTICS.name] = { clients = {}, group_id = nil },
        [FEATURES.REFERENCES.name] = { clients = {}, group_id = nil },
    })

    vim.api.nvim_create_user_command('LspToggleAutoFormat', function()
      require('helpers.lsp').toggle_format_on_save()
    end, {})

    vim.api.nvim_create_user_command('LspToggleDiagnostics', function()
      require('helpers.lsp').toggle_diagnostics()
    end, {})

    vim.api.nvim_create_user_command('LspToggleInlayHints', function()
      require('helpers.lsp').toggle_inlay_hints()
    end, {})

    ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
    local progress = vim.defaulttable()
    vim.api.nvim_create_autocmd("LspProgress", {
      ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
        if not client or type(value) ~= "table" then
          return
        end
        local p = progress[client.id]

        for i = 1, #p + 1 do
          if i == #p + 1 or p[i].token == ev.data.params.token then
            p[i] = {
              token = ev.data.params.token,
              msg = ("[%3d%%] %s%s"):format(
                value.kind == "end" and 100 or value.percentage or 100,
                value.title or "",
                value.message and (" **%s**"):format(value.message) or ""
              ),
              done = value.kind == "end",
            }
            break
          end
        end

        local msg = {} ---@type string[]
        progress[client.id] = vim.tbl_filter(function(v)
          return table.insert(msg, v.msg) or not v.done
        end, p)

        local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        vim.notify(table.concat(msg, "\n"), "info", {
          id = "lsp_progress",
          title = client.name,
          opts = function(notif)
            notif.icon = #progress[client.id] == 0 and " "
              or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
          end,
        })
      end,
    })


    local augroup = augroup_factory(bufnr, bclient, events)

    augroup(FEATURES.DIAGNOSTICS, function()
        return {
            -- {
            --     event = { "CursorHold" },
            --     buffer = bufnr,
            --     desc = "LSP: Show diagnostics",
            --     command = function(args)
            --         vim.diagnostic.open_float(args.buf, { scope = "cursor", focus = false })
            --     end,
            -- },
            {
                event = { "BufEnter" },
                pattern = { ".env" },
                desc = "LSP: Disable Diagnostics for .env file",
                command = function()
                    vim.diagnostic.disable(0)
                end,
            },
        }
    end)

    -- augroup(FEATURES.FORMATTING, function(provider)
    --     return {
    --         {
    --             event = "BufWritePre",
    --             buffer = bufnr,
    --             desc = "LSP: Format on save",
    --             command = function(args)
    --                 if not vim.g.formatting_disabled and not vim.b.formatting_disabled then
    --                     local clients = clients_by_capability(args.buf, provider)
    --                     format({ bufnr = args.buf, async = #clients == 1 })
    --                 end
    --             end,
    --         },
    --     }
    -- end)

    -- augroup(FEATURES.CODELENS, function()
    --     return {
    --         {
    --             event = { "BufEnter", "CursorHold", "InsertLeave" },
    --             desc = "LSP: Code Lens",
    --             buffer = bufnr,
    --             command = function()
    --                 if #clients_by_capability(bufnr, "codeLensProvider") then
    --                     lsp.codelens.refresh()
    --                 end
    --             end,
    --         },
    --     }
    -- end)

    augroup(FEATURES.REFERENCES, function()
        return {
            {
                event = { "CursorHold", "CursorHoldI", "InsertLeave" },
                buffer = bufnr,
                desc = "LSP: References",
                command = function()
                    vim.lsp.buf.document_highlight()
                end,
            },
            {
                event = { "CursorMoved", "InsertEnter", "BufLeave" },
                desc = "LSP: References Clear",
                buffer = bufnr,
                command = function()
                    vim.lsp.buf.clear_references()
                end,
            },
        }
    end)

    vim.b[bufnr].lsp_events = events
end





return M
