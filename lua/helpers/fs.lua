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

function M.insert_file_path()
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  require("telescope.builtin").find_files {
    cwd = "~/dev", -- Set the directory to search
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local selected_file = action_state.get_selected_entry(prompt_bufnr).path
        actions.close(prompt_bufnr)

        -- Replace the home directory with ~
        selected_file = selected_file:gsub(vim.fn.expand "$HOME", "~")

        -- Ask the user if they want to insert the full path or just the file name
        local choice = vim.fn.input "Insert full path or file name? (n[ame]/p[ath]): "
        local text_to_insert
        if choice == "p" then
          text_to_insert = selected_file
        elseif choice == "n" then
          text_to_insert = vim.fn.fnamemodify(selected_file, ":t")
        end

        -- Move the cursor back one position
        local col = vim.fn.col "." - 1
        vim.fn.cursor(vim.fn.line ".", col)

        -- Insert the text at the cursor position
        vim.api.nvim_put({ text_to_insert }, "c", true, true)
      end)
      return true
    end,
  }
end

return M
