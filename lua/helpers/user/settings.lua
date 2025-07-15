--[[
-- Helper: User Settings
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-15
--]]

local M = {
  settings = {
    auto_resize_splits = true, -- Automatically resize splits when window got resized
  },
}


local a = vim.api
local vedit_default
local vt_bak
local diagnostics_active = true

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

function M.toggle_lazy_redraw()
  if vim.o.lazyredraw then
    vim.opt.lazyredraw = false
    vim.notify('Lazy Redraw: Off')
  else
    vim.opt.lazyredraw = true
    vim.notify('Lazy Redraw: On')
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

function M.toggle_option(option)
    local value = not vim.api.nvim_get_option_value(option, {})
    vim.opt[option] = value
    vim.notify(option .. " set to " .. tostring(value))
end

function M.toggle_tabline()
    local value = vim.api.nvim_get_option_value("showtabline", {})

    if value == 2 then
        value = 0
    else
        value = 2
    end

    vim.opt.showtabline = value

    vim.notify("showtabline" .. " set to " .. tostring(value))
end

function M.toggle_diagnostics()
    diagnostics_active = not diagnostics_active
    if diagnostics_active then
        vim.diagnostic.show()
    else
        vim.diagnostic.hide()
    end
end


M.my_toggle_line_numbers = function()
  if vim.o.number == true then
    vim.o.number = false
    vim.o.relativenumber = false
  else
    vim.o.number = true
    vim.o.relativenumber = true
  end
end

M.my_fold_mapping = function()
  local openers = { ['('] = ')', ['['] = ']', ['{'] = '}', ['<'] = '>' }
  local closers = { [')'] = '(', [']'] = '[', ['}'] = '{', ['>'] = '<' }
  local current_line_number = vim.fn.line('.')
  local current_line = vim.fn.getline(current_line_number)
  local foldmethod = vim.wo.foldmethod
  -- Check that exist specific symbols on current line
  local current_char = string.match(current_line, '[%(%)%[%]%{%}<>]')

  if foldmethod == 'indent' then
      vim.cmd("normal! za")
  else
    if current_char then
      if openers[current_char] then
        local find_opener = true
        vim.cmd("normal! zfa" .. current_char)
      elseif closers[current_char] then
        local find_opener = false
        vim.cmd("normal! zfa" .. closers[current_char])
      end
      return -- nothing to do
    end

    -- find for the nearest closing/opening brackets
    local bracket = nil
    local bracket_line_number = nil
    for line_number = current_line_number - 1, 1, -1 do
      local line = vim.fn.getline(line_number)
      bracket = string.match(line, '[>%)%]%}<%(%[%{]')
      if bracket then
        bracket_line_number = line_number
        break
      end
    end

    if not bracket then
      --vim.cmd('echo "not found bracket"')
      return
    end

    -- Search opener or closer bracket
    if openers[bracket] then
      local closer = openers[bracket]
      local stack = 0
      local start_line = bracket_line_number
      local end_line = vim.fn.line('$')
      local step = 1
      for line_number = start_line, end_line, step do
        local line = vim.fn.getline(line_number)
          for char in string.gmatch(line, '.') do
          if char == bracket then
            stack = stack + 1
          elseif char == closer then
            stack = stack - 1
            if stack == 0 then
              vim.fn.cursor(line_number, 1)
              vim.cmd("normal! zf" .. bracket_line_number .. "gg")
              return
            end
          end
        end
      end
    elseif closers[bracket] then
      local opener = closers[bracket]
      local stack = 1
      local start_line = bracket_line_number - 1
      local end_line = 1
      local step = -1
      for line_number = start_line, end_line, step do
        local line = vim.fn.getline(line_number)
        for char in string.gmatch(line, '.') do
          if char == bracket then
            stack = stack + 1
          elseif char == opener then
            stack = stack - 1
            if stack == 0 then
              vim.fn.cursor(line_number, 1)
              vim.cmd("normal! zf" .. bracket_line_number .. "G")
              return
            end
          end
        end
      end
    end
  end
end

M.my_toggle_paste_mode = function()
    if vim.opt.paste:get() then
        vim.opt.paste = false
        print("NO paste mode")
    else
        vim.opt.paste = true
        print("paste mode ON")
    end
end

M.my_toggle_wrap_mode = function()
    if vim.opt.wrap:get() then
        vim.opt.wrap = false
    else
        vim.opt.wrap = true
    end
end

M.my_list_chars_mode = function()
    if vim.opt.list:get() then
        vim.opt.list = false
    else
        vim.opt.list = true
    end
end

M.vcut_to_q = function()
    local vmapx_reg = vim.fn.getreg('"')  -- save current register ""
    vim.cmd('normal! gv"qx')  -- save cut to register "q
    vim.fn.setreg('"', vmapx_reg) -- restore register ""
end

M.vcut_to_qq = function()
    local vmapx_reg = vim.fn.getreg('"')
    vim.cmd('normal! gv"qX')  -- save cut to register "q
    vim.fn.setreg('"', vmapx_reg)
end

M.vcut_to_w = function()
    local vmapc_reg = vim.fn.getreg('"')  -- save current register ""
    vim.cmd('normal! gv"wc')  -- save cut to register "w
    vim.fn.setreg('"', vmapc_reg) -- restore register ""
    vim.cmd('startinsert')
end

M.vcut_to_ww = function()
    local vmapc_reg = vim.fn.getreg('"')
    vim.cmd('normal! gv"wC')  -- save cut to register "w
    vim.fn.setreg('"', vmapc_reg)
    vim.cmd('startinsert')
end

M.ccut_to_w = function()
    local nmapc_reg = vim.fn.getreg('"')
    vim.cmd('normal! "wciw')  -- save cut to register "w
    vim.fn.setreg('"', nmapc_reg) 
    vim.cmd('startinsert')
end

M.ccut_to_ww = function()
    local nmapc_reg = vim.fn.getreg('"')
    vim.cmd('normal! "wciW')  -- save cut to register "w
    vim.fn.setreg('"', nmapc_reg)
    vim.cmd('startinsert')
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
