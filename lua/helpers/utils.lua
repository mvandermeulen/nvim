M = {}

local fn = vim.fn
local bo = vim.bo
local api = vim.api

function M.start()
  fullPath = fullPath or false
  local buffer_name
  if fullPath == true then
    buffer_name = vim.api.nvim_buf_get_name(0)
  else
    buffer_name = string.match(vim.api.nvim_buf_get_name(0), "(%w+)$")
  end
  return buffer_name
end


function M.remove_augroup(name)
  if vim.fn.exists("#" .. name) == 1 then
    vim.cmd("au! " .. name)
  end
end

-- get length of current word
function M.get_word_length()
  local word = vim.fn.expand("<cword>")
  return #word
end


--- Returns a 2D Array by file type with names and the paths.
--- @param fileType string: suffix of the file type.
--- @return Array
function M.get_files_by_end(fileType, path)
  fileType = (".*%." .. fileType .. "$") or ""
  path = path or false

  local function match_file(name)
    return name:match(fileType)
  end

  local find = vim.fs.find(match_file, { type = "file", limit = math.huge })
  local files = {}

  if #find > 1 then
    if path then
      for _, value in ipairs(find) do
        local name = vim.fs.basename(value)
        local new_path = value:gsub(vim.fn.getcwd(), "")
        table.insert(files, { tostring(name), tostring(new_path) })
      end
    else
      for _, value in ipairs(find) do
        local name = vim.fs.basename(value)
        table.insert(files, { tostring(name), tostring(value) })
      end
    end
  end

  return files
end

--- Returns working directory.
--- @return string
function M.is_win()
  return ""
end

--- Returns the active buffers path or name.
--- Defaults to name.
--- @param fullPath boolean? Default is false
--- @return string
function M.get_buffer_name(fullPath)
  fullPath = fullPath or false
  local buffer_name
  if fullPath == true then
    buffer_name = vim.api.nvim_buf_get_name(0)
  else
    buffer_name = string.match(vim.api.nvim_buf_get_name(0), "(%w+)$")
  end
  return buffer_name
end

--- Clears the extmark on all windows.
--- @param name string Default is false
function M.clear_extmark(name)
  local ns_id = vim.api.nvim_get_namespaces()[name]
  local window_ids = vim.api.nvim_list_wins()
  local bufnr
  for _, winid in pairs(window_ids) do
    bufnr = vim.api.nvim_win_get_buf(winid)
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
  end
end

--- Returns table compiled to plain text.
--- Defaults to empty string.
function M.compile_table(tbl, indent)
  local result = ""
  local current_indent = indent or ""
  local next_indent = current_indent .. " "

  local function build_line(key, value)
    result = table.concat {
      result,
      next_indent,
      key and key .. " = " or "",
      value,
      ",\n",
    }
  end

  result = table.concat {
    result,
    current_indent,
    "{\n",
  }

  for key, value in pairs(tbl) do
    if type(key) ~= "number" then
      key = tostring(key)
    else
      key = false
    end

    if type(value) == "function" then
      value = value()
    end

    if type(value) == "table" then
      build_line(key, M.compile_table(value, next_indent))
      goto continue
    end

    if type(value) == "string" then
      build_line(key, tostring('"' .. value .. '"'))
    else
      build_line(key, tostring(value))
    end

    ::continue::
  end

  result = table.concat {
    result,
    current_indent,
    "}",
  }

  return result
end
-- Append modeline at end of file.
function M.append_modeline()
  local modeline = string.format(
    'vim: set ts=%d sw=%d tw=%d %set :',
    vim.bo.tabstop,
    vim.bo.shiftwidth,
    vim.bo.textwidth,
    vim.bo.expandtab and '' or 'no'
  )
  local cs = require('ts_context_commentstring.internal').calculate_commentstring()
    or vim.bo.commentstring
  if not cs then
    vim.notify('No commentstring found','warn')
    return
  end
  modeline = string.gsub(cs, '%%s', modeline)
  vim.api.nvim_buf_set_lines(0, -1, -1, false, { modeline })
end

-- Go to newer/older buffer through jumplist.
---@param direction 1 | -1
function M.jump_buffer(direction)
  local jumplist, curjump = unpack(vim.fn.getjumplist() or { 0, 0 })
  if #jumplist == 0 then
    return
  end
  local cur_buf = vim.api.nvim_get_current_buf()
  local jumpcmd = direction > 0 and '<C-i>' or '<C-o>'
  local searchrange = {}
  curjump = curjump + 1
  if direction > 0 then
    searchrange = vim.fn.range(curjump + 1, #jumplist)
  else
    searchrange = vim.fn.range(curjump - 1, 1, -1)
  end

  for _, i in ipairs(searchrange) do
    local nr = jumplist[i]['bufnr']
    if nr ~= cur_buf and vim.fn.bufname(nr):find('^%w+://') == nil then
      local n = tostring(math.abs(i - curjump))
      vim.notify('Executing ' .. jumpcmd .. ' ' .. n .. ' times')
      jumpcmd = vim.api.nvim_replace_termcodes(jumpcmd, true, true, true)
      vim.cmd.normal({ n .. jumpcmd, bang = true })
      break
    end
  end
end

-- Jump to next/previous whitespace error.
---@param direction 1 | -1
function M.whitespace_jump(direction)
  local opts = 'wz'
  if direction < 1 then
    opts = opts .. 'b'
  end

  -- Whitespace pattern: Trailing whitespace or mixed tabs/spaces.
  local pat = '\\s\\+$\\| \\+\\ze\\t'
  vim.fn.search(pat, opts)
end

-- Toggle list window
---@param name "quickfix" | "loclist"
M.toggle_list = function(name)
  local win_bufs = M.get_tabpage_win_bufs(0)
  for win, buf in pairs(win_bufs) do
    if vim.bo[buf].filetype == 'qf' and vim.fn.win_gettype(win) == name then
      vim.api.nvim_win_close(win, false)
      return
    end
  end

  if name == 'loclist' then
    vim.cmd([[ botright lopen ]])
  else
    vim.cmd([[ botright copen ]])
  end
end

-- Return a table with all window buffers from a tabpage.
---@private
---@param tabpage integer
---@return table
M.get_tabpage_win_bufs = function(tabpage)
  local bufs = {}
  for _, win in pairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    if win ~= nil and vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      if buf ~= nil and vim.api.nvim_buf_is_valid(buf) then
        bufs[win] = buf
      end
    end
  end
  return bufs
end

-- Toggle diagnostics locally (false) or globally (true).
---@param global boolean
M.diagnostic_toggle = function(global)
  local opts = {}
  if not global then
    opts.bufnr = vim.api.nvim_get_current_buf()
  end
  local enabled = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not enabled, opts)
  local msg = (enabled and 'Disable' or 'Enable') .. 'd diagnostics'
  if global then
    msg = msg .. ' globally'
  end
  vim.notify(msg, "info")
end

function M.filepath(max_dirs, dir_max_chars)
  return function()
    local msg = ''
    -- local ft = vim.bo.filetype
    local name = vim.fn.expand('%:~:.')
    local cache_key = 'badge_cache_filepath' -- _'..ft
    local cache_ok, cache = pcall(vim.api.nvim_buf_get_var, 0, cache_key)

    if cache_ok then
      return cache
    elseif name:len() < 1 then
      return 'N/A'
    end

    local i = 0
    local parts = {}
    local iter = string.gmatch(name, '([^/]+)')
    for dir in iter do
      table.insert(parts, dir)
    end
    while #parts > 1 do
      local dir = table.remove(parts, 1)
      if #parts <= max_dirs then
        dir = string.sub(dir, 0, dir_max_chars)
        if i > 0 then
          msg = msg .. '/'
        end
        msg = msg .. dir
        i = i + 1
      end
    end
    if i > 0 then
      msg = msg .. '/'
    end
    msg = msg .. table.concat(parts, '/')
    vim.api.nvim_buf_set_var(0, cache_key, msg)

    return msg
  end
end

function M.filemode(normal_symbol, readonly_symbol, zoom_symbol)
  return function()
    local msg = ''
    if not (vim.bo.readonly or vim.t.zoomed) then
      msg = msg .. normal_symbol
    end
    if vim.bo.buftype == '' and vim.bo.readonly then
      msg = msg .. readonly_symbol
    end
    if vim.t.zoomed then
      msg = msg .. zoom_symbol
    end
    return msg
  end
end


function M.modified(symbol)
	return function()
		if vim.bo.modified then
			return symbol
		end
		return ''
	end
end


-- Get the names of all current listed buffers
local function get_current_filenames()
  local listed_buffers = vim.tbl_filter(function(bufnr)
    return bo[bufnr].buflisted and api.nvim_buf_is_loaded(bufnr)
  end, api.nvim_list_bufs())

  return vim.tbl_map(api.nvim_buf_get_name, listed_buffers)
end

-- Get unique name for the current buffer
local function get_unique_filename(filename, shorten)
  local filenames = vim.tbl_filter(function(filename_other)
    return filename_other ~= filename
  end, get_current_filenames())

  if shorten then
    filename = fn.pathshorten(filename)
    filenames = vim.tbl_map(fn.pathshorten, filenames)
  end

  -- Reverse filenames in order to compare their names
  filename = string.reverse(filename)
  filenames = vim.tbl_map(string.reverse, filenames)

  local index

  -- For every other filename, compare it with the name of the current file char-by-char to
  -- find the minimum index `i` where the i-th character is different for the two filenames
  -- After doing it for every filename, get the maximum value of `i`
  if next(filenames) then
    index = math.max(unpack(vim.tbl_map(function(filename_other)
      for i = 1, #filename do
        -- Compare i-th character of both names until they aren't equal
        if filename:sub(i, i) ~= filename_other:sub(i, i) then
          return i
        end
      end
      return 1
    end, filenames)))
  else
    index = 1
  end

  -- Iterate backwards (since filename is reversed) until a "/" is found
  -- in order to show a valid file path
  while index <= #filename do
    if filename:sub(index, index) == '/' then
      index = index - 1
      break
    end

    index = index + 1
  end

  return string.reverse(string.sub(filename, 1, index))
end

function M.file_info(component, opts)
  local filename
  if opts.filetypes_override_name then
    local filetype = api.nvim_get_option_value('filetype', { buf = 0 })
    if opts.filetypes_override_name[filetype] then
      filename = opts.filetypes_override_name[filetype]
    elseif vim.tbl_contains(opts.filetypes_override_name, filetype) then
      filename = filetype
    end
  end
  if filename == nil then
    filename = api.nvim_buf_get_name(0)
    local _type = opts.type or 'base-only'

    if _type == 'short-path' then
      filename = fn.pathshorten(filename)
    elseif _type == 'base-only' then
      filename = fn.fnamemodify(filename, ':t')
    elseif _type == 'relative' then
      filename = fn.fnamemodify(filename, ':~:.')
    elseif _type == 'relative-short' then
      filename = fn.pathshorten(fn.fnamemodify(filename, ':~:.'))
    elseif _type == 'unique' then
      filename = get_unique_filename(filename)
    elseif _type == 'unique-short' then
      filename = get_unique_filename(filename, true)
    elseif _type ~= 'full-path' then
      filename = fn.fnamemodify(filename, ':t')
    end
  end

  local extension = fn.fnamemodify(filename, ':e')
  local readonly_str

  local icon

  -- Avoid loading nvim-web-devicons if an icon is provided already
  if not component.icon then
    local icon_str, icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })

    icon = { str = icon_str }

    if opts.colored_icon == nil or opts.colored_icon then
      icon.hl = { fg = icon_color }
    end
  end

  if filename == '' then
    filename = 'unnamed'
  end

  if bo.readonly then
    readonly_str = opts.file_readonly_icon or '🔒'
  else
    readonly_str = ''
  end

  local content = {
    str = string.format(' %s%s ', readonly_str, filename),
  }

  if bo.modified then
    icon = {
      str = opts.file_modified_icon or '',
      hl = {
        fg = opts.active and colors.hydrangea,
        bg = colors.deep_licorice,
      },
    }
  end

  return content.str, icon
end

M.hl = function(base)
  return function()
    return vim.tbl_extend('force', {
      style = vim.api.nvim_get_option_value('modified', { buf = 0 }) and 'italic' or nil,
    }, base)
  end
end


return M
