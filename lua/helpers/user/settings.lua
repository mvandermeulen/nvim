--[[
-- Helper: User Settings
--
-- Author: Mark van der Meulen
-- Updated: 2025-06-05
--]]

local M = {
  settings = {
    auto_resize_splits = true, -- Automatically resize splits when window got resized
  },
}


local vedit_default
local vt_bak

function M.toggle_virtual_edit()
  if not vedit_default then
    vedit_default = vim.o.virtualedit
  end
  if vim.o.virtualedit == vedit_default then
    vim.opt.virtualedit = 'all'
  else
    vim.opt.virtualedit = vedit_default
  end
  vim.notify('virtualedit=' .. vim.o.virtualedit)
end

function M.toggle_virtual_text()
  if not vt_bak then
    vt_bak = vim.diagnostic.config().virtual_text
  end
  if vim.diagnostic.config().virtual_text == vt_bak then
    vim.diagnostic.config({ virtual_text = false })
  else
    vim.diagnostic.config({ virtual_text = vt_bak })
  end
  vim.notify('virtual_text=' .. tostring(vim.diagnostic.config().virtual_text))
end

function M.toggle_word_wrap()
  if vim.o.wrap then
    vim.opt.wrap = false
    vim.notify('Word Wrap: Off')
  else
    vim.opt.wrap = true
    vim.notify('Word Wrap: On')
  end
end

function M.toggle_status_line()
  if vim.o.laststatus == 0 then
    vim.o.laststatus = 3
    vim.notify('Statusline: On')
  else
    vim.o.laststatus = 0
    vim.notify('Statusline: Off')
  end
end

function M.toggle_clipboard()
  if vim.o.clipboard == '' then
    vim.o.clipboard = 'unnamedplus'
    vim.notify('Clipboard: UnnamedPlus')
  else
    vim.o.clipboard = ''
    vim.notify('Clipboard: None')
  end
end

function M:toggle_setting(setting)
  if self.settings[setting] == nil then
    vim.notify('Setting ' .. setting .. ' does not exist.')
    return
  end
  if type(self.settings[setting]) == 'boolean' then
    self.settings[setting] = not self.settings[setting]
    vim.notify(setting .. ': ' .. tostring(self.settings[setting]))
  else
    vim.notify('Setting ' .. setting .. ' is not a boolean.')
  end
end


return M
