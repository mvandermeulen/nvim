--[[
-- Helpers: Utils
--
-- Author: Mark van der Meulen
-- Updated: 2024-09-22
--]]

local nvim_eleven = vim.fn.has 'nvim-0.11' == 1
local fs_status, fs = pcall(require, 'helpers.fs')

local M = {}

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
M.has_venv_dir = function(path)
  local path = path or vim.loop.cwd()
  local vpath = fs.path_join(path, "venv")
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
  if M.has_venv_dir(path) then
    local venv = fs.path_join(path, "venv")
    if not M.is_string_in_table(venv, _G.my.helpers.venv_paths_added) then
      table.insert(_G.my.helpers.venv_paths_added, venv)
      vim.env.PATH = venv .. ":" .. vim.env.PATH
    end
    return venv
  end
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

return M
