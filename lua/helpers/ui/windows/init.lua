--[[
-- Helpers: window
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-15
--]]

local fn = require('helpers.user.fn')

local M = {
  state = { prev_win = {} },
  tabpage_wins_normal = {}, -- only normal windows
  tabpage_wins_any = {}, -- all windows
  zoom = require('helpers.ui.windows.zoom'),
}

M.is_normal_win = function(winid)
  if vim.fn.win_gettype(winid) ~= '' then
    return false
  end
  local bufid = vim.api.nvim_win_get_buf(winid)
  if vim.api.nvim_get_option_value('buftype', { buf = bufid }) ~= '' then
    return false
  end
  if
    vim.tbl_contains({
      'NvimTree',
      'neo-tree',
      'Trouble',
      'aerial',
      'Avante',
      'AvanteInput',
    }, vim.bo[bufid].filetype)
  then
    return false
  end
  return true
end

-- @param height_ratio number (0.0 - 1.0)
-- @param width_ratio number (0.0 - 1.0)
-- @param opts table
function M.float_window_config(height_ratio, width_ratio, opts)
  local screen_w = vim.opt.columns:get()
  local screen_h = vim.opt.lines:get()
  local window_w = screen_w * width_ratio
  local window_h = screen_h * height_ratio
  local window_w_int = math.ceil(window_w)
  local window_h_int = math.ceil(window_h)
  local center_x = (screen_w - window_w) / 2
  local center_y = (vim.opt.lines:get() - window_h) / 2
  return {
    border = opts.border or "rounded",
    relative = opts.relative or "editor",
    row = center_y,
    col = center_x,
    width = window_w_int,
    height = window_h_int,
  }
end

---@param ignored_filetypes? string[]
function M.close_all_floating_windows(ignored_filetypes)
  ignored_filetypes = ignored_filetypes or {}

  for _, window in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(window)

    local bufnr = vim.fn.winbufnr(window)
    local buf_filetype = vim.fn.getbufvar(bufnr, '&filetype')
    if config.relative ~= '' and not vim.tbl_contains(ignored_filetypes, buf_filetype) then
      vim.api.nvim_win_close(window, false)
    end
  end
end

-- Close plugin owned windows.
M.close_plugin_owned = function()
  -- Jump to preview window if current window is plugin owned.
  if M.is_plugin_owned(0) then
    vim.cmd [[ wincmd p ]]
  end
  for _, win in ipairs(vim.fn.getwininfo()) do
    if M.is_plugin_owned(win.bufnr) then
      -- Delete plugin owned window buffers.
      vim.api.nvim_buf_delete(win.bufnr, {})
    end
  end
end

-- Detect if window is owned by plugin by checking buftype.
M.is_plugin_owned = function(bufid)
  local origin_type = vim.api.nvim_get_option_value('buftype', { buf = bufid })
  if origin_type == '' or origin_type == 'help' then
    return false
  end
  return true
end


M.get_filename = function()
  local filename = vim.fn.expand("%:t")
  local extension = vim.fn.expand("%:e")

  if not fn.is_empty(filename) then
    local file_icon, file_icon_color = require("nvim-web-devicons").get_icon_color(
      filename,
      extension,
      { default = true }
    )

    local hl_group = "FileIconColor" .. extension
    vim.api.nvim_set_hl(0, hl_group, { fg = file_icon_color })
    if fn.is_empty(file_icon) then
      file_icon = ""
      file_icon_color = ""
    end

    vim.api.nvim_set_hl(0, "Winbar", { link = "Variable" })
    return " " .. "%#" .. hl_group .. "#" .. file_icon .. "%*" .. " " .. "%#Winbar#" .. filename .. "%*"
  end
end


local get_gps = function()
  local status_gps_ok, gps = fn.require("nvim-navic")
  if not status_gps_ok then
    return ""
  end

  local status_ok, gps_location = pcall(gps.get_location, {})
  if not status_ok then
    return ""
  end

  if not gps.is_available() or gps_location == "error" then
    return ""
  end

  local separator = ">" --   
  if not fn.is_empty(gps_location) then
    return separator .. " " .. gps_location
  else
    return ""
  end
end


M.eval = function()
  local nvim_location = get_gps()
  return string.format("%s %s", M.get_filename(), nvim_location)
end


local function is_ignored_buf(bufnr)
  bufnr = bufnr or 0
  if not vim.bo[bufnr].buflisted then
    return true
  end
  if vim.api.nvim_buf_get_name(bufnr) == '' then
    return true
  end
  if vim.bo[bufnr].buftype ~= '' then
    return true
  end
  return false
end


function M.is_ignored_win(winid)
  winid = winid or 0
  if is_ignored_buf(vim.api.nvim_win_get_buf(winid)) then
    return true
  end
  if vim.fn.win_gettype(winid) ~= '' then
    return true
  end
  return false
end


function M.get_most_recent_win(tabpage)
  local win = vim.api.nvim_tabpage_get_win(tabpage)
  if
    M.is_ignored_win(win)
    and M.state.prev_win[tabpage] ~= nil
    and vim.api.nvim_win_is_valid(M.state.prev_win[tabpage])
  then
    win = M.state.prev_win[tabpage]
  end
  M.state.prev_win[tabpage] = win
  return win
end


function M.get_most_recent_buf(tabpage)
  return vim.api.nvim_win_get_buf(M.get_most_recent_win(tabpage))
end


M.update = function(current_win)
  current_win = current_win or vim.api.nvim_get_current_win()
  local tabpage = vim.api.nvim_win_get_tabpage(current_win)
  if not M.tabpage_wins_normal then
    M.tabpage_wins_normal = {}
  end
  if not M.tabpage_wins_normal[tabpage] then
    M.tabpage_wins_normal[tabpage] = {}
  end
  if not M.tabpage_wins_any[tabpage] then
    M.tabpage_wins_any[tabpage] = {}
  end
  local tabpage_recents = M.tabpage_wins_normal[tabpage]
  local tabpage_recents_any = M.tabpage_wins_any[tabpage]
  if current_win ~= tabpage_recents_any[1] then
    M.tabpage_wins_any[tabpage] = {
      current_win,
      tabpage_recents_any[1] or nil,
    }
  end
  if not M.is_normal_win(current_win) then
    return
  end
  if current_win ~= tabpage_recents[1] then
    M.tabpage_wins_normal[tabpage] = {
      current_win,
      tabpage_recents[1] or nil,
    }
  end
end


M.tabpage_get_recents = function(tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()
  return M.tabpage_wins_normal[tabpage]
end


M.tabpage_get_recents_any = function(tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()
  return M.tabpage_wins_any[tabpage]
end


M.tabpage_get_recents_smart = function(tabpage)
  for _, tp in ipairs { tabpage, M.tabpage_get_recents, M.tabpage_get_recents_any } do
    local recents
    if tp then
      if type(tp) == 'function' then
        recents = tp()
      else
        recents = M.tabpage_wins_normal[tp]
      end
    end
    if recents then
      return recents
    end
  end
end


M.get_most_recent = function(tabpage_recents, current_win)
  current_win = current_win or vim.api.nvim_get_current_win()
  tabpage_recents = tabpage_recents or M.tabpage_get_recents()
  local winid = tabpage_recents and tabpage_recents[1]
  if not winid then
    return
  end
  if current_win == winid then
    winid = tabpage_recents[2]
  end
  if not winid or not vim.api.nvim_win_is_valid(winid) then
    return
  end
  return winid
end


M.get_most_recent_any = function(current_win)
  return M.get_most_recent(M.tabpage_get_recents_any(), current_win)
end


M.get_most_recent_smart = function(current_win)
  local tabpage_recents = M.tabpage_get_recents_any(current_win) or {}
  if not vim.api.nvim_win_is_valid(tabpage_recents[1] or -1) then
    tabpage_recents = M.tabpage_get_recents()
  end
  return M.get_most_recent(tabpage_recents, current_win)
end


M.focus_most_recent = function(winid)
  winid = winid or M.get_most_recent()
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_set_current_win(winid)
    return
  end
  vim.cmd [[wincmd p]]
end


M.focus_most_recent_any = function()
  return M.focus_most_recent(M.get_most_recent())
end


M.focus_most_recent_smart = function()
  return M.focus_most_recent(M.get_most_recent_smart())
end


M.flip_recents = function(tabpage_recents)
  tabpage_recents = tabpage_recents or M.tabpage_get_recents()
  local cur_winid = vim.api.nvim_get_current_win()
  local last_winid = tabpage_recents and tabpage_recents[1]
  if not last_winid or last_winid == cur_winid then
    return
  end
  vim.api.nvim_set_current_win(tabpage_recents[2])
  M.update()
  vim.cmd [[wincmd p]]
end


M.flip_recents_any = function()
  return M.flip_recents(M.tabpage_get_recents_any())
end


M.flip_recents_smart = function()
  return M.flip_recents(M.tabpage_get_recents_smart())
end


function M.open_new_tab(opts)
  vim.cmd.tabnew()
  if opts then
    if opts == 'empty' or opts == '' then
      return
    elseif opts == 'tiled' then
      vim.cmd.vnew()
      vim.cmd.new()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>h', true, false, true), 'n', false)
      vim.cmd.new()
    elseif opts == 'horizontal' then
      vim.cmd.new()
    elseif opts == 'vertical' then
      vim.cmd.vnew()
    elseif opts == 'triple' then
      vim.cmd.vnew()
      vim.cmd.vnew()
    elseif opts == 'quad' then
      vim.cmd.vnew()
      vim.cmd.vnew()
      vim.cmd.vnew()
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>=', true, false, true), 'n', false)
  end
end



return M
