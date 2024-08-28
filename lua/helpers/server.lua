M = {}

M.server = { }

M.server.address = '127.0.0.1:13370'
M.server.pipe = nil
M.server.running = false

local function is_empty(s)
    return ((s == '') or (s == nil))
end

local function get_output_as_string(data)
    output = ""
    for i, k in ipairs(data) do
      if (k ~= '') then
        output = output .. k .. ", "
      end
    end
    if (output ~= '') then
      output = output:sub(1, -3)
    end
    return output
end

local function handle_cmd_error(chanid, data, name)
    output = get_output_as_string(data)

    if is_empty(output) then
      return
    end

    print("Error executing cmd: "..command)
    print(output)
end

function set_server_value_in_redis(server_socket_path)

    command = "/Users/vandem/scripts/venv/bin/python3 /Users/vandem/scripts/nvim_add_server_socket.py " .. server_socket_path
    local jobid = vim.fn.jobstart(command,
        {
            on_stdout = function(chanid, data, name)
              output = get_output_as_string(data)
              if is_empty(output) then
                return
              end
              print(output)
            end,
            on_stderr = function(chanid, data, name)
              handle_cmd_error(chanid, data, name)
            end,
        }
    )
    vim.fn.jobwait({ jobid })

end

function M:vdm_start_server()
  if self.server.running or self.server.pipe ~= nil then
    print('Server already running on ' .. self.server.pipe)
  else
    self.server.pipe = vim.fn.serverstart("vdmpy." .. os.time())
    self.server.running = true
    set_server_value_in_redis(self.server.pipe)
    print("Server started on " .. self.server.pipe)
    -- local _s = vim.fn.sockconnect("tcp", "127.0.0.1:6379")
    -- vim.fn.chansend(_s, "SET local_neovim_pipe_path " .. self.my.server .. "\n")
  end
end

return M
