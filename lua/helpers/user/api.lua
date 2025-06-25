--[[
-- Helpers: API
--
-- Author: Mark van der Meulen
-- Updated: 2025-06-17
--]]

-- Helpers and utilities for vim.api
local api = vim.api

local M = {}

---@param bufnr? number @the buffer number to resolve (defaults to current buffer)
---@return number|nil @the resolved buffer number or nil if the buffer is invalid
function M.resolve_bufnr(bufnr)
  local resolved = bufnr ~= 0 and bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(resolved) then
    return nil
  end
  return resolved
end

---@param winnr? number @the window number to resolve
---@return number|nil @the resolved window number or nil if the window is invalid
function M.resolve_winnr(winnr)
  local resolved = winnr ~= 0 and winnr or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(resolved) then
    return nil
  end
  return resolved
end

---@param tabnr? number @the tabpage number to resolve
---@return number|nil @the resolved tabpage number or nil if the tabpage is invalid
function M.resolve_tabnr(tabnr)
  local resolved = tabnr ~= 0 and tabnr or vim.api.nvim_get_current_tabpage()
  if not vim.api.nvim_tabpage_is_valid(resolved) then
    return nil
  end
  return resolved
end

---@param win? number @the window number
---@param name string @the buffer option name
---@return any @the option value or nil if the window/option is invalid
function M.win_get_buf_option(win, name)
  win = M.resolve_winnr(win)
  if not win then
    return nil
  end
  local buf = api.nvim_win_get_buf(win)
  if not buf then
    return nil
  end
  return vim.bo[buf][name]
end

---@param win? number @the window number
---@param name string @the buffer option name
---@return any @the option value or nil if the window/option is invalid
function M.win_get_buf_var(win, name)
  win = M.resolve_winnr(win)
  if not win then
    return nil
  end
  local buf = api.nvim_win_get_buf(win)
  if not buf then
    return nil
  end
  return api.nvim_buf_get_var(buf, name)
end

---@param win? number @the window number
---@return boolean @true if the window is modified
function M.win_is_modified(win)
  win = M.resolve_winnr(win)
  if not win then
    return false
  end
  return M.win_get_buf_option(win, 'modified')
end

---@param win? number @the window number
---@return boolean @true if the window is floating
function M.win_is_floating(win)
  win = M.resolve_winnr(win)
  if not win then
    return false
  end
  local cfg = vim.api.nvim_win_get_config(win)
  if not cfg then
    return false
  end
  return cfg.relative and cfg.relative ~= '' and true or false
end

---@param tabpage? number @the tabpage number
---@return boolean @true if the tabpage is modified
function M.tabpage_is_modified(tabpage)
  tabpage = M.resolve_tabnr(tabpage)
  if not tabpage then
    return false
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    if M.win_is_modified(win) then
      return true
    end
  end
  return false
end

---@param tabpage? number @the tabpage number
---@return number[] @the buffer numbers in the tabpage
function M.tabpage_list_bufs(tabpage)
  tabpage = M.resolve_tabnr(tabpage)
  if not tabpage then
    return {}
  end
  local bufs = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if bufs[buf] ~= nil then
      return {}
    end
    bufs[buf] = true
  end
  return vim.tbl_keys(bufs)
end

---@param tabpage? number @the tabpage number
---@return number|nil @the quickfix window number or nil if the tabpage has no quickfix window
function M.tabpage_get_quickfix_win(tabpage)
  tabpage = M.resolve_tabnr(tabpage)
  if not tabpage then
    return nil
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    if M.win_get_buf_option(win, 'buftype') == 'quickfix' then
      return win
    end
  end
  return nil
end

---@param tabpage? number @the tabpage number
---@return number[] @the buffer numbers in the tabpage that are modified
function M.tabpage_list_modified_bufs(tabpage)
  tabpage = M.resolve_tabnr(tabpage)
  if not tabpage then
    return {}
  end
  return vim.tbl_filter(function(buf)
    return vim.bo[buf].modified
  end, M.tabpage_list_bufs(tabpage))
end

---@param buf? number @the buffer number
---@return boolean @true if the buffer is empty
function M.buf_is_empty(buf)
  buf = M.resolve_bufnr(buf)
  if not buf then
    return false
  end
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  return #lines == 1 and lines[1] == ''
end

---@param buf? number @the buffer number
---@return number[] @the window numbers in the buffer
function M.buf_get_wins(buf)
  buf = M.resolve_bufnr(buf)
  if not buf then
    return {}
  end
  local wins = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      table.insert(wins, win)
    end
  end
  return wins
end


--- Gera um keymapping
---@param mode string|table Uma string representando o modo para o qual o mapeamento deve ser criado (por exemplo, "n", "i", "v", "x", etc.). Alternativamente, pode ser passado uma tabela contendo várias strings de modo para criar o mapeamento para vários modos.
---@param remap string A sequência de teclas a ser mapeada.
---@param command string | fun() A sequência de comandos ou a função que será executada quando o mapeamento for acionado
---@param opts vim.keymap.set.Opts? Uma tabela de opções adicionais a serem passadas para a função `vim.keymap.set`. defaults `{ noremap = true, silent = true }`
function M.keymap(mode, remap, command, opts)
  local options = { noremap = true, silent = true }

  if opts then options = vim.tbl_extend('force', options, opts) end

  if type(mode) == 'table' and type(command) == 'string' and vim.tbl_contains(mode, 'i') then
    vim.keymap.set(mode, remap, '<ESC>' .. tostring(command), options)
  else
    if command == nil then return end
    vim.keymap.set(mode, remap, command, options)
  end
end

local autocmd_keys = { 'event', 'buffer', 'pattern', 'desc', 'command', 'group', 'once', 'nested' }

--- Validate the keys passed to as.augroup are valid
---@param name string
---@param command Autocommand
local function validate_autocmd(name, command)
  local incorrect = utils.fold(function(accum, _, key)
    if not vim.tbl_contains(autocmd_keys, key) then table.insert(accum, key) end
    return accum
  end, command, {})

  if #incorrect > 0 then
    vim.schedule(function()
      local msg = 'Incorrect keys: ' .. table.concat(incorrect, ', ')
      vim.notify(msg, vim.log.levels.ERROR, { title = string.format('Autocmd: %s', name) })
    end)
  end
end

---@class AutocmdArgs
---@field id number autocmd ID
---@field event string
---@field group string?
---@field buf number
---@field file string
---@field match string | number
---@field data any

---@class Autocommand
---@field desc string?
---@field event  string | string[] list of autocommand events
---@field pattern string | string[] | nil list of autocommand patterns
---@field command string | fun(args: AutocmdArgs): boolean?
---@field nested  boolean?
---@field once    boolean?
---@field buffer  number?

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string The name of the autocommand group
---@param ... Autocommand A list of autocommands to create
---@return number
function M.augroup(name, ...)
  local commands = { ... }
  assert(name ~= 'User', 'The name of an augroup CANNOT be User')
  assert(#commands > 0, string.format('You must specify at least one autocommand for %s', name))

  local id = api.nvim_create_augroup(name, { clear = true })
  for _, autocmd in ipairs(commands) do
    -- validate_autocmd(name, autocmd)
    local is_callback = type(autocmd.command) == 'function'

    api.nvim_create_autocmd(autocmd.event, {
      group = name,
      pattern = autocmd.pattern,
      desc = autocmd.desc,
      callback = is_callback and autocmd.command or nil,
      command = not is_callback and autocmd.command or nil,
      once = autocmd.once,
      nested = autocmd.nested,
      buffer = autocmd.buffer,
    })
  end
  return id
end

---@class LAutocommand
---@field description? string
---@field event  string[] list of autocommand events
---@field pattern? string[] list of autocommand patterns
---@field command string | function
---@field nested?  boolean
---@field once?    boolean
---@field buffer?  number

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string
---@param commands LAutocommand[]
---@return number
function M.laugroup(name, commands)
    local id = vim.api.nvim_create_augroup(name, { clear = true })
    for _, autocmd in ipairs(commands) do
        local is_callback = type(autocmd.command) == "function"
        vim.api.nvim_create_autocmd(autocmd.event, {
            group = id,
            pattern = autocmd.pattern,
            desc = autocmd.description,
            callback = is_callback and autocmd.command or nil,
            command = not is_callback and autocmd.command or nil,
            once = autocmd.once,
            nested = autocmd.nested,
            buffer = autocmd.buffer,
        })
    end
    return id
end


--- @class CommandArgs
--- @field args string
--- @field fargs table
--- @field bang boolean,

---Create an nvim command
---@param name string
---@param rhs string | fun(args: CommandArgs)
---@param opts table?
function M.command(name, rhs, opts)
  opts = opts or {}
  api.nvim_create_user_command(name, rhs, opts)
end

---A terser proxy for `nvim_replace_termcodes`
---@param str string
---@return string
function M.replace_termcodes(str) return api.nvim_replace_termcodes(str, true, true, true) end

---@param keys string
---@param mode string? defaults to 'n'
function M.feedkeys(keys, mode)
  vim.schedule(function()
    mode = mode or 'n'
    api.nvim_feedkeys(M.replace_termcodes(keys), mode, false)
  end)
end

---A terser proxy for `nvim_get_hl_by_name`
function M.get_hl_by_name(name)
  local hl = api.nvim_get_hl(0, {
    name = name,
    link = false,
  })
  return hl
end


return M
