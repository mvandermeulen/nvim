--[[
-- Commands: Copy
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-25
--]]

local Path = require('helpers.utils.path')

local function copy_to_clipboard(content, message)
  vim.fn.setreg('+', content)
  -- vim.notify('Copied "' .. content .. '" to the clipboard!', vim.log.levels.INFO)
  vim.notify(message, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('CopyFileRelativePath', function()
  local path = vim.fn.expand('%')
  copy_to_clipboard(path, 'Copied "' .. path .. '" to the clipboard!')
end, {})

vim.api.nvim_create_user_command('CopyRelativePath', function()
  local path = Path:new(vim.fn.expand('%')):parent()
  copy_to_clipboard(path, 'Copied "' .. path .. '" to the clipboard!')
end, {})

vim.api.nvim_create_user_command('CopyFileAbsolutePath', function()
  local path = vim.fn.expand('%:p')
  copy_to_clipboard(path, 'Copied "' .. path .. '" to the clipboard!')
end, {})

vim.api.nvim_create_user_command('CopyAbsolutePath', function()
  local path = Path:new(vim.fn.expand('%:p')):parent()
  copy_to_clipboard(path, 'Copied "' .. path .. '" to the clipboard!')
end, {})

vim.api.nvim_create_user_command('CopyFileRelativePathWithLine', function()
  local path = vim.fn.expand('%')
  local line = vim.fn.line('.')
  local result = path .. ':' .. line
  copy_to_clipboard(result, 'Copied "' .. result .. '" to the clipboard!')
end, {})

vim.api.nvim_create_user_command('CopyFileAbsolutePathWithLine', function()
  local path = vim.fn.expand('%:p')
  local line = vim.fn.line('.')
  local result = path .. ':' .. line
  copy_to_clipboard(result, 'Copied "' .. result .. '" to the clipboard!')
end, {})

vim.api.nvim_create_user_command('CopyFileName', function()
  local path = vim.fn.expand('%:t')
  copy_to_clipboard(path, 'Copied "' .. path .. '" to the clipboard!')
end, {})

