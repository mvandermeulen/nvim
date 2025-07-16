--[[
-- Helpers: Functions
--
-- Author: Mark van der Meulen
-- Updated: 2025-02-10
--]]


local _name = 'user.tools'
local _log = require('plenary.log').new({ plugin = _name, level = 'debug', use_console = true })

local function mlog(msg, level)
  local level = level or 'debug'
  if level == 'error' then
    _log.error(msg)
    vim.notify(msg, vim.log.levels.ERROR, { title = _name })
    print(msg)
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

local uv = vim.uv or vim.loop
local utils = require("helpers.utils.utils")
local CONFIRM_THRESHOLD = 5

-- Default configuration
M.config = {
  socket_path = utils.get_home() .. '/.local/state/snuggle.socket',-- default socket path
}


M.root_patterns = { ".git", "/lua", '.is_root_directory' }
local sysname = vim.loop.os_uname().sysname


-- get length of current word
function M.get_word_length()
    local word = vim.fn.expand "<cword>"
    return #word
end


-- Helper function to get total line count of a file
local function get_file_line_count(file_path)
  local file = io.open(file_path, 'r')
  if not file then
    return 0
  end
  local line_count = 0
  for _ in file:lines() do
    line_count = line_count + 1
  end
  file:close()
  return line_count
end


function M.get_current_file_line_count()
  local file_path = vim.fn.expand('%:p')
  if file_path == '' then
    return 0
  end
  return get_file_line_count(file_path)
end


local function blank_line_below()
  vim.fn.append(vim.fn.line("."), "")
end


local function blank_line_above()
  vim.fn.append(vim.fn.line(".") - 1, "")
end


local function get_current_buf_name()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local base_name = basename(buf_name)
  return base_name
end


local function press_enter()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", false, true, true), "n", false)
end


local function get_line_number()
  return vim.api.nvim_win_get_cursor(0)[1]
end


function M.replace_indented_line()
  local empty_string = string.match(vim.api.nvim_get_current_line(), '^%s*$')
  if empty_string then
    vim.api.nvim_del_current_line()
    blank_line_above()
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
end


function M.isempty(s)
    return s == nil or s == ""
end


function M.get_buf_option(opt)
    local status_ok, buf_option = pcall(vim.api.nvim_buf_get_option, 0, opt)
    if not status_ok then
        return nil
    else
        return buf_option
    end
end


function M.smart_quit()
    local bufnr = vim.api.nvim_get_current_buf()
    local modified = vim.api.nvim_buf_get_option(bufnr, "modified")
    if modified then
        vim.ui.input({
            prompt = "You have unsaved changes. Quit anyway? (y/n) ",
        }, function(input)
            if input == "y" then
                vim.cmd "q!"
            end
        end)
    else
        vim.cmd "q!"
    end
end


function M.open_file_default_program()
    local filename = vim.fn.expand("%:p") -- Get the full path of the current file
    local ext = vim.fn.fnamemodify(filename, ":e") -- Get the file extension

    -- List of allowed file extensions for images and PDFs
    local allowed_exts = { "jpg", "jpeg", "png", "gif", "bmp", "pdf", "tiff", "webp" }

    -- Check if the extension is in the list of allowed extensions
    if vim.tbl_contains(allowed_exts, ext) then
        -- Use xdg-open for Linux, open for macOS, and start for Windows
        local open_cmd = vim.loop.os_uname().sysname == "Windows_NT" and "start"
            or (vim.loop.os_uname().sysname == "Darwin" and "open" or "xdg-open")
        vim.cmd("!" .. open_cmd .. " " .. vim.fn.shellescape(filename))
    else
        vim.notify("Not an image or PDF file!", vim.log.levels.WARN)
    end
end


function M.run_python_script()
    -- Only save the file if it's not a terminal buffer
    if vim.bo.buftype ~= "terminal" then
        vim.cmd("w") -- Save the current file
    end

    local filetype = vim.bo.filetype -- Get the filetype of the current file

    -- Check if the filetype is Python
    if filetype ~= "python" then
        vim.notify("Not a Python file!", vim.log.levels.WARN)
        return
    end

    local filename = vim.fn.shellescape(vim.fn.expand("%")) -- Get the full path of the current file

    -- Check if a terminal split is already open
    local terminal_open = false
    local terminal_win_id = nil

    -- Iterate through all open windows and check if any of them are terminals
    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
        local buf_id = vim.api.nvim_win_get_buf(win_id)
        local buf_name = vim.api.nvim_buf_get_name(buf_id)
        if buf_name:match("term://") then
            terminal_open = true
            terminal_win_id = win_id
            break
        end
    end

    -- If a terminal is open, close it (only if terminal_win_id is not nil)
    if terminal_open and terminal_win_id ~= nil then
        vim.api.nvim_win_close(terminal_win_id, true)
    end

    -- Open a new terminal split and run the Python script
    vim.cmd("split | terminal python3 " .. filename)
end


function M.run_c_cpp_script()
    -- Only save the file if it's not a terminal buffer
    if vim.bo.buftype ~= "terminal" then
        cmd("w") -- Save the current file
    end

    local ext = vim.fn.expand("%:e") -- Get the file extension

    -- Check if the file is C or C++
    if ext ~= "c" and ext ~= "cpp" then
        vim.notify("Not a C or C++ file!", vim.log.levels.WARN)
        return
    end

    local filename = vim.fn.shellescape(vim.fn.expand("%")) -- Get the full path of the current file

    -- Check if a terminal split is already open
    local terminal_open = false
    local terminal_win_id = nil

    -- Iterate through all open windows and check if any of them are terminals
    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
        local buf_id = vim.api.nvim_win_get_buf(win_id)
        local buf_name = vim.api.nvim_buf_get_name(buf_id)
        if buf_name:match("term://") then
            terminal_open = true
            terminal_win_id = win_id
            break
        end
    end

    -- If a terminal is open, close it (only if terminal_win_id is not nil)
    if terminal_open and terminal_win_id ~= nil then
        vim.api.nvim_win_close(terminal_win_id, true)
    end

    -- Compile and run the C/C++ file in a new terminal split
    local term_cmd = ""
    if ext == "c" then
        term_cmd = "gcc " .. filename .. " -o output && ./output"
    elseif ext == "cpp" then
        term_cmd = "g++ " .. filename .. " -o output && ./output"
    end

    -- Notify the user
    vim.notify("Compiling and running the C/C++ file...", vim.log.levels.INFO)
    vim.cmd("split | terminal " .. term_cmd)

    -- Remove the compiled binary after running it
    vim.cmd("autocmd BufWipeout * silent! !rm -f output")
end


function M.copy_whole_file_to_system_clipboard()
    -- Copy the whole buffer to the system clipboard
    vim.fn.setreg("+", vim.fn.getline("1", "$"))
    -- Notify the user
    vim.notify("Copied the whole buffer to the system clipboard!", vim.log.levels.INFO)
end


function M.read_file(path)
    local api_key
    local file = io.open(path, "r")
    if file then
        api_key = file:read()
        file:close()
    end
    return api_key
end


function M.splitBy(str, byStr)
    local result = {}
    for part in string.gmatch(str, "[^" .. byStr .."]+") do
        table.insert(result, part)
    end
    return result
end


--- A condition function if the current file is in a git repo
---@param bufnr table|integer a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
---@return boolean # whether or not the current file is in a git repo
function M.is_git_repo(bufnr)
  if type(bufnr) == "table" then
    bufnr = bufnr.bufnr
  end
  return vim.b[bufnr or 0].gitsigns_head or vim.b[bufnr or 0].gitsigns_status_dict
end


-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
function M.get_root()
  ---@type string?
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= "" and vim.loop.fs_realpath(path) or nil
  ---@type string[]
  local roots = {}
  if path then
    for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
      local workspace = client.config.workspace_folders
      local paths = workspace
          and vim.tbl_map(function(ws)
            return vim.uri_to_fname(ws.uri)
          end, workspace)
        or client.config.root_dir and { client.config.root_dir }
        or {}
      for _, p in ipairs(paths) do
        local r = vim.loop.fs_realpath(p)
        if path:find(r, 1, true) then
          roots[#roots + 1] = r
        end
      end
    end
  end
  table.sort(roots, function(a, b)
    return #a > #b
  end)
  ---@type string?
  local root = roots[1]
  if not root then
    path = path and vim.fs.dirname(path) or vim.loop.cwd()
    ---@type string?
    root = vim.fs.find(M.root_patterns, { path = path, upward = true })[1]
    root = root and vim.fs.dirname(root) or vim.loop.cwd()
  end
  ---@cast root string
  return root
end


function M.command(name, fn)
  vim.cmd(string.format("command! %s %s", name, fn))
end


function M.lua_command(name, fn)
  M.command(name, "lua " .. fn)
end


function M.is_directory()
  return vim.fn.isdirectory(vim.api.nvim_buf_get_name(0)) == 1
end


local get_map_options = function(custom_options)
  local options = { noremap = true, silent = true }
  if custom_options then
    options = vim.tbl_extend("force", options, custom_options)
  end
  return options
end


M.buf_map = function(mode, target, source, opts, bufnr)
  vim.api.nvim_buf_set_keymap(bufnr or 0, mode, target, source, get_map_options(opts))
end


M.nmap_buf = function(...)
  M.buf_map("n", ...)
end


---@param plugin string
function M.has(plugin)
  return require("lazy.core.config").plugins[plugin] ~= nil
end


---get fg from vim
---@param name string
---@return function
function M.get_fg(name)
  return function()
    ---@type {foreground?:number}?
    local hl = vim.api.nvim_get_hl_by_name(name, true)
    return hl and hl.foreground and { fg = string.format("#%06x", hl.foreground) }
  end
end


---@param cmd string command to execute
---@param warn? string|boolean if vim.fn.executable <= 0 then warn with warn
---@return boolean
function M.executable(cmd, warn)
  if vim.fn.executable(cmd) > 0 then
    return true
  end
  if warn then
    local message = type(warn) == "string" and warn or ("Command `%s` was not executable"):format(cmd)
    vim.notify(message, vim.log.levels.WARN, { title = "Executable not found" })
  end
  return false
end


function M.resolve_win(win)
  win = win or 0
  if win == 0 then
    return vim.api.nvim_get_current_win()
  end
  return win
end


function M.is_ignored_filetype(filetype)
  local ignore = config.ignore
  return ignore.filetypes and vim.tbl_contains(ignore.filetypes, filetype)
end


function M.is_ignored_buf(bufnr)
  bufnr = bufnr or 0
  local ignore = config.ignore
  if ignore.unlisted_buffers and not vim.api.nvim_get_option_value('buflisted', { buf = bufnr }) then
    return true
  end
  if ignore.buftypes then
    local buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr })
    if ignore.buftypes == 'special' and buftype ~= '' then
      return true
    elseif type(ignore.buftypes) == 'table' then
      if vim.tbl_contains(ignore.buftypes, buftype) then
        return true
      end
    elseif type(ignore.buftypes) == 'function' then
      if ignore.buftypes(bufnr, buftype) then
        return true
      end
    end
  end
  if ignore.filetypes then
    local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
    if M.is_ignored_filetype(filetype) then
      return true
    end
  end
  return false
end


function M.is_floating_win(winid)
  return vim.api.nvim_win_get_config(winid or 0).relative ~= ''
end


function M.is_ignored_win(winid)
  winid = winid or 0
  local bufnr = vim.api.nvim_win_get_buf(winid)
  if M.is_ignored_buf(bufnr) then
    return true
  end
  local ignore = config.ignore
  if ignore.floating_wins and M.is_floating_win(winid) then
    return true
  end
  if ignore.wintypes then
    local wintype = vim.fn.win_gettype(winid)
    if ignore.wintypes == 'special' and wintype ~= '' then
      return true
    elseif type(ignore.wintypes) == 'table' then
      if vim.tbl_contains(ignore.wintypes, wintype) then
        return true
      end
    elseif type(ignore.wintypes) == 'function' then
      if ignore.wintypes(winid, wintype) then
        return true
      end
    end
  end
  return false
end


function M.tabpage_list_fixed_wins(tab)
  return vim.tbl_filter(function(w)
    return not M.is_floating_win(w)
  end, vim.api.nvim_tabpage_list_wins(tab))
end


--- Go to or create the *`n`*th tab
---@param n integer
function M.tabnm(n)
  local tabs = vim.api.nvim_list_tabpages()
  if n > #tabs then
    vim.cmd("$tabnew")
  else
    local tabpage = tabs[n]
    vim.api.nvim_set_current_tabpage(tabpage)
  end
  -- return function()
  --   local tabs = vim.api.nvim_list_tabpages()
  --   if n > #tabs then
  --     vim.cmd("$tabnew")
  --   else
  --     local tabpage = tabs[n]
  --     vim.api.nvim_set_current_tabpage(tabpage)
  --   end
  -- end
end


--- Put the `char` variable at the beginning of the line. If present, remove it
---@param chars string
function M.put_at_end(chars)
  local pos = vim.api.nvim_win_get_cursor(0)
  local row = pos[1] - 1
  local current_line = vim.api.nvim_get_current_line()
  local col = #current_line
  local entry_length = string.len(chars)
  ---@diagnostic disable-next-line: param-type-mismatch
  local cline = vim.fn.getline(".")
  ---@diagnostic disable-next-line: param-type-mismatch
  local endchar = vim.fn.getline("."):sub(cline:len() - (entry_length - 1))
  if endchar == chars then
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.api.nvim_set_current_line(cline:sub(1, cline:len() - entry_length))
  else
    vim.api.nvim_buf_set_text(0, row, col, row, col, { chars })
  end
end


--- Put the `char` variable at the end of the line. If present, remove it
---@param chars string
function M.put_at_beginning(chars)
  ---@diagnostic disable-next-line: param-type-mismatch
  local cline = vim.fn.getline(".")
  ---@diagnostic disable-next-line: param-type-mismatch
  -- vim.api.nvim_set_current_line(cline:sub(1, cline:len()-1))
  local pos = vim.api.nvim_win_get_cursor(0)
  local row = pos[1] - 1
  local col = 0
  local entry_length = string.len(chars)
  ---@diagnostic disable-next-line: param-type-mismatch
  local start_chars = string.sub(vim.fn.getline("."), 0, entry_length)
  if start_chars == chars then
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.api.nvim_set_current_line(cline:sub((entry_length + 1), cline:len()))
  else
    vim.api.nvim_buf_set_text(0, row, col, row, col, { chars })
  end
end


--- Dumb but useful function to increase markdown headers
function M.increase_header()
  ---@diagnostic disable-next-line: param-type-mismatch
  local cline = vim.fn.getline(".")
  ---@diagnostic disable-next-line: param-type-mismatch
  local header = vim.fn.getline("."):sub(1, 8)
  if header:find("# ") then
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.api.nvim_set_current_line("#" .. cline)
  else
    vim.notify("No headers, creating one")
    vim.api.nvim_set_current_line("# " .. cline)
  end
end


--- Dumb but useful function to decrease markdown headers
function M.decrease_header()
  ---@diagnostic disable-next-line: param-type-mismatch
  local cline = vim.fn.getline(".")
  ---@diagnostic disable-next-line: param-type-mismatch
  local header = vim.fn.getline("."):sub(1, 8)
  if string.match(header, "# ") or string.match(header, " ") then
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.api.nvim_set_current_line(cline:sub(2, cline:len()))
  else
    vim.notify("No headers, not removing anything")
  end
end


--- Navigate to other windows in the tab by window number, not ID
---@param num integer
function M.navigate(num)
  local nrs = {}
  local ids = {}
  ---@type table<integer>
  local windows = vim.tbl_filter(function(id)
    return vim.api.nvim_win_get_config(id).relative == ""
  end, vim.api.nvim_tabpage_list_wins(0))

  for _, win in ipairs(windows) do
    local number = vim.api.nvim_win_get_number(win)

    table.insert(nrs, number)
    ids[number] = win
  end
  vim.api.nvim_set_current_win(ids[num])
end


--- Moves [count] up and down the selected lines
function M.visual_move(count, min_count, pos_1, pos_2, fix_num, cmd_start)
  vim.cmd([[execute "normal! \<esc>"]])

  local get_to_move = function()
    if count <= min_count then
      return min_count
    else
      return count - (vim.fn.line(pos_1) - vim.fn.line(pos_2)) + fix_num
    end
  end

  local to_move = get_to_move()
  vim.cmd(cmd_start .. to_move)

  local cur_row, cur_col = unpack(vim.api.nvim_win_get_cursor(0))

  vim.cmd("normal! `]")
  local end_cursor_pos = vim.api.nvim_win_get_cursor(0)
  local end_row = end_cursor_pos[1]
  local end_line = vim.api.nvim_get_current_line()
  local end_col = #end_line
  vim.api.nvim_buf_set_mark(0, "z", end_row, end_col, {})

  vim.cmd("normal! `[")
  local start_cursor_pos = vim.api.nvim_win_get_cursor(0)
  local start_row = start_cursor_pos[1]
  vim.api.nvim_win_set_cursor(0, { start_row, 0 })

  vim.cmd("normal! =`z")
  vim.api.nvim_win_set_cursor(0, { cur_row, cur_col })
  vim.cmd("normal! gv")
end


--- Open inputted harpoon tag number in vertical split
function M.harpoon_split()
  ---@param harp_mark integer
  vim.ui.input({ prompt = "Which mark?" }, function(harp_mark)
    vim.cmd(string.format("vsplit | lua require('harpoon.ui').nav_file(%d)", harp_mark))
  end)
end


--- Swap current char with the previous one
function M.swap_char_b()
  local pos = vim.api.nvim_win_get_cursor(0)
  local prev_colnr = pos[2]
  local colnr = pos[2] + 1
  if not prev_colnr then
    print("Go forward a char to swap")
    return
  end
  ---@diagnostic disable-next-line: param-type-mismatch
  local curchar = vim.fn.getline("."):sub(colnr, colnr)
  ---@diagnostic disable-next-line: param-type-mismatch
  local prevchar = vim.fn.getline("."):sub(prev_colnr, prev_colnr)
  local concatted = curchar .. prevchar
  vim.api.nvim_buf_set_text(0, pos[1] - 1, (prev_colnr - 1), pos[1] - 1, colnr, { concatted })
end


--- Swap current char with the next one
function M.swap_char_f()
  local pos = vim.api.nvim_win_get_cursor(0)
  local colnr = pos[2] + 1
  local next_colnr = pos[2] + 2
  ---@diagnostic disable-next-line: param-type-mismatch
  local curchar = vim.fn.getline("."):sub(colnr, colnr)
  ---@diagnostic disable-next-line: param-type-mismatch
  local nextchar = vim.fn.getline("."):sub(next_colnr, next_colnr)
  local concatted = nextchar .. curchar
  vim.api.nvim_buf_set_text(0, pos[1] - 1, (colnr - 1), pos[1] - 1, next_colnr, { concatted })
end


--- Code runner
---@param height integer
function M.runner(height)
  local fts = {
    rust = "cargo run",
    python = "python3 %",
    javascript = "npm start",
    c = "make",
    cpp = "make",
    java = "java %",
  }

  local cmd = fts[vim.bo.filetype]
  -- stylua: ignore
  vim.cmd(
    cmd and ("w | " .. (height or "") .. "sp | term " .. cmd)
    or "echo 'No runner for this filetype'")
end


--- Markdown codeblock machine using `vim.ui.input`
function M.md_block()
  vim.ui.input({ prompt = "Block language?" }, function(lang)
    local enter = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
    local escape = vim.api.nvim_replace_termcodes("<C-o>k", true, false, true)
    vim.api.nvim_feedkeys([[o```]] .. lang .. enter .. enter .. [[```]] .. escape, "n", true)
  end)
end


--- Cursor lock for navigating code - Credit to @b0o
function M.cursor_lock(lock)
  return function()
    local win = vim.api.nvim_get_current_win()
    local augid = vim.api.nvim_create_augroup("user_cursor_lock_" .. win, { clear = true })
    if not lock or vim.w.cursor_lock == lock then
      vim.w.cursor_lock = nil
      vim.notify("Cursor lock disabled")
      return
    end
    local cb = function()
      if vim.w.cursor_lock then
        vim.cmd("silent normal z" .. vim.w.cursor_lock)
      end
    end
    vim.w.cursor_lock = lock
    vim.api.nvim_create_autocmd("CursorMoved", {
      desc = "Cursor lock for window " .. win,
      buffer = 0,
      group = augid,
      callback = cb,
    })
    cb()
    vim.notify("Cursor lock enabled")
  end
end


-- @author kikito
-- @see https://codereview.stackexchange.com/questions/268130/get-list-of-buffers-from-current-neovim-instance
-- currently not used
function M.get_listed_buffers()
  local buffers = {}
  local len = 0
  for buffer = 1, vim.fn.bufnr("$") do
    if vim.fn.buflisted(buffer) == 1 then
      len = len + 1
      buffers[len] = buffer
    end
  end

  return buffers
end



-- yank.lua
function M.to_markdown(content)
  local filename = vim.api.nvim_buf_get_name(0)
  local ext = filename:match("^.+%.([a-zA-Z0-9]+)$") or ""
  local markdown = ("```%s\n%s\n```"):format(ext, content)
  vim.fn.setreg("+", markdown)
end


function M.selection_to_markdown()
  vim.cmd('normal! ""y')
  local content = vim.fn.getreg('"')
  if not content or content == "" then
    print("No selection found.")
    return
  end
  M.to_markdown(content)
  vim.notify(
    "Copied visual selection to clipboard as markdown code block",
    vim.log.levels.INFO,
    { title = "YankSelectionToMarkdown" }
  )
end


function M.file_to_markdown()
  vim.cmd("%y")
  local content = vim.fn.getreg('"')
  M.to_markdown(content)
  vim.notify(
    "Copied buffer content as markdown code block to clipboard",
    vim.log.levels.INFO,
    { title = "YankFileToMarkdown" }
  )
end


function M.cursor_diagnostics()
  local pos = vim.api.nvim_win_get_cursor(0)
  local diagnostics = vim.diagnostic.get(0, { lnum = pos[1] - 1 })
  if #diagnostics > 0 then
    local message = diagnostics[1].message
    vim.fn.setreg("+", message) -- System clipboard
    vim.notify("Diagnostics copied to clipboard", vim.log.levels.INFO, { title = "Diagnostics" })
  else
    vim.notify("No diagnostic under cursor.", vim.log.levels.WARN, { title = "Diagnostics" })
  end
end


function M.all_diagnostics()
  local diagnostics = vim.diagnostic.get(0)
  if #diagnostics == 0 then
    vim.notify("No diagnostics in buffer.", vim.log.levels.WARN, { title = "Diagnostics" })
    return
  end

  local messages = {}
  for _, diag in ipairs(diagnostics) do
    table.insert(messages, string.format("[%s:%d] %s", diag.source or "LSP", diag.lnum + 1, diag.message))
  end

  local result = table.concat(messages, "\n")
  vim.fn.setreg("+", result) -- System clipboard

  vim.notify("All diagnostics copied to clipboard", vim.log.levels.INFO, { title = "Diagnostics" })
end



-- web.lua
function M.url_encode(str)
  return (str:gsub("[^%w%-_%.~]", function(c)
    return string.format("%%%02X", string.byte(c))
  end))
end


function M.build_url(endpoint, params)
  if not params or vim.tbl_isempty(params) then
    return endpoint
  end
  local query = {}
  for k, v in pairs(params) do
    if v ~= nil then
      table.insert(query, M.url_encode(k) .. "=" .. M.url_encode(tostring(v)))
    end
  end
  return endpoint .. "?" .. table.concat(query, "&")
end


function M.extract_uris(lines)
  opts = opts or {}
  local uris, seen = {}, {}
  for _, line in ipairs(lines) do
    for url in line:gmatch("%[.-%]%((https?://[^%s%)]+)%)") do
      if not seen[url] then
        table.insert(uris, url)
        seen[url] = true
      end
    end
    for url in line:gmatch("https?://[%w-_%.%?%.:/%+=&%%#@%!]+") do
      if not seen[url] then
        table.insert(uris, url)
        seen[url] = true
      end
    end
  end
  return uris
end


function M.extract_uris_from_selection()
  vim.cmd('normal! ""y')
  local content = vim.fn.getreg('"')

  if not content or content == "" then
    vim.notify("No visual selection found", vim.log.levels.WARN)
    return
  end
  local lines = {}
  for line in content:gmatch("[^\n]+") do
    table.insert(lines, line)
  end
  return M.extract_uris(lines)
end


function M.open_uris(uris)
  if #uris == 0 then
    vim.notify("No URLs found in buffer", vim.log.levels.INFO)
    return
  end
  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("Snacks not found.", vim.log.levels.ERROR)
    return
  end

  if #uris > CONFIRM_THRESHOLD then
    snacks.input({
      prompt = string.format("Open all %d links? (y/N)", #uris),
      icon = "󰖟 ",
      default = "n",
      win = {
        style = "minimal",
        border = "single",
        height = 1,
        width = 40,
        row = math.floor((vim.o.lines - 1) / 2),
        col = math.floor((vim.o.columns - 40) / 2),
      },
    }, function(input)
      if input and input:lower() == "y" then
        for _, uri in ipairs(uris) do
          platform.system_open(uri)
        end
      else
        vim.notify("Cancelled opening links", vim.log.levels.WARN)
      end
    end)
  else
    for _, uri in ipairs(uris) do
      platform.system_open(uri)
    end
  end
end


function M.open_uris_in_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local uris = M.extract_uris(lines)
  M.open_uris(uris)
end


function M.open_uris_in_selection()
  M.open_uris(M.extract_uris_from_selection())
end


function M.open_branch_workitem()
  local branch = git.get_branch_name()
  if not branch then
    vim.notify("No branch name found", vim.log.levels.WARN)
    return
  end
  local workitem_id = git.extract_workitem_id_from_branch()
  if not workitem_id then
    vim.notify("No workitem ID found in branch name", vim.log.levels.WARN)
    return
  end
  local azure_org = git.extract_azure_org(git.get_remote_url())
  if azure_org then
    platform.system_open(azure_org .. "/_workitems/edit/" .. workitem_id)
  end
end


function M.open_path_with_app(apps, path)
  for _, app in ipairs(apps) do
    if vim.fn.executable(app) == 1 then
      local command = app .. " " .. vim.fn.shellescape(path)
      vim.fn.jobstart(command, {
        detach = true,
        on_exit = function(_, code, _)
          if code ~= 0 then
            vim.notify("Failed to open " .. path, vim.log.levels.ERROR)
          end
        end,
      })
      return
    end
  end
end


function M.system_open(path)
  if not path then
    return
  end

  if M.is_wsl() then
    if vim.fn.executable("wslview") == 1 then
      vim.fn.jobstart({ "wslview", path }, { detach = true })
      return
    else
      vim.fn.jobstart({ "powershell.exe", "/c", "start", path }, { detach = true })
      return
    end
  elseif M.is_macos() then
    M.open_path_with_app({ "open" }, path)
  elseif M.is_windows() then
    vim.fn.jobstart({ "cmd.exe", "/c", "start", "", path }, { detach = true })
  elseif M.is_linux() then
    M.open_path_with_app({ "xdg-open", "gvfs-open", "gnome-open" }, path)
  else
    vim.notify("Unsupported OS for system_open", vim.log.levels.ERROR)
  end
end


function M.comment_yank_paste()
  local win = vim.api.nvim_get_current_win()
  local cur = vim.api.nvim_win_get_cursor(win)
  local vstart = vim.fn.getpos("v")[2]
  local current_line = vim.fn.line(".")
  if vstart == current_line then
    vim.cmd.yank()
    require("Comment.api").toggle.linewise.current()
    vim.cmd.put()
    set_cur(win, { cur[1] + 1, cur[2] })
  else
    if vstart < current_line then
      cmd(":" .. vstart .. "," .. current_line .. "y")
      vim.cmd.put()
      set_cur(win, { vim.fn.line("."), cur[2] })
    else
      cmd(":" .. current_line .. "," .. vstart .. "y")
      set_cur(win, { vstart, cur[2] })
      vim.cmd.put()
      set_cur(win, { vim.fn.line("."), cur[2] })
    end
    require("Comment.api").toggle.linewise(vim.fn.visualmode())
  end
end


function M.win_only(cb)
  cb = cb or nil
  if #api.nvim_list_wins() > 1 then
    vim.cmd.only()
  end
  if cb then
    cb()
  end
end


function M.toggle_cmdheight()
  if vim.o.cmdheight == 1 then
    vim.o.cmdheight = 0
    ---@diagnostic disable-next-line: inject-field
    vim.g.CMDHEIGHTZERO = 1
  else
    vim.o.cmdheight = 1
    ---@diagnostic disable-next-line: inject-field
    vim.g.CMDHEIGHTZERO = 0
  end
end


function M.screen_scale(config)
  local defaults = {
    width = 0.5,
    height = 0.5,
  }
  config = config or defaults
  config.width = config.width or defaults.width
  config.height = config.height or defaults.height
  local width = fn.round(o.columns * config.width)
  local height = fn.round(o.lines * config.height)
  return {
    width = width,
    height = height,
  }
end


function M.toggleterm_opts(added_opts)
  local ratio = 0.85
  local scale = M.screen_scale({ width = ratio, height = ratio })
  local toggleterm_opts = {
    auto_scroll = true,
    direction = "float",
    float_opts = {
      border = "curved",
      width = scale.width,
      height = scale.height,
      winblend = 2,
    },
    winbar = {
      enabled = false,
    },
    shade_terminals = true,
    hide_numbers = false,
    on_open = function(term)
      vim.api.nvim_buf_set_keymap(
        term.bufnr,
        "n",
        "q",
        [[<cmd>close<cr>]],
        { noremap = true, silent = true }
      )
    end,
    on_close = function() end,
  }
  if not added_opts then
    return toggleterm_opts
  end
  return vim.tbl_deep_extend("force", toggleterm_opts, added_opts)
end


function M.toggle_term_cmd(config)
  if not config or not config.count then
    return
  end
  if config.cmd[1] ~= nil then
    vim.ui.select(config.cmd, {
      prompt = "Select command",
    }, function(selected)
      if not selected then
        return
      end
      config.cmd = selected
      M.toggle_term_cmd(config)
    end)
  else
    local term_config = M.toggleterm_opts(config)
    local Terminal = require("toggleterm.terminal").Terminal
    local term = Terminal:new(term_config)
    term:toggle()
  end
end


function M.run_system_command(config)
  if not config or not config.cmd then
    return
  end
  config.notify_config = config.notify_config or { title = "System Command" }
  vim.defer_fn(function()
    local handle = io.popen(config.cmd)
    if handle then
      local result = handle:read("*a")
      handle:close()
      if config.notify == true then
        require("notify").notify(result, vim.log.levels.INFO, config.notify_config)
      end
    end
  end, 0)
end


local function open_help_tab(help_cmd, topic)
  vim.cmd.tabe()
  local winnr = vim.api.nvim_get_current_win()
  cmd("silent! " .. help_cmd .. " " .. topic)
  vim.api.nvim_win_close(winnr, false)
end


function M.current_word()
  local current_word = fn.expand("<cword>")
  return current_word
end


function M.help_word()
  local current_word = M.current_word()
  open_help_tab("help", current_word)
end


function M.terminal_send_cmd(cmd_text)
  local function get_first_terminal()
    local terminal_chans = {}
    for _, chan in pairs(api.nvim_list_chans()) do
      if chan["mode"] == "terminal" and chan["pty"] ~= "" then
        table.insert(terminal_chans, chan)
      end
    end
    table.sort(terminal_chans, function(left, right)
      return left["buffer"] < right["buffer"]
    end)
    if #terminal_chans == 0 then
      return nil
    end
    return terminal_chans[1]["id"]
  end

  local send_to_terminal = function(terminal_chan, term_cmd_text)
    vim.api.nvim_chan_send(terminal_chan, term_cmd_text .. "\n")
  end

  local terminal = get_first_terminal()
  if not terminal then
    return nil
  end

  if not cmd_text then
    vim.ui.input({ prompt = "Send to terminal: " }, function(input_cmd_text)
      if not input_cmd_text then
        return nil
      end
      send_to_terminal(terminal, input_cmd_text)
    end)
  else
    send_to_terminal(terminal, cmd_text)
  end
  return true
end


function M.tabnavigate(cfg)
  cfg = cfg or {
    navto = "next",
  }
  if cfg.navto ~= "next" and cfg.navto ~= "prev" then
    return
  end
  local nav = cfg.navto == "next" and vim.cmd.tabnext or cmd.tabprev
  local term_escape = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true)
  if vim.bo.filetype == "terminal" then
    vim.api.nvim_feedkeys(term_escape, "t", true)
  end
  nav()
end


function M.diagnostics_jump(config)
  local sev = vim.diagnostic.severity
  config = config or {}
  config.count = config.count or 1
  if config.count == 0 then
    return
  end
  config.float = config.float or false
  config.severity = config.severity or sev.ERROR
  config.scan_direction = config.scan_direction or -1
  local get = config.count > 0 and vim.diagnostic.get_next or vim.diagnostic.get_prev
  local diag = get({
    count = config.count,
    severity = config.severity,
  })
  if diag then
    vim.diagnostic.jump({
      count = config.count,
      severity = config.severity,
      float = config.float,
    })
  else
    if
      (config.severity == sev.ERROR and config.scan_direction == -1)
      or (config.severity == sev.HINT and config.scan_direction == 1)
    then
      return
    end
    config.severity = config.severity + config.scan_direction
    M.diagnostics_jump(config)
  end
end


function M.term_open(c)
  vim.g.catgoose_terminal_enable_startinsert = 1
  if type(c) == "string" then
    cmd(c)
  end
  if type(c) == "table" then
    for _, v in ipairs(c) do
      cmd(v)
    end
  end
end


function M.testing_function()
  vim.cmd.make()
end


function M.make_open_qf()
  vim.print(
    string.format(
      "Compiling with '%s'",
      vim.api.nvim_get_option_value("makeprg", { scope = "local" })
    )
  )
  cmd("silent! make")
  if #vim.fn.getqflist() > 0 then
    vim.cmd.copen()
  else
    vim.print("Compiling complete with no errors!")
  end
end


function M.open_log(window_name)
  local window_name = window_name or "NvimLog"
  local session_name = window_name or "NvimLog"
  local shell = require("helpers.user.shell")
  local path = vim.lsp.get_log_path()
  if not path then
    mlog("No LSP log file found", "error")
    return
  end
  parent_path = vim.fn.fnamemodify(path, ":p:h")
  -- if shell.new_window(session_name, true, parent_path, window_name) then
  --   mlog("Created new window " .. window_name .. " in session " .. session_name, "info")
  -- else
  --   mlog("Failed to create new window " .. window_name .. " in session " .. session_name, "error")
  --   return
  -- end
  -- if shell.run_in_pane(session_name .. ":" .. window_name, false, "tail -100f " .. path) then
  --   mlog("Running tail -100f " .. path .. " in window " .. window_name, "info")
  -- else
  --   mlog("Failed to run tail -100f " .. path .. " in window " .. window_name, "error")
  --   return
  -- end
  shell.show_session_in_popup(session_name, parent_path)
  shell.run_in_pane(session_name .. ":1", false, "tail -100f " .. path)
  -- if shell.show_session_in_popup(session_name) then
  --   mlog("Showing session " .. session_name .. " in popup", "info")
  -- else
  --   mlog("Failed to show session " .. session_name .. " in popup", "error")
  --   return
  -- end
end


function M.exists(var)
    for k, _ in pairs(_G) do
        if k == var then
            return true
        end
    end
end


function M.killer()
    local cmd = "!lsof -t -i:8080 | xargs kill -9"
    vim.cmd(cmd)
end


function M.newbinsource(cmd)
    return function()
        local file = io.popen(cmd)
        local output = file:read("*all")
        file:close()
        output = vim.split(output, "\n")
        return output
    end
end


-- add the escape character to special characters
function M.escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end


function M.return_last_pos()
  if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
    vim.cmd("normal! g'\"")
  end
end


function M.buf_close_it()
  local current_buf = vim.fn.bufnr("%")
  local alternate_buf = vim.fn.bufnr("#")

  if vim.fn.buflisted(alternate_buf) == true then
    vim.cmd('buffer #')
  else
    vim.cmd('bnext')
  end

  if vim.fn.buflisted(current_buf) then
    vim.cmd("bdelete! " .. current_buf)
  end
end


function M.strip_white_space()
  local save_cursor = vim.fn.getpos(".")
  local old_query = vim.fn.getreg("/")
  vim.cmd([[:%s/\(\s\+\|\)$//e]])
  vim.fn.setpos(".", save_cursor)
  vim.fn.setreg("/", old_cursor)
end


-- Diff current buffer and the original file
function M.diff_with_saved()
  local filetype = vim.api.nvim_eval("&ft")
  vim.cmd([[
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  ]])
  vim.cmd("setlocal bt=nofile bh=wipe nobl noswf ro ft=" .. filetype)
end


function M.show_documentation()
  local filetype = vim.bo.filetype
  if vim.tbl_contains({ 'vim','help' }, filetype) then
    vim.cmd('h '..vim.fn.expand('<cword>'))
  elseif vim.tbl_contains({ 'man' }, filetype) then
    vim.cmd('Man '..vim.fn.expand('<cword>'))
  elseif vim.fn.expand('%:t') == 'Cargo.toml' and require('crates').popup_available() then
    require('crates').show_popup()
  else
    vim.lsp.buf.hover()
  end
end


function M.toggle_lsp_client()
  local buf = vim.api.nvim_get_current_buf()

  local clients = vim.lsp.get_clients({ bufnr = buf })
  if not vim.tbl_isempty(clients) then
    vim.cmd("LspStop")
  else
    vim.cmd("LspStart")
  end
end






-- function to create quick note
-- function CreateQuickNote()
--     -- Get the current timestamp
--     local timestamp = os.date("%Y-%m-%d/%H-%M-%S")
--     -- Build the file path
--     local notes_dir = notes_base .. "/notes/Inbox/"
--     local file_path = notes_dir .. timestamp .. ".md"

--     -- Ensure the directory structure exists
--     vim.fn.system({ "mkdir", "-p", vim.fn.fnamemodify(file_path, ":h") })

--     -- Open the file in the current buffer
--     vim.cmd("e " .. file_path)

--     -- Write the filename as the first line in the buffer
--     local buf = vim.api.nvim_get_current_buf()
--     local header = "# " .. vim.fn.fnamemodify(file_path, ":t") -- Adds the filename as a Markdown header
--     vim.api.nvim_buf_set_lines(buf, 0, 0, false, { header }) -- Inserts at the beginning of the buffer
-- end



return M
