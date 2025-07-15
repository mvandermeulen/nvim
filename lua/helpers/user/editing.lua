--[[
-- Helpers: Editing
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-15
--]]


local M = {}


function M.insert_todo_and_comment()
  -- Insert the TODO text at the current cursor position
  local line = vim.api.nvim_get_current_line()
  print("Original line: ", line)
  vim.api.nvim_put({ "TODO:(mvandermeulen)" }, "", true, true)
  vim.cmd [[execute "normal gcc"]]
end


function M.record_was_doing()
  local doing = vim.ui.input("What were you doing? ")
  vim.cmd("Was " .. doing)
end


function M.insert_date()
  local date = os.date('%Y-%m-%d') --[[@ as string]]
  vim.api.nvim_feedkeys(date, 'n', false)
end


function M.insert_time()
  local time = os.date('%H:%M:%S') --[[@ as string]]
  vim.api.nvim_feedkeys(time, 'n', false)
end


function M.EscapePair()
  local closers = { ")", "]", "}", ">", "'", '"', "`", "," }
  local line = vim.api.nvim_get_current_line()
  local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  local after = line:sub(col + 1, -1)
  local closer_col = #after + 1
  local closer_i = nil
  for i, closer in ipairs(closers) do
    local cur_index, _ = after:find(closer)
    if cur_index and (cur_index < closer_col) then
      closer_col = cur_index
      closer_i = i
    end
  end
  if closer_i then
    vim.api.nvim_win_set_cursor(0, { row, col + closer_col })
  else
    vim.api.nvim_win_set_cursor(0, { row, col + 1 })
  end
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


-- get length of current word
function M.get_word_length()
    local word = vim.fn.expand "<cword>"
    return #word
end


-- Helper function to get total line count of a file
function M.get_unopened_file_line_count(file_path)
  local file = io.open(file_path, 'r')
  if not file then
    return 0
  end
  local line_count = 0
  for _ in file:lines() do
    line_count = line_count + 1
  end
  file:close()
  return line_count
end


-- Add snippet functions (normal and visual mode)
function M.add_snippet_normal()
  local line_num = vim.fn.line '.'
  local code = vim.api.nvim_get_current_line()
  local current_file = vim.fn.expand '%:p'
  local total_lines = M.get_unopened_file_line_count(current_file)
  local snippet = {
    directory = current_file,
    stat = vim.fn.system('stat ' .. current_file):gsub('\n', ' '),
    code = code,
    start_line = line_num,
    end_line = line_num,
    total_lines = total_lines,
  }
  table.insert(snippet_buffer, snippet)
end


function M.add_snippet_visual()
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  local start_line, end_line = start_pos[2], end_pos[2]
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local code = table.concat(lines, '\n')
  local current_file = vim.fn.expand '%:p'
  local total_lines = M.get_unopened_file_line_count(current_file)
  local snippet = {
    directory = current_file,
    stat = vim.fn.system('stat ' .. current_file):gsub('\n', ' '),
    code = code,
    start_line = start_line,
    end_line = end_line,
    total_lines = total_lines,
  }
  table.insert(snippet_buffer, snippet)
end


-- Function to generate file tree
function M.generate_file_tree()
  local root_dir = vim.fn.getcwd()
  local tree = {}

  for _, snippet in ipairs(snippet_buffer) do
    local path = vim.fn.fnamemodify(snippet.directory, ':~:.')
    local parts = vim.split(path, '/')
    local current = tree
    for i, part in ipairs(parts) do
      if i == #parts then
        current[part] = true -- Mark as file
      else
        current[part] = current[part] or {}
        current = current[part]
      end
    end
  end

  local function render_tree(node, prefix, is_last)
    local lines = {}
    local keys = vim.tbl_keys(node)
    table.sort(keys)

    for i, key in ipairs(keys) do
      local is_last_item = (i == #keys)
      local new_prefix = prefix .. (is_last and '    ' or '│   ')
      local line = prefix .. (is_last_item and '└── ' or '├── ') .. key

      table.insert(lines, line)

      if type(node[key]) == 'table' then
        local subtree = render_tree(node[key], new_prefix, is_last_item)
        vim.list_extend(lines, subtree)
      end
    end

    return lines
  end

  return render_tree(tree, '', true)
end


-- View snippets function
function M.view_snippets()
  if #snippet_buffer == 0 then
    print 'No snippets in buffer.'
    return
  end

  vim.cmd 'vnew'
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)

  local content = {}
  local file_tree = generate_file_tree()

  -- Add file tree to content
  table.insert(content, 'File Tree:')
  table.insert(content, '../')
  vim.list_extend(content, file_tree)
  table.insert(content, string.rep('-', 40))
  table.insert(content, '')

  -- Add snippets to content with line numbers and total line count
  for i, snippet in ipairs(snippet_buffer) do
    table.insert(content, 'Snippet ' .. i .. ':')
    table.insert(content, 'Directory: ' .. snippet.directory)
    table.insert(content, 'Stat: ' .. snippet.stat)
    table.insert(content, string.format('Total lines in file: %d', snippet.total_lines))
    table.insert(content, 'Code:')

    -- Split the code into lines and add line numbers
    local lines = vim.split(snippet.code, '\n')
    local current_line = snippet.start_line

    for _, line in ipairs(lines) do
      table.insert(content, string.format('%6d | %s', current_line, line))
      current_line = current_line + 1
    end

    table.insert(content, '')
    table.insert(content, string.rep('-', 40))
    table.insert(content, '')
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  print('Displaying ' .. #snippet_buffer .. ' snippets.')
end


-- Clear snippets function
function M.clear_snippets()
  local count = #snippet_buffer
  snippet_buffer = {}
  print('Snippet buffer cleared. Removed ' .. count .. ' snippets.')
end


-- Load the output of the last command into the register "o"
-- if it was executed with | tee /tmp/output.log
function M.load_output_to_register(file_path, register)
  local file_path = file_path or vim.env.HOME .. "/.cache/nvim/output.log"
  local register = register or "o"
  local file = io.open(file_path, "r")
  if file then
    local content = file:read("*all")
    file:close()
    vim.fn.setreg(register, content)
  else
    print("Failed to open file: " .. file_path)
  end
end



return M
