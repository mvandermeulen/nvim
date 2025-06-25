--[[
-- Helpers: Shell
--
-- Author: Mark van der Meulen
-- Updated: 2025-06-17
--]]

local _name = 'Shell'
local _log = require('plenary.log').new({ plugin = _name, level = 'debug', use_console = true })
local function mlog(msg, level)
  local level = level or 'debug'
  if level == 'error' then
    vim.api.nvim_err_writeln(msg)
    _log.error(msg)
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


local TMUXKeys = {
  enter = "Enter",
}

local function tslime_to_target_pane()
  return vim.g.tslime.session .. ":" .. vim.g.tslime.window .. "." .. vim.g.tslime.pane
end

local tmux_directions = { h = "L", j = "D", k = "U", l = "R" }
local tmux_swap_directions = { h = "left", j = "down", k = "up", l = "right" }

local function get_tmux()
    return os.getenv("TMUX")
end

local function get_tmux_pane()
    return os.getenv("TMUX_PANE")
end

local function get_socket()
    return vim.split(get_tmux(), ",")[1]
end

local M = {
    is_tmux = false,
}

function M.execute(arg, pre)
    local command = string.format("%s tmux -S %s %s", pre or "", get_socket(), arg)

    local handle = assert(io.popen(command), string.format("unable to M.execute: [%s]", command))
    local result = handle:read("*a")
    handle:close()

    return result
end

local function get_version()
    local result = M.execute("-V")
    local version = result:sub(result:find(" ") + 1)

    return version:gsub("[^%.%w]", "")
end

function M.setup()
    M.is_tmux = get_tmux() ~= nil

    mlog(M.is_tmux, 'debug')
    if not M.is_tmux then
        return false
    end

    M.version = get_version()
    log.debug(M.version)
    return true
end

function M.change_pane(direction)
    M.execute(string.format("select-pane -t '%s' -%s", get_tmux_pane(), tmux_directions[direction]))
    -- vim.o.laststatus = vim.o.laststatus -- reset statusline as it sometimes disappear (#105)
end

function M.window_index()
    return M.execute("display-message -p '#{window_index}'")
end

function M.base_index()
    return M.execute("display-message -p '#{base-index}'")
end

function M.window_end_flag()
    return M.execute("display-message -p '#{window_end_flag}'") == "0"
end

function M.window_start_flag()
    return M.window_index() == M.base_index()
end

function M.select_window(direction)
    M.execute(string.format("select-window -%s", direction))
    -- vim.o.laststatus = vim.o.laststatus -- reset statusline as it sometimes disappear (#105)
end

function M.get_buffer(name)
    return M.execute(string.format("show-buffer -b %s", name))
end

function M.get_buffer_names()
    local buffers = M.execute([[ list-buffers -F "#{buffer_name}" ]])

    local result = {}
    for line in buffers:gmatch("([^\n]+)\n?") do
        table.insert(result, line)
    end

    return result
end

function M.get_current_pane_id()
    local pane = get_tmux_pane()
    return pane and tonumber(pane:sub(2)) or nil
end

function M.get_window_layout()
    return M.execute("display-message -p '#{window_layout}'")
end

function M.is_zoomed()
    return M.execute("display-message -p '#{window_zoomed_flag}'"):find("1")
end

function M.resize(direction, step)
    M.execute(string.format("resize-pane -t '%s' -%s %d", get_tmux_pane(), tmux_directions[direction], step))
end

function M.swap(direction)
    M.execute(string.format("swap-pane -t '%s' -s '{%s-of}'", get_tmux_pane(), tmux_swap_directions[direction]))
end

function M.set_buffer(content, sync_clipboard)
    content = content:gsub("\\", "\\\\")
    content = content:gsub('"', '\\"')
    content = content:gsub("`", "\\`")
    content = content:gsub("%$", "\\$")

    if sync_clipboard ~= nil and sync_clipboard then
        M.execute("load-buffer -w -", string.format('printf "%%s" "%s" | ', content))
    else
        M.execute("load-buffer -", string.format('printf "%%s" "%s" | ', content))
    end
end

---Get stringified result of sh command
---@param cmd string[] command to run
---@param cwd? string current working directory
---@return string[] stdout
---@return number command status
---@return string[] stderr
local function get_os_command_output(cmd, cwd)
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

local function tmux_get_panes()
  local cmd = {
    "tmux",
    "list-panes",
    "-F",
    "#{session_name},#{window_index},#{pane_index},#{pane_bottom},#{pane_left},${pane_title},#{pane_current_command}",
  }
  local panes_raw = get_os_command_output(cmd)
  local panes = vim.tbl_map(function(e)
    local opts = vim.split(e, ",", {})
    return {
      session = opts[1],
      window = opts[2],
      pane = opts[3],
      bottom = opts[4],
      left = opts[5],
      title = opts[6],
      current_cmd = opts[7],
    }
  end, panes_raw)
  return panes
end

function M.tslime_select_target_pane()
  -- List of tmux 'named variables'  (#{...})
  -- https://gist.github.com/genki/22cace67e4fc7441222a06facee12b2e
  local cmd = {
    "tmux",
    "list-panes",
    "-F",
    "#{pane_index} - #{pane_title}",
  }

  local panes = get_os_command_output(cmd)
  if #panes == 2 then
    M.tslime_auto_select_bottom_pane()
    return
  end

  vim.ui.select(panes, {
    prompt = "Select tmux pane> ",
  }, function(_, i)
    vim.g.tslime = tmux_get_panes()[i]
  end)
end

function M.tslime_auto_select_bottom_pane()
  local panes = tmux_get_panes()
  table.sort(panes, function(left, right)
    if left["bottom"] == right["bottom"] then
      return left["left"] < right["left"]
    else
      return left["bottom"] > right["bottom"]
    end
  end)

  if #panes == 0 then
    -- not in tmux
    return
  end

  local pane = panes[1]

  if pane["current_cmd"] == "zsh" then
    -- log.debug("Tslime - auto set pane to", pane)
    vim.g.tslime = pane
  end
end

function M.get_current_window()
  local cmd = { "tmux", "display-message", "-p", "#W" }
  local res = get_os_command_output(cmd)
  if #res >= 1 then
    return { name = res[1] }
  else
    return { name = nil }
  end
end

---------- Experiment: custom run in pane ----------
--

--- Run a bash command in tmux pane
---
--@param cmd table:
--        @key cmd[]: command list to execute

---Run os command in tmux pane
---@param cmd string[]
---@return nil
function M.run_in_pane(cmd)
  if not vim.g.tslime then
    M.tslime_auto_select_bottom_pane()
  end

  local target_pane = tslime_to_target_pane()
  local args = { "send-keys", "-t", target_pane, table.concat(cmd, " "), TMUXKeys.enter }

  local handle
  handle, _ = vim.loop.spawn("tmux", { args = args }, function(code)
    handle:close()
    if code ~= 0 then
      vim.notify(
        string.format("Terminal exited %d running %s %s", code, "tmux", table.concat(args, " ")),
        vim.log.levels.ERROR
      )
    end
  end)

  return handle
end

function M.get_tmux_working_directory()
  -- local handle = io.popen "tmux display-message -p -F '#{session_path}'"
  local handle = io.popen "tmux display-message -p -F '#{pane_path}'"
  if handle then
    local result = handle:read "*l"
    handle:close()
    if result and result ~= "" then
      return result
    else
      print "No result obtained or result is empty"
    end
  else
    print "Failed to create handle"
  end
end

function M.attach_session(session_name)
  local tmux_session_check = M.execute("has-session -t=" .. session_name .. " 2> /dev/null")
  if tmux_session_check == 0 then
    M.execute("switch-client -t " .. session_name)
  end
end

function M.is_running()
  local tmux_running = os.execute("pgrep tmux > /dev/null")
  local in_tmux = vim.fn.exists('$TMUX') == 1
  if tmux_running == 0 and in_tmux then
    return true
  end
  return false
end

function M.last_session()
  M.execute("switch-client -l")
end









-- Trigger ranger in neovim inside a tmux popup
-- Current file path will be the main path
-- PROJECT: ranger-tmux-setup
function M.ranger_popup_in_tmux()
  -- Get the directory of the current file in Neovim
  local current_file = vim.fn.expand "%:p:h"
  -- Formulate the tmux command with either the file directory or the pane's current path
  local tmux_command = "tmux popup -d '" .. current_file .. "' -E -h 95% -w 95% -x 100% 'ranger'"
  -- Execute the tmux command
  os.execute(tmux_command)
end

function M.add_empty_lines(opts)
  opts = opts or {}
  local count = vim.v.count1
  local lines = {}
  for _ = 1, count do
    table.insert(lines, "")
  end
  local current_line = vim.fn.line "."

  if opts.below then
    vim.fn.append(current_line, lines)
    vim.api.nvim_win_set_cursor(0, { current_line + count, 0 })
  else
    vim.fn.append(current_line - 1, lines)
    vim.api.nvim_win_set_cursor(0, { current_line, 0 })
  end

  if opts.insert then
    vim.cmd "startinsert"
  end
end

function M.execute_file_and_show_output()
  -- Define the command based on filetype
  local cmd
  if vim.bo.filetype == "fsharp" then
    cmd = "dotnet run " .. vim.fn.expand "%:p" -- for F# files, use dotnet run
  else
    cmd = "bash " .. vim.fn.expand "%:p" -- for other files, use bash
  end

  -- Execute the command and capture its output
  local output = vim.fn.systemlist(cmd)

  -- Check for execution error
  if vim.v.shell_error ~= 0 then
    table.insert(output, 1, "Error executing file:")
  end

  -- Call the function to create a floating scratch buffer with the output
  require("user_functions.utils").create_floating_scratch(output)
end

function M.interrupt_process()
  if _G.job_id then
    vim.fn.jobstop(_G.job_id)
    _G.job_id = nil -- Clear the job ID after stopping the job
    print "Process interrupted."
  end
end

function M.execute_visual_selection()
  vim.cmd "normal! gvy"
  local lines = vim.fn.getreg '"'

  -- Create a temporary script file
  local script_path = "/tmp/nvim_exec_script.sh"
  local script_file = io.open(script_path, "w")
  script_file:write(lines)
  script_file:close()

  local command = "bash " .. script_path
  require("user_functions.utils").create_floating_scratch(nil)

  local bufs = vim.api.nvim_list_bufs()
  local target_buf = bufs[#bufs]

  _G.job_id = vim.fn.jobstart(command, {
    on_stdout = function(_, data)
      if data then
        vim.api.nvim_buf_set_lines(target_buf, -1, -1, false, data)
        local win_ids = vim.fn.win_findbuf(target_buf)
        for _, win_id in ipairs(win_ids) do
          vim.api.nvim_win_set_cursor(win_id, { vim.api.nvim_buf_line_count(target_buf), 0 })
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.api.nvim_buf_set_lines(target_buf, -1, -1, false, data)
        local win_ids = vim.fn.win_findbuf(target_buf)
        for _, win_id in ipairs(win_ids) do
          vim.api.nvim_win_set_cursor(win_id, { vim.api.nvim_buf_line_count(target_buf), 0 })
        end
      end
    end,
    stdout_buffered = false,
    stderr_buffered = false,
  })

  vim.api.nvim_buf_set_keymap(
    target_buf,
    "n",
    "<C-c>",
    "<cmd>lua require('user_functions.shell_integration').interrupt_process()<CR>",
    { noremap = true, silent = true }
  )
end

return M
