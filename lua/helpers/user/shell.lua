--[[
-- Helpers: Shell
--
-- Author: Mark van der Meulen
-- Updated: 2024-09-22
--]]


local M = {}

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
