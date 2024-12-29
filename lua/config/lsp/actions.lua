local M = {}

local code_action = vim.lsp.buf.code_action

--- Applies the code action with the given prefix
--- Example: `actions.apply("Wrap in Some")`
--- @param prefix string
-- local function apply(prefix)
M.apply = function(prefix)
  code_action({
      apply = true,
      filter = function(action)
          local title = vim.fn.trim(action.title)
          return vim.startswith(title, prefix)
      end,
  })
end

--- Applies quickfix and can be filtered by providing the preferred action depending on the diagnostic
--- Example: `
---   local options = {
---     ["E0425"] = "Import"
---     ["unused-local"] = "Disable diagnostics on this line"
---   }
---   actions.quickfix(options)
--- `
---@param options table<string, string> | nil
-- local function quickfix(options)
M.quickfix = function(options)
  code_action({
    apply = true,
    context = {
      only = { "quickfix" },
    },
    filter = function(action)
      local found = false
      local diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
      for code, fix_message in pairs(options or {}) do
        for _, diagnostic in pairs(diagnostics) do
          if diagnostic.code == code then
            found = true
            local title = vim.fn.trim(action.title)
            if vim.startswith(title, fix_message) then
              return true
            end
          end
        end
      end
      return not found
    end,
  })
end

--- Tries to fix the next diagnostic
-- local function quickfix_next(options)
M.quickfix_next = function(options)
  vim.diagnostic.goto_next()
  M.quickfix(options)
end

--- Tries to fix the previous diagnostic
-- local function quickfix_prev(options)
M.quickfix_prev = function(options)
  vim.diagnostic.get_prev()
  M.quickfix(options)
end

--- Quick refactor
-- local function refactor()
M.refactor = function()
  code_action({
    apply = true,
    context = {
      only = { "refactor" },
    },
  })
end

--- Same concept as above
-- local function source()
M.source = function()
  code_action({
    apply = true,
    context = {
      only = { "source" },
    },
  })
end

-- Taken from https://www.reddit.com/r/neovim/comments/gyb077/nvimlsp_peek_defination_javascript_ttserver/
local function preview_location(location, context, before_context)
  -- location may be LocationLink or Location (more useful for the former)
  context = context or 15
  before_context = before_context or 0
  local uri = location.targetUri or location.uri
  if uri == nil then
    return
  end
  local bufnr = vim.uri_to_bufnr(uri)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end

  local range = location.targetRange or location.range
  local contents = vim.api.nvim_buf_get_lines(
    bufnr,
    range.start.line - before_context,
    range["end"].line + 1 + context,
    false
  )
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  return vim.lsp.util.open_floating_preview(contents, filetype)
end

local function preview_location_callback(_, method, result)
  local context = 15
  if result == nil or vim.tbl_isempty(result) then
    print("No location found: " .. method)
    return nil
  end
  if vim.tbl_islist(result) then
    M.floating_buf, M.floating_win = preview_location(result[1], context)
  else
    M.floating_buf, M.floating_win = preview_location(result, context)
  end
end

-- local function PeekDefinition()
function M.PeekDefinition()
  if vim.tbl_contains(vim.api.nvim_list_wins(), M.floating_win) then
    vim.api.nvim_set_current_win(M.floating_win)
  else
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(0, "textDocument/definition", params, preview_location_callback)
  end
end

-- local function PeekTypeDefinition()
function M.PeekTypeDefinition()
  if vim.tbl_contains(vim.api.nvim_list_wins(), M.floating_win) then
    vim.api.nvim_set_current_win(M.floating_win)
  else
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(0, "textDocument/typeDefinition", params, preview_location_callback)
  end
end

-- local function PeekImplementation()
function M.PeekImplementation()
  if vim.tbl_contains(vim.api.nvim_list_wins(), M.floating_win) then
    vim.api.nvim_set_current_win(M.floating_win)
  else
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(0, "textDocument/implementation", params, preview_location_callback)
  end
end

local _winnr
local _prompt_str = "New Name❯ "

-- local function rename()
function M.rename()
  local currName = vim.fn.expand("<cword>")
  local opts = {
    style = "minimal",
    border = "rounded",
    relative = "cursor",
    width = 40,
    height = 1,
    row = 1,
    col = 1,
  }
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")

  _winnr = vim.api.nvim_open_win(bufnr, true, opts)
  vim.api.nvim_win_set_option(_winnr, "scrolloff", 0)
  vim.api.nvim_win_set_option(_winnr, "sidescrolloff", 0)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "prompt")

  vim.fn.prompt_setprompt(bufnr, _prompt_str)
  vim.fn.matchaddpos("Conditional", { { 1, 1, #_prompt_str } })

  -- DOES NOT WORK IN 'prompt' BUFFER
  -- api.nvim_buf_set_text(bufnr, 0, 0, 0, 0, {currName})
  -- api.nvim_buf_set_lines(bufnr, -1, -1, 1, {currName})
  -- vim.fn.append(1, currName)

  vim.api.nvim_command("startinsert!")
  vim.api.nvim_feedkeys(currName, "n", true)

  local map_opts = { silent = true, buffer = bufnr }
  vim.keymap.set("i", "<esc>", "<CMD>stopinsert <BAR> q!<CR>", map_opts)
  vim.keymap.set("i", "<C-c>", "<CMD>stopinsert <BAR> q!<CR>", map_opts)
  vim.keymap.set("i", "<CR>", "<CMD>stopinsert <BAR> lua require('config.lsp.actions')._rename()<CR>", map_opts)
end

-- see neovim #15504
-- https://github.com/neovim/neovim/pull/15504#discussion_r698424017
local function handler(...)
  local result
  local method
  local err = select(1, ...)
  local is_new = not select(4, ...) or type(select(4, ...)) ~= "number"
  if is_new then
    method = select(3, ...).method
    result = select(2, ...)
  else
    method = select(2, ...)
    result = select(3, ...)
  end
  if err then
    vim.notify(("Error running LSP query '%s': %s")
      :format(method, err), vim.log.levels.WARN)
    return
  end
  -- echo the resulting changes
  if result and (result.changes or result.documentChanges) then
    for f, c in pairs(result.changes or result.documentChanges) do
      require("notify")(([["%s", %d change(s)]]):format(c.textDocument and c.textDocument.uri or f, #c), vim.log.levels.INFO)
      -- utils.info(([["%s", %d change(s)]]):format(c.textDocument and c.textDocument.uri or f, #c))
    end
  end
  vim.lsp.handlers[method](...)
end

-- local function _rename()
function M._rename()
  local winnr = vim.api.nvim_get_current_win()
  if winnr ~= _winnr then return end
  local newName = vim.trim(vim.fn.getline("."):sub(#_prompt_str, -1))
  vim.api.nvim_win_close(winnr, true)
  local params = vim.lsp.util.make_position_params()
  local currName = vim.fn.expand("<cword>")
  if not (newName and #newName > 0) or newName == currName then
    return
  end
  params.newName = newName
  vim.lsp.buf_request(0, "textDocument/rename", params, handler)
end

return M
-- return {
--   rename = rename,
--   _rename = _rename,
-- }
