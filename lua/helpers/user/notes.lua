--[[
-- Helpers: Notes
--
-- Author: Mark van der Meulen
-- Updated: 2025-02-10
--]]


local M = {}

local uv = vim.uv or vim.loop
local utils = require("helpers.utils.utils")

-- Default configuration
M.config = {
  socket_path = utils.get_home() .. '/.local/state/snuggle.socket',-- default socket path
}
-- get length of current word
function M.get_word_length()
    local word = vim.fn.expand "<cword>"
    return #word
end

-- Extract plugin-name:init.lua or plain filename
function M.extract_tag_from_source(source)
  source = source:gsub("\\", "/")
  local file = source:match("[^/]+$") or "<unknown>"
  if file == "init.lua" then
    local module = source:match("/lua/([^/]+)/init%.lua$")
    if module then
      return "@" .. module:gsub("%s+", "_") .. ":init.lua"
    end
  end

  return "@" .. file:gsub("%s+", "_")
end

-- Main log function
function M.log(...)
  local info = debug.getinfo(2, "S")
  local source = info and info.short_src or "<unknown>"
  local tag = M.extract_tag_from_source(source)

  local args = { ... }
  table.insert(args, 1, tag)

  M.write(table.concat(args, " "))
end

-- Write to the UNIX socket
function M.write(message)
  -- if not message or message:match("^%s*$") then
  --   return
  -- end
  if not message then
    vim.notify("No message to write to socket", vim.log.levels.WARN)
    return
  end

  local socket_path = M.config.socket_path
  local uv = vim.loop
  local sock = uv.new_pipe(false) -- false: not IPC

  sock:connect(socket_path, function(err)
    if err then
      vim.schedule(function()
        vim.notify("Socket write error: " .. err, vim.log.levels.WARN)
      end)
      sock:close()
      return
    end

    sock:write(message .. "\n")
    sock:shutdown(function()
      sock:close()
    end)
  end)
end



function M.insert_todo_and_comment()
  -- Insert the TODO text at the current cursor position
  local line = vim.api.nvim_get_current_line()
  print("Original line: ", line)

  vim.api.nvim_put({ "TODO:(mvandermeulen)" }, "", true, true)
  vim.cmd [[execute "normal gcc"]]
  -- Uncomment the line
  -- vim.cmd [[execute "normal \<Plug>(comment_toggle_linewise)"]]
end

function M.record_was_doing()
  local doing = vim.ui.input("What were you doing? ")
  vim.cmd("Was " .. doing)
end


function M.socket_paste()
  print(M.config.socket_path)
  M.write(vim.fn.getreg('"'))
  -- local pipe = uv.new_pipe(false)
  -- uv.pipe_connect(pipe, vim.fn.resolve(socket_path), function(err)
  --     assert(not err, err)
  -- end)
  -- pipe:write('Testing\n')
  -- pipe:write(vim.fn.getreg(''))
  -- pipe:close()
  -- local socket = vim.uv.new_pipe(false)
  -- local err = async.uv.pipe_connect(socket, vim.fn.resolve(socket_path))
  -- assert(not err, err)
  -- async.uv.write(socket, vim.fn.getreg(''))
end

function M.send_to_snuggle()
  local socket_path = M.config.socket_path
  print(socket_path)
  local _s = vim.fn.sockconnect('pipe', vim.fn.resolve(socket_path), {rpc = false})
  if _s == -1 then
    vim.cmd('echomsg "Failed to open channel, status = ' .. _s .. '"')
    return
  end
  vim.fn.chansend(_s, vim.fn.getreg('"') )
  vim.fn.chanclose(_s)
  -- vim.fn.chansend(_s, vim.fn.getreg(''))
  -- vim.loop.pipe_connect(pipe, vim.fn.resolve(socket_path), function(err)
  --     assert(not err, err)
  -- end)
    -- vim.fn.chansend(_s, "SET local_neovim_pipe_path " .. self.my.server .. "\n")
  -- pipe:write(vim.fn.getreg(''))
  -- pipe:close()
end



return M
