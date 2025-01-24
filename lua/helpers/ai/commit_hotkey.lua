--[[
-- Helpers: AI Auto Commit Message
--
-- Author: Mark van der Meulen
-- Updated: 2025-01-12
--]]


-- Auto Commit Message
local M = {}

function M.generate_commit_message()
  local api_key = os.getenv 'ANTHROPIC_API_KEY'
  if not api_key then
    vim.api.nvim_echo({ {
      'ANTHROPIC_API_KEY environment variable is not set',
      'ErrorMsg',
    } }, true, {})
    return
  end

  local current_line = vim.api.nvim_get_current_line()
  local diff_win = vim.fn.winnr 'j'
  vim.cmd(diff_win .. 'wincmd w')
  local diff_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')

  local prompt_template = [[
Write a commit message for this git diff.
]] .. current_line .. [[
<Example 1>
Update database connection handling
- Switch to connection pooling
- Add timeout settings
- Log failed connections
</Example 1>
<Example 2>
Fix image upload validation
- Enforce maximum file size of 5MB for uploaded images
- Restrict allowed file types to .jpg, .png, .gif
- Return user-friendly error messages for validation failures
- Implement asynchronous upload processing to improve user experience
- Auto-rotate images based on EXIF data
- Optimize image compression on server to reduce file sizes
- Add client-side preview of uploaded images
- Integrate with 3rd party service for advanced image optimization
- Scan uploaded files for viruses/malware and log failures
- Update API docs to reflect new image upload requirements
</Example 2>
<Example 3>
Fix typo in footer
</Example 3>
Keep messages succinct. If there's a single small change, use a one-line message (like in Example 3). For multiple changes, list the key updates (like in Examples 1 and 2).
Do not start your message with things like "Here is a good commit message for this diff:" -- just get straight to writing the commit message.
Here's the Git diff:
]] .. diff_content

  local request_body = vim.fn.json_encode {
    model = 'claude-3-5-sonnet-20241022',
    max_tokens = 1000,
    system = 'You are a Principal Machine Learning Engineer tasked with generating commit messages. Write with clarity and persuasion. Keep sentences simple. Avoid marketing speak purple prose, hyperbole, and flowery language. Use ordinary words where possible, and technical terms only when needed for precision. Remember: simple writing is persuasive writing.',
    messages = {
      {
        role = 'user',
        content = prompt_template,
      },
    },
  }

  local curl_command = string.format(
    "curl -s -X POST 'https://api.anthropic.com/v1/messages' "
      .. "-H 'x-api-key: %s' "
      .. "-H 'anthropic-version: 2023-06-01' "
      .. "-H 'Content-Type: application/json' "
      .. "-d '%s'",
    api_key,
    request_body:gsub("'", "'\\''")
  )

  -- Write request to debug file
  local debug_file = io.open('/tmp/nvim_commit_debug.json', 'w')
  if debug_file then
    debug_file:write 'REQUEST:\n'
    debug_file:write(request_body)
    debug_file:write '\n\nRESPONSE:\n'
  end

  local handle = io.popen(curl_command)
  local response = handle:read '*a'
  handle:close()

  -- Append response to debug file
  if debug_file then
    debug_file:write(response)
    debug_file:close()
  end

  if response == '' then
    vim.api.nvim_echo({ { 'API call failed', 'ErrorMsg' } }, true, {})
    return
  end

  local ok, parsed_response = pcall(vim.fn.json_decode, response)
  if not ok then
    vim.api.nvim_echo({ { 'Failed to parse API response', 'ErrorMsg' } }, true, {})
    vim.api.nvim_echo({ { 'Raw response: ' .. response, 'Normal' } }, true, {})
    return
  end

  if not parsed_response.content or #parsed_response.content == 0 then
    vim.api.nvim_echo({ { 'Unexpected API response structure', 'ErrorMsg' } }, true, {})
    return
  end

  local content_block = parsed_response.content[1]
  if not content_block.type == 'text' or not content_block.text then
    vim.api.nvim_echo({ { 'Unexpected API response structure', 'ErrorMsg' } }, true, {})
    return
  end

  local commit_message = content_block.text
  local commit_win = vim.fn.winnr 'k'
  vim.cmd(commit_win .. 'wincmd w')

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor_pos[1] - 1, cursor_pos[2]
  vim.api.nvim_buf_set_text(0, row, col, row, col, vim.split(commit_message, '\n'))
end

if not _G.myplugin then
  _G.myplugin = {}
end
_G.myplugin.generate_commit_message = M.generate_commit_message

vim.api.nvim_set_keymap('n', '<leader>gai', ':lua _G.myplugin.generate_commit_message()<CR>', {
  noremap = true,
  silent = false,
})
