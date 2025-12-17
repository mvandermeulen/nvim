local M = {}

-- Templates for log files
local templates = {
  default = {
    header = [[
# Log Entry
Date: %s
Category: %s
Author: %s
--------------------

]],
    footer = [[

--------------------
End of log entry
Generated via Neovim
]],
  },
  meeting = {
    header = [[
# Meeting Notes
Date: %s
Category: %s
Attendees: 
- 
--------------------

Agenda:
1. 

Notes:

]],
    footer = [[

--------------------
Action Items:
- 

Next Steps:
- 
]],
  },
  debug = {
    header = [[
# Debug Log
Date: %s
Category: %s
System: %s
--------------------

Environment:
- OS: 
- Version: 
- Dependencies:

Issue Description:

Steps to Reproduce:
1. 

]],
    footer = [[

--------------------
Resolution:

Follow-up:
- 
]],
  },
}

-- Helper function to check if a directory exists
local function dir_exists(path)
  local ok, err, code = os.rename(path, path)
  if not ok then
    if code == 13 then -- Permission denied
      return true
    end
  end
  return ok
end

-- Helper function to check if a file exists
local function file_exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

-- Function to create a new log file
function M.create_new_log()
  -- Configuration
  local log_dir = os.getenv("HOME") .. "/code/neovim/logs"
  local default_author = vim.env.USER or "Unknown"

  -- Get category
  local category = vim.fn.input({
    prompt = "Category (debug/meeting/default): ",
    default = "default",
  })
  if category == "" then
    return
  end

  -- Get template based on category
  local template = templates[category] or templates.default

  -- Get custom filename or use timestamp
  local use_timestamp = vim.fn.confirm("Use timestamp as filename?", "&Yes\n&No") == 1
  local timestamp = os.date("%Y%m%d_%H%M%S")
  local filename

  if use_timestamp then
    filename = string.format("log_%s_%s.md", category, timestamp)
  else
    local custom_name = vim.fn.input("Enter filename (without extension): ")
    if custom_name == "" then
      return
    end
    filename = string.format("%s_%s.md", custom_name, category)
  end

  -- Create full file path
  local category_dir = string.format("%s/%s", log_dir, category)
  local filepath = string.format("%s/%s/%s", log_dir, category, filename)

  -- Debug information
  vim.notify(
    string.format("Attempting to create:\nDirectory: %s\nFile: %s", category_dir, filepath),
    vim.log.levels.INFO
  )

  vim.notify(string.format("Created! Mallick - %s", filepath), vim.log.levels.INFO)
  -- Create the category directory if it doesn't exist
  local mkdir_cmd = string.format("mkdir -p %s/%s", log_dir, category)
  local mkdir_result = vim.fn.system(mkdir_cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify(
      string.format("Failed to create directory: %s\nError: %s", category_dir, mkdir_result),
      vim.log.levels.ERROR
    )
    return
  end

  -- Check directory permissions
  if not dir_exists(category_dir) then
    vim.notify(string.format("Directory was not created or is not accessible: %s", category_dir), vim.log.levels.ERROR)
    return
  end

  -- Check if file already exists
  if file_exists(filepath) then
    local overwrite = vim.fn.confirm("File already exists. Overwrite?", "&Yes\n&No") == 1
    if not overwrite then
      vim.notify("File creation cancelled - file already exists", vim.log.levels.WARN)
      return
    end
  end

  -- Try to create the file
  local file, err = io.open(filepath, "w")
  if not file then
    vim.notify(string.format("Failed to create file: %s\nError: %s", filepath, err), vim.log.levels.ERROR)
    return
  end

  -- Write header
  local ok, write_err = pcall(function()
    local header = string.format(template.header, os.date("%Y-%m-%d %H:%M:%S"), category, default_author)
    file:write(header)
    file:write(template.footer)
    file:close()
  end)

  if not ok then
    vim.notify(string.format("Failed to write to file: %s\nError: %s", filepath, write_err), vim.log.levels.ERROR)
    return
  end

  -- Verify file was created
  if not file_exists(filepath) then
    vim.notify("File was not created successfully", vim.log.levels.ERROR)
    return
  end

  -- Open the file in Neovim
  local edit_cmd = string.format("edit %s", filepath)
  local ok_edit, edit_err = pcall(vim.cmd, edit_cmd)
  if not ok_edit then
    vim.notify(string.format("Failed to open file in Neovim: %s", edit_err), vim.log.levels.ERROR)
    return
  end

  -- Move cursor to appropriate position
  pcall(function()
    vim.cmd("normal gg")
    vim.cmd("/^--------------------$")
    vim.cmd("normal j")
  end)

  -- Set up autocommand to auto-save
  local augroup_cmd = string.format([[
    augroup LogAutoSave
      autocmd! * <buffer>
      autocmd TextChanged,TextChangedI <buffer> silent write
    augroup END
  ]])
  pcall(vim.cmd, augroup_cmd)

  -- Show success message
  vim.notify(string.format("Successfully created %s log: %s", category, filename), vim.log.levels.INFO)

  -- Create the file
  -- local file = io.open(filepath, "w")
  -- if file then
  --   -- Write header
  --   local header = string.format(template.header, os.date("%Y-%m-%d %H:%M:%S"), category, default_author)
  --   file:write(header)
  --
  --   -- Write footer
  --   file:write(template.footer)
  --   file:close()
  --
  --   -- Open the file in Neovim
  --   vim.cmd("edit " .. filepath)
  --
  --   -- Move cursor to appropriate position (after header, before footer)
  --   vim.cmd("normal gg")
  --   vim.cmd("/^--------------------$")
  --   vim.cmd("normal j")
  --
  --   -- Show a success message with the filepath
  --   vim.notify(string.format("Created new %s log: %s", category, filename), vim.log.levels.INFO)
  --
  --   -- Optional: Set up autocommand to auto-save
  --   vim.cmd(string.format([[
  --     augroup LogAutoSave
  --       autocmd! * <buffer>
  --       autocmd TextChanged,TextChangedI <buffer> silent write
  --     augroup END
  --   ]]))
  -- else
  --   vim.notify("Failed to create log file!", vim.log.levels.ERROR)
  -- end
end

-- Quick category-specific log creators
function M.create_meeting_log()
  vim.schedule(function()
    vim.fn.feedkeys("nl", "n")
    vim.fn.feedkeys("meeting\n")
    vim.fn.feedkeys("y") -- Use timestamp
  end)
end

function M.create_debug_log()
  vim.schedule(function()
    vim.fn.feedkeys("nl", "n")
    vim.fn.feedkeys("debug\n")
    vim.fn.feedkeys("y") -- Use timestamp
  end)
end

return M
