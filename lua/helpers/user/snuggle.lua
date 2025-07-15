--[[
-- Helpers: Snuggle
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-15
--]]


local M = {}


-- Default configuration
M.config = {
  socket_path = utils.get_home() .. '/.local/state/snuggle.socket',-- default socket path
}


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
  local uv = vim.uv or vim.loop
  -- local uv = vim.loop
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
  -- print(socket_path)
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
