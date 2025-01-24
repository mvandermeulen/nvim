-- Helper function to get total line count of a file
local function get_file_line_count(file_path)
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
_G.add_snippet_normal = function()
  local line_num = vim.fn.line '.'
  local code = vim.api.nvim_get_current_line()
  local current_file = vim.fn.expand '%:p'
  local total_lines = get_file_line_count(current_file)
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

_G.add_snippet_visual = function()
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  local start_line, end_line = start_pos[2], end_pos[2]
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local code = table.concat(lines, '\n')
  local current_file = vim.fn.expand '%:p'
  local total_lines = get_file_line_count(current_file)
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
local function generate_file_tree()
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
_G.view_snippets = function()
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
_G.clear_snippets = function()
  local count = #snippet_buffer
  snippet_buffer = {}
  print('Snippet buffer cleared. Removed ' .. count .. ' snippets.')
end

-- Set up keymaps
vim.api.nvim_set_keymap('n', '<leader>we', ':lua add_snippet_normal()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>we', ':<C-U>lua add_snippet_visual()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>wr', ':lua view_snippets()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>wq', ':lua clear_snippets()<CR>', { noremap = true, silent = true })
