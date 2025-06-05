M = {}


local u = require("helpers.utils.utils")


M.server = { }
M.server.address = '127.0.0.1:13370'
M.server.pipe = nil
M.server.running = false
M.server.script_path = u.get_home() .. '/.scripts'
M.server.script_name = 'nvim_add_server_socket.py'
M.server.script_env = M.server.script_path .. '/venv/bin/python3'

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

function M.verify_environment()
  local venv_path = M.server.script_env
  if not vim.fn.executable(venv_path) then
    print("Python virtual environment not found at: " .. venv_path)
    print("Please create a virtual environment and install the required packages.")
    return false
  end
  if not u.file_exists(M.server.script_path .. '/' .. M.server.script_name) then
    print("Script not found at: " .. M.server.script_path .. '/' .. M.server.script_name)
    print("Please ensure the script is in the correct location.")
    return false
  end
  return true
end

function M.generate_command(server_socket_path)
  if not M.verify_environment() then
    return nil
  end

  local command = M.server.script_env .. " " .. M.server.script_path .. "/" .. M.server.script_name .. " " .. server_socket_path
  return command
end

local function set_server_value_in_redis(server_socket_path)
  command = M.generate_command(server_socket_path)
  if command == nil then
    print("Error generating command, See log for details.")
    return
  end
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


function M:is_running()
  return self.server.running
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
