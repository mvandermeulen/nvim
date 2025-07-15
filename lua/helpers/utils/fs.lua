--[[
-- Helper: filesystem
--
-- Author: Mark van der Meulen
-- Updated: 2024-09-21
--]]

local M = {}

local format = vim.fn.fnamemodify


local function tbl_flatten(t)
  return nvim_eleven and vim.iter(t):flatten(math.huge):totable() or vim.tbl_flatten(t)
end

function M.dirname(path)
  local strip_dir_pat = '/([^/]+)$'
  local strip_sep_pat = '/$'
  if not path or #path == 0 then
    return path
  end
  local result = path:gsub(strip_sep_pat, ''):gsub(strip_dir_pat, '')
  if #result == 0 then
    return '/'
  end
  return result
end

function M.path_join(...)
  return table.concat(tbl_flatten { ... }, '/')
end

-- check if path is directory
M.is_directory = function(path)
  local ok, _ = vim.loop.fs_stat(path)
  if not ok then
    return false
  else
    return true
  end
end

function M.root(opts)
    local opts = opts or { capitalize = false }
    local cwd = vim.fn.getcwd()
    local root = format(cwd, ":t")

    if opts.capitalize then
        return root:upper()
    else
        return root
    end
end

function M.relative_path(loc)
    return format(loc, ":.")
end

function M.filename(loc)
    return format(loc, ":t")
end

function M.filestem(loc)
    return format(loc, ":t:r")
end

function M.format(loc, fmt)
    if fmt == "absolute" then
        return loc
    elseif fmt == "relative" then
        return M.relative_path(loc)
    elseif fmt == "filename" then
        return M.filename(loc)
    elseif fmt == "filestem" then
        return M.filestem(loc)
    else
        vim.api.nvim_err_writeln("Invalid path format: " .. fmt)
        return nil
    end
end

function M.print_current_file_dir()
  local dir = vim.fn.expand "%:p:h"
  if dir ~= "" then
    print(dir)
  end
end

function M.reload_module(name)
  package.loaded[name] = nil
  return require(name)
end

-- Function to reload the current Lua file
function M.reload_current_file()
  local current_file = vim.fn.expand "%:p"

  if current_file:match "%.lua$" then
    vim.cmd("luafile " .. current_file)
    print("Reloaded file: " .. current_file)
  else
    print("Current file is not a Lua file: " .. current_file)
  end
end




function M.shorten_path_relative(path)
  return path
    -- Remove CWD
    :gsub(vim.pesc(vim.loop.cwd()) .. '/', '')
    -- Remove home dir
    :gsub(vim.pesc(vim.fn.expand '$HOME'), '~')
    -- Remove trailing slash
    :gsub('/$', '')
end

function M.shorten_path_absolute(path)
  return path:gsub(vim.pesc(vim.fn.expand '$HOME'), '~')
end

---@param filename string
---@return table | nil
function M.read_json_file(filename)
  local Path = require 'plenary.path'

  local path = Path:new(filename)
  if not path:exists() then
    return nil
  end

  local json_contents = path:read()
  local json = vim.fn.json_decode(json_contents)

  return json
end

M.get_root_dir = function()
  local bufname = vim.fn.expand('%:p')
  if vim.fn.filereadable(bufname) == 0 then
    return
  end

  local parent = vim.fn.fnamemodify(bufname, ':h')
  local git_root = vim.fn.systemlist('git -C ' .. parent .. ' rev-parse --show-toplevel')
  if #git_root > 0 and git_root[1] ~= '' then
    return git_root[1]
  else
    return parent
  end
end

function M.find_file(filename, excluded_dirs)
  if not excluded_dirs then
    excluded_dirs = { ".git", "node_modules", ".venv" }
  end
  local exclude_str = ""
  for _, dir in ipairs(excluded_dirs) do
    exclude_str = exclude_str .. " --exclude " .. dir
  end
  local command = "fd --hidden --no-ignore" .. exclude_str .. " '" .. filename .. "' " .. vim.fn.getcwd() .. " | head -n 1"
  local file = io.popen(command):read("*l")
  local path = file and file or nil

  return path
end

M.is_wsl = function() return vim.fn.system('grep microsoft /proc/version'):len() > 0 end

---@type boolean
M.is_windows = vim.loop.os_uname().version:match('Windows')

---@param ... string
---@return boolean
M.any_exists = function(...)
	for _, name in ipairs({ ... }) do
		if M.exists(name) then return true end
	end
	return false
end

---@param filepath string
---@return boolean
M.exists = function(filepath)
	local stat = vim.loop.fs_stat(filepath)
	return stat ~= nil and stat.type ~= nil
end

---@return string
M.join = function(...)
	local sep = M.is_windows and '\\' or '/'
	local joined = table.concat({ ... }, sep)
	if M.is_windows then
		joined = joined:gsub('\\\\+', '\\')
	else
		joined = joined:gsub('//+', '/')
	end
	return joined
end

M.is_absolute = function(path)
	if M.is_windows then
		return path:lower():match('^%a:')
	else
		return vim.startswith(path, '/')
	end
end

M.abspath = function(path)
	if not M.is_absolute(path) then path = vim.fn.fnamemodify(path, ':p') end
	return path
end

--- Returns true if candidate is a subpath of root, or if they are the same path.
---@param root string
---@param candidate string
---@return boolean
M.is_subpath = function(root, candidate)
	if candidate == '' then return false end
	root = vim.fs.normalize(M.abspath(root))
	-- Trim trailing "/" from the root
	if root:find('/', -1) then root = root:sub(1, -2) end
	candidate = vim.fs.normalize(M.abspath(candidate))
	if M.is_windows then
		root = root:lower()
		candidate = candidate:lower()
	end
	if root == candidate then return true end
	local prefix = candidate:sub(1, root:len())
	if prefix ~= root then return false end

	local candidate_starts_with_sep = candidate:find('/', root:len() + 1, true) == root:len() + 1
	local root_ends_with_sep = root:find('/', root:len(), true) == root:len()

	return candidate_starts_with_sep or root_ends_with_sep
end

M.get_stdpath_filename = function(stdpath, ...)
  local ok, dir = pcall(vim.fn.stdpath, stdpath)
  if not ok then
    if stdpath == 'log' then
      return M.get_stdpath_filename('cache', ...)
    elseif stdpath == 'state' then
      return M.get_stdpath_filename('data', ...)
    else
      error(dir)
    end
  end
  return M.join(dir, ...)
end

---@param filepath string
---@return string?
M.read = function(filepath)
	if not M.exists(filepath) then return nil end
	local fd = assert(vim.loop.fs_open(filepath, 'r', 420)) -- 0644
	local stat = assert(vim.loop.fs_fstat(fd))
	local content = vim.loop.fs_read(fd, stat.size)
	vim.loop.fs_close(fd)
	return content
end

---@param filepath string
---@return table?
M.read_json = function(filepath)
	local content = M.read(filepath)
	if content then return vim.json.decode(content) end
end

---@param dir? string (opcional) diretório que será procurado os arguivos. Usa o cwd por padrão
---@return Array files Lista com os nomes dos arquivos
M.list_files = function(dir)
	dir = dir or vim.fn.getcwd()
	local fd = vim.loop.fs_opendir(dir, nil, 32)
	local entries = vim.loop.fs_readdir(fd)
	local ret = {}
	while entries do
		for _, entry in ipairs(entries) do
			if entry.type == 'file' then table.insert(ret, entry.name) end
		end
		entries = vim.loop.fs_readdir(fd)
	end
	vim.loop.fs_closedir(fd)
	return ret
end

---@param dirname string
---@param perms? number
M.mkdir = function(dirname, perms)
	if not perms then
		perms = 493 -- 0755
	end
	if not M.exists(dirname) then
		local parent = vim.fs.dirname(dirname)
		if not M.exists(parent) then M.mkdir(parent) end
		vim.loop.fs_mkdir(dirname, perms)
	end
end

---@param filename string
---@param contents string
M.write = function(filename, contents)
	M.mkdir(vim.fn.fnamemodify(filename, ':p:h'))
	local fd = assert(vim.loop.fs_open(filename, 'w', 420)) -- 0644
	vim.loop.fs_write(fd, contents)
	vim.loop.fs_close(fd)
end

---@param filename string
M.delete_file = function(filename)
	if M.exists(filename) then
		vim.loop.fs_unlink(filename)
		return true
	end
end

---@param filename string
---@param obj any
M.write_json = function(filename, obj)
	local serialized = vim.json.encode(obj)
	M.write(filename, serialized)
end


return M
