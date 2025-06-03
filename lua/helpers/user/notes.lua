--[[
-- Helpers: Notes
--
-- Author: Mark van der Meulen
-- Updated: 2025-02-10
--]]


local M = {}

local uv = vim.uv or vim.loop

-- get length of current word
function M.get_word_length()
    local word = vim.fn.expand "<cword>"
    return #word
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
  local socket_path = os.getenv('HOME') .. '/.local/tmp/snuggle.socket'
  local pipe = uv.new_pipe(false)
  print(socket_path)
  uv.pipe_connect(pipe, vim.fn.resolve(socket_path), function(err)
      assert(not err, err)
  end)
  pipe:write('Testing\n')
  -- pipe:write(vim.fn.getreg(''))
  pipe:close()
  -- local socket = vim.uv.new_pipe(false)
  -- local err = async.uv.pipe_connect(socket, vim.fn.resolve(socket_path))
  -- assert(not err, err)
  -- async.uv.write(socket, vim.fn.getreg(''))
end

function M.send_to_snuggle()
  local socket_path = os.getenv('HOME') .. '/.local/tmp/snuggle.socket'
  print(socket_path)
  local _s = vim.fn.sockconnect('pipe', vim.fn.resolve(socket_path), {rpc = false})
  if _s == -1 then
    vim.cmd('echomsg "Failed to open channel, status = ' .. _s .. '"')
    return
  end
  vim.fn.chansend(_s, vim.fn.getreg('"'))
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
