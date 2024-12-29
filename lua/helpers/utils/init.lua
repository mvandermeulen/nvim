--[[
-- Helpers: Utils
--
-- Author: Mark van der Meulen
-- Updated: 2024-09-22
--]]

local M = {}

local nvim_eleven = vim.fn.has 'nvim-0.11' == 1

local fs_status, fs = pcall(require, 'helpers.utils.fs')
if not fs_status then
  local msg = "Error loading helper: fs"
  print(msg)
  vim.notify(msg, vim.log.levels.ERROR)
  return M
end

-------- Register Scratchpad --------
local scratch_status, scratch = pcall(require, 'helpers.utils.scratch')
if not scratch_status then
  local msg = "Error loading helper: scratch"
  print(msg)
  vim.notify(msg, vim.log.levels.ERROR)
  return M
end


-------- Register Path --------
local path_status, Path = pcall(require, 'helpers.utils.Path')
if not path_status then
  local msg = "Error loading helper: Path"
  print(msg)
  vim.notify(msg, vim.log.levels.ERROR)
  return M
end


local u_status, u = pcall(require, 'helpers.utils.utils')
if not u_status then
  local msg = "Error loading helper: utils.utils"
  print(msg)
  vim.notify(msg, vim.log.levels.ERROR)
  return M
end



M.big_file_threshold = 100 * 1024 -- 100KB

---@param list any[]
---@param x any
---@return boolean
function M.in_list(list, x)
  for _, v in ipairs(list) do
    if v == x then
      return true
    end
  end
  return false
end

---remove an item from a list by value
---@param list any[]
---@param value_to_remove any
function M.remove_by_value(list, value_to_remove)
  for i = #list, 1, -1 do -- Iterate backwards!
    if list[i] == value_to_remove then
      table.remove(list, i)
    end
  end
end

---filters a list
---@param list any[]
---@param condition fun(item: any): boolean
---@return any[]
function M.filter_list(list, condition)
  local new_list = {}
  for _, v in ipairs(list) do
    if condition(v) then
      table.insert(new_list, v)
    end
  end
  return new_list
end

---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
  local Config = require "lazy.core.config"
  if Config.plugins[name] and Config.plugins[name]._.loaded then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

function M.tbl_flatten(t)
  return nvim_eleven and vim.iter(t):flatten(math.huge):totable() or vim.tbl_flatten(t)
end

-- check if cwd is a git repo
M.is_git_repo = function(path)
  local path = path or vim.loop.cwd()
  local gitpath = fs.path_join(path, ".git")
  return fs.is_directory(gpath)
end

-- check if cwd is has env directory
M.has_venv_dir = function(path, venv)
  local path = path or vim.loop.cwd()
  local vpath = fs.path_join(path, venv)
  return fs.is_directory(vpath)
end

-- check if string is in table
M.is_string_in_table = function(str, tbl)
  for _, value in ipairs(tbl) do
    if value == str then
      return true
    end
  end
  return false
end

function M.add_venv_to_path(path)
  local path = path or vim.loop.cwd()
  for _, v in ipairs { "venv", ".venv" } do
    if M.has_venv_dir(path, v) then
      local venv = fs.path_join(path, v)
      if not M.is_string_in_table(venv, _G.my.helpers.venv_paths_added) then
        table.insert(_G.my.helpers.venv_paths_added, venv)
        vim.env.PATH = venv .. ":" .. vim.env.PATH
      end
      return venv
    end
  end
  -- if M.has_venv_dir(path) then
  --   local venv = fs.path_join(path, "venv")
  --   if not M.is_string_in_table(venv, _G.my.helpers.venv_paths_added) then
  --     table.insert(_G.my.helpers.venv_paths_added, venv)
  --     vim.env.PATH = venv .. ":" .. vim.env.PATH
  --   end
  --   return venv
  -- end
  return nil
end

function M.create_floating_scratch(content)
  -- Get editor dimensions
  local width = vim.api.nvim_get_option "columns"
  local height = vim.api.nvim_get_option "lines"

  -- Calculate the floating window size
  local win_height = math.ceil(height * 0.8) + 2 -- Adding 2 for the border
  local win_width = math.ceil(width * 0.8) + 2 -- Adding 2 for the border

  -- Calculate window's starting position
  local row = math.ceil((height - win_height) / 2)
  local col = math.ceil((width - win_width) / 2)

  -- Create a buffer and set it as a scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "filetype", "sh") -- for syntax highlighting

  -- Create the floating window with a border and set some options
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = win_width,
    height = win_height,
    border = "single", -- You can also use 'double', 'rounded', or 'solid'
  })

  -- Check if we've got content to populate the buffer with
  if content then
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, content)
  else
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "This is a scratch buffer in a floating window." })
  end

  vim.api.nvim_win_set_option(win, "wrap", false)
  vim.api.nvim_win_set_option(win, "cursorline", true)

  -- Map 'q' to close the buffer in this window
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q!<CR>", { noremap = true, silent = true })
end

function M.add_project_from_line(current_line)
  local project_pattern = "PROJECT:%s*(%S+)"
  local project_name = current_line:match(project_pattern)

  if not project_name then
    require "notify"("No project name found on the line.", "error")
    return
  end

  local file_path = vim.fn.expand "~/projects.txt"
  local projects = {}
  local file = io.open(file_path, "r")

  if file then
    for line in file:lines() do
      projects[line] = true
    end
    file:close()
  end

  if projects[project_name] then
    require "notify"("Project already exists: " .. project_name, "info")
  else
    file = io.open(file_path, "a")
    if file then
      file:write(project_name .. "\n")
      file:close()
      require "notify"("Project added: " .. project_name, "info")
    else
      require "notify"("Failed to open the file.", "error")
    end
  end
end


-- M.api = require('helpers.utils.api')
-- M.icons = require('helpers.utils.icons')
-- M.fs = require('helpers.utils.fs')

-- _G.c = require('utils.colors')
-- _G.Class = require('utils.class')
-- _G.Array = require('utils.array')
-- _G.create_picker = require('plugins.navigation.telescope.picker')
-- _G.utils = M
-- _G.U = M


---Open a scratch window with given content
---@param content any
---@return nil
function M.open_scratch_win(content)
  local floatopts = scratch.float_win()
  local bufnr = floatopts.bufnr

  -- format content
  local function sanitize_input(e)
    if type(e) == "string" then
      return e
    else
      return vim.inspect(e)
    end
  end

  content = vim.tbl_map(sanitize_input, content)

  local function split_line_return(entry)
    return vim.fn.split(entry, "\\n")
  end

  content = vim.tbl_map(split_line_return, content)
  content = M.tbl_flatten(content)

  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, content)
end

---Dump the args in vim messages
-- function _G.dump(...)
--   local objects = vim.tbl_map(vim.inspect, { ... })
--   print(table.unpack(objects))
-- end

---Dump the args inside a floating window scratch buffer
-- function _G.dumpf(...)
--   local content = vim.tbl_map(vim.inspect, { ... })
--   open_scratch_win(content)
-- end

-------- Mocks --------

---Generate a mock
---@param opts table<string, any>
---@return any
function M.mock(opts)
    local Mock = opts or {}
    setmetatable(Mock, {
      __call = function(...) ---@diagnostic disable-line:unused-vararg
        -- log.trace(("called __call with args=%s"):format(...))
        print(("called __call with args=%s"):format(...))
        return Mock
      end,
      __index = function(...) ---@diagnostic disable-line:unused-vararg
        -- log.trace(("called __index with args=%s"):format(...))
        print(("called __index with args=%s"):format(...))
        return Mock
      end,
    })
    return Mock
end

-------- Module Operations --------

---Return truthy if module is available
---@param name string
---@return boolean
function M.is_module_available(name)
    if package.loaded[name] then
      return true
    else
      for _, searcher in ipairs(package.loaders) do
        local loader = searcher(name)
        if type(loader) == "function" then
          package.preload[name] = loader
          return true
        end
      end
      return false
    end
end

---Try to require. If module is not available, returns a mock.
---@param name string
---@return any
function M.safe_require(name)
    local res, mod = pcall(require, name)
    if not res then
      -- log.error(mod)
      print(mod)
      return M.mock()
    else
      return mod
    end
end

-------- FilePaths --------

-- debug.getinfo to get the filepath of the current lua script
-- then get its parent directory

M.lua_srcdir = Path:new(vim.fn.fnamemodify(debug.getinfo(1, "S").short_src, ":p:h")) -- "$HOME/.config/nvim/lua/wax"

-------- Cache --------

M._my_cache = {}

---@class Wax.CacheFnOpts
---@field per_buffer? boolean

---@generic T : function
---@param fn T
---@param opts Wax.CacheFnOpts
---@return T
function M.my_cache_fn(fn, opts)
  opts = opts or {}

  local per_buffer = opts.per_buffer == nil or opts.per_buffer

  -- local function to_cache_key(...)
  --   local key = { args = { ... } }
  --   if per_buffer then
  --     key.buffer = vim.api.nvim_buf_get_name(0)
  --   end
  --   return vim.inspect(key, { depth = 2 })
  -- end
  local function to_cache_key(...)
    local mem_address = string.gsub(tostring(fn), "function: ", "")

    local args = vim
      .iter({ ... })
      :filter(function(e)
        return e ~= nil and e ~= ""
      end)
      :map(tostring)

    local pieces = { mem_address }

    if #args then
      table.insert(pieces, table.concat(args, ", "))
    end

    if per_buffer then
      local buf_name = vim.api.nvim_buf_get_name(0)
      if #buf_name > 0 then
        table.insert(pieces, buf_name)
      else
        table.insert(pieces, vim.loop.cwd())
      end
    end

    local key = table.concat(pieces, " | ")

    return key
  end

  local function wrap(...)
    local key = ""
    if #{ ... } == 0 then
      key = to_cache_key(...)
    end
    if string.len(key) == 0 then
      -- log.trace("Could not cache call due to empty cache key.")
      -- print("Could not cache call due to empty cache key.")
      return fn(...)
    end

    local value = vim.tbl_get(M._my_cache, key)
    if value == nil then
      M._my_cache[key] = fn(...)
      -- log.trace("Cached returned value using cache key", key)
      -- print("Cached returned value using cache key " .. key)
    else
      print("Found in cache using cache key " .. key)
    end

    return M._my_cache[key]
  end

  -- return wrap
  return fn
end

-------- Logs --------

-- _G.log = require("wax.logs").new({
--   plugin = "wax",
--   level = waxopts.loglevel,
--   use_console = false,
-- })

-------- WorkSpace --------

---Get stringified result of sh command
---@param cmd string[] command to run
---@param cwd? string current working directory
---@return string[] stdout
---@return number command status
---@return string[] stderr
function M.get_os_command_output(cmd, cwd)
  if type(cmd) ~= "table" then
    return {}, 0, {}
  end

  cwd = cwd or vim.loop.cwd()
  local Job = require("plenary.job")

  local command = table.remove(cmd, 1)
  local stderr = {}
  local stdout, ret = Job:new({
    command = command,
    args = cmd,
    cwd = cwd,
    on_stderr = function(_, data)
      table.insert(stderr, data)
    end,
  }):sync()
  return stdout, ret, stderr
end

---Check if cwd is git versioned
---@param cwd string | nil
---@return boolean
function M.is_git(cwd)
  cwd = cwd or vim.loop.cwd()
  local cmd = { "git", "rev-parse", "--show-toplevel" }
  local git_root, ret = M.get_os_command_output(cmd, cwd)
  return not (ret ~= 0 or #git_root <= 0)
end

M.find_root_dir = M.my_cache_fn(
    ---Return the root directory
    ---@param path string | nil
    ---@return string | nil
    function(path, patterns)
      local default_patterns = { ".git" }
      patterns = patterns or default_patterns
      path = path or vim.loop.cwd()
      local root_dir = Path:new(path):find_root_dir(patterns)
      if root_dir ~= nil then
        return root_dir.path
      else
        return nil
      end
    end
)

M.is_monorepo = M.my_cache_fn(
  ---Return the root directory
  ---@param cwd string | nil
  ---@return string | nil
  function(cwd)
    -- cwd = cwd or vim.loop.cwd()
    local root_dir = M.find_root_dir(nil, { ".git" })
    local root_subproject = M.find_root_dir(nil, { "package.json" })
    local is_monorepo = root_dir and root_subproject and root_dir ~= root_subproject
    return is_monorepo
  end
)

---Convert the path of the workspace to its name
---@param path string
---@return string?
function M.to_workspace_name(path)
  return vim.fn.fnamemodify(path, ":t:r") or nil
end

---Return the name of the workspace from a path
---@param path string
---@return string?
function M.find_workspace_name(path)
  local root_dir = M.find_root_dir(path or vim.api.nvim_buf_get_name(0))
  if root_dir == nil then
    return nil
  end
  return M.to_workspace_name(root_dir)
end

-------- Utilities --------

---Check if the bufnr should be considered a big file
---@param fpath string
---@return boolean
function M.is_big_file(fpath)
  local byte_size = vim.fn.getfsize(fpath)

  if byte_size == 0 then
    print(("Path given is a directory: "):format(fpath))
    return false
  elseif byte_size == -1 then
    print(("Could not find file with path being: %s"):format(fpath))
    return false
  elseif byte_size == -2 then
    return true -- size too big to fit in a Number
  else
    return byte_size > M.big_file_threshold
  end
end


function M.insert_new_line_in_current_buffer(str, opts)
  local bufnr = 0 -- current buffer
  local default_opts = { delta = 1 }
  opts = vim.tbl_deep_extend("keep", opts or {}, default_opts)

  local pos = vim.api.nvim_win_get_cursor(bufnr)
  local n_line = pos[1]

  local n_insert_line = n_line + opts.delta

  -- deduce indent for line:
  local n_space = vim.fn.indent(n_line)

  -- special cases depending on filetype
  -- local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
  if filetype == "python" then
    n_space = vim.fn.GetPythonPEPIndent(n_insert_line)
    if n_space == -1 then -- but fix it when can't find
      n_space = vim.fn.indent(n_line)
    end
  else
    -- if treesitter available, might use it to correct corner cases:
    local has_treesitter = M.is_module_available("nvim-treesitter.indent")
    if has_treesitter then
      local ts_indent = require("nvim-treesitter.indent")
      n_space = ts_indent.get_indent(n_insert_line)
    end
  end

  local space = string.rep(" ", n_space)
  local str_added = ("%s%s"):format(space, str)

  vim.api.nvim_buf_set_lines(0, n_insert_line - 1, n_insert_line - 1, false, { str_added })

  -- Waiting for https://github.com/neovim/neovim/issues/19832
  -- to avoid putting this jump in the jumplist
  vim.api.nvim_win_set_cursor(0, { n_insert_line, pos[2] })
end

M.capture = function(cmd, raw)
  local f = assert(io.popen(cmd, "r"))
  local s = assert(f:read("*a"))
  f:close()
  if raw then
    return s
  end
  s = string.gsub(s, "^%s+", "")
  s = string.gsub(s, "%s+$", "")
  s = string.gsub(s, "[\n\r]+", " ")
  return s
end

M.start_replace = function()
  vim.cmd.startreplace()
end

M.reload = function(package_name)
  local t = u.split(package_name, " ")
  for _, value in ipairs(t) do
    package.loaded[value] = nil
    local status = pcall(require, value)
    if not status then
      require("notify")(value .. " is not available.", "warn")
    end
  end
end

M.reload_current = function()
  local current_buffer = u.get_buffer_name()
  local module_name = u.split(current_buffer, "/lua")
  local patterns = { "/", ".lua" }
  for _, value in ipairs(patterns) do
    module_name = string.gsub(current_buffer, value, "")
  end
  package.loaded[module_name] = nil
  local status = pcall(require, module_name)
  if not status then
    require("notify")(module_name .. " is not available.", "error")
  end
end

M.run_script = function(script_name, args)
  local nvim_scripts_dir = "~/.config/nvim/scripts"
  local f = nil
  if args == nil then
    f = io.popen(string.format("/bin/bash %1s/%2s", nvim_scripts_dir, script_name))
  else
    f = io.popen(string.format("/bin/bash %1s/%2s %3s", nvim_scripts_dir, script_name, args))
  end
  local output = f:read("*a")
  f:close()
  return output
end

M.stash = function(name)
  vim.fn.system("git stash -u -m " .. name)
end

M.buf_only = function()
  local option = vim.api.nvim_get_option_value
  local del_non_modifiable = vim.g.bufonly_delete_non_modifiable or false

  local cur = vim.api.nvim_get_current_buf()

  local deleted, modified = 0, 0

  for _, n in ipairs(vim.api.nvim_list_bufs()) do
    -- If the iter buffer is modified one, then don't do anything
    if option("modified", { buf = n }) then
      -- iter is not equal to current buffer
      -- iter is modifiable or del_non_modifiable == true
      -- `modifiable` check is needed as it will prevent closing file tree ie. NERD_tree
      modified = modified + 1
    elseif n ~= cur and (option("modifiable", { buf = n }) or del_non_modifiable) then
      vim.api.nvim_buf_delete(n, {})
      deleted = deleted + 1
    end
  end

  require("notify")("BufOnly: " .. deleted .. " deleted buffer(s), " .. modified .. " modified buffer(s)")
end

M.screenshot = function()
  local async_job_ok, job = pcall(require, 'plenary.job')
  if not async_job_ok then
    require("notify")("Plenary is not installed!", "error")
  end

  local language = vim.bo.filetype
  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local create_screenshot = job:new({
    command = 'silicon',
    args = { '--from-clipboard', '-l', language, '--to-clipboard', '--line-offset', line_number },
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        require("notify")("Could not create screenshot! Do you have silicon installed?", "error")
        return
      end
      require("notify")("Screenshot copied to clipboard", vim.log.levels.INFO)
    end,
  })

  create_screenshot:start()
end







return M
