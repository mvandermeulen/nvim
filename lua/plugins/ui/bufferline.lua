--[[
-- Bufferline Plugin Configuration
--
-- Author: Mark van der Meulen
-- Updated: 09-05-2022
--]]

local status_ok, bufferline = pcall(require, 'bufferline')
if not status_ok then
  return
end

local icons = require('helpers.ui.icons')

local function diagnostic_count(severity)
  return function()
    local result = vim.lsp.diagnostic.get_count(0, severity)
    return result == 0 and '' or result
  end
end

local function diagnostic_indicator(count, level)
  local icon = level:match 'error' and icons.ui.Error or icons.ui.Warning
  return ' ' .. icon .. count
end


local function buffer_filter(bufno)
  -- filter out filetypes you don't want to see
  if vim.bo[bufno].filetype ~= '<i-dont-want-to-see-this>' then
    return true
  end
  -- filter out by buffer name
  if vim.fn.bufname(bufno) ~= 'No Name' then
    return true
  end
  -- filter out based on arbitrary rules
  -- e.g. filter out vim wiki buffer from tabline in your work repo
  if vim.fn.getcwd() == '<work-repo>' and vim.bo[bufno].filetype ~= 'wiki' then
    return true
  end
end

bufferline.setup {
  options = {
    -- mode = 'tabs',
    numbers = function(opts)
      return string.format('%s', opts.raise(opts.id)) -- :h bufferline-numbers
    end,
    indicator = {
      icon = ' ',
      style = 'icon',
    },
    hover = {
      enabled = true,
      delay = 200,
      reveal = {'close'}
    },
    close_command = 'Bdelete! %d', -- can be a string | function, see "Mouse actions"
    right_mouse_command = 'Bdelete! %d', -- can be a string | function, see "Mouse actions"
    left_mouse_command = 'buffer %d', -- can be a string | function, see "Mouse actions"
    middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
    buffer_close_icon = icons.ui.Close_alt,
    modified_icon = icons.ui.Pencil,
    close_icon = icons.ui.Close,
    left_trunc_marker = '',
    right_trunc_marker = '',
    max_name_length = 30,
    max_prefix_length = 30, -- prefix used when a buffer is de-duplicated
    tab_size = 20,
    diagnostics = false, -- | "nvim_lsp" | "coc",
    diagnostics_update_in_insert = false,
    --		diagnostics = "nvim_lsp",
    diagnostics_indicator = function(count, level)
      return diagnostic_indicator(count, level)
    end,
    -- NOTE: this will be called a lot so don't do any heavy processing here
    custom_filter = function(buf_number)
      return buffer_filter(buf_number)
    end,
    offsets = {
      {
        filetype = 'neo-tree',
        text = ' File Explorer',
        highlight = 'Directory',
        text_align = 'left',
        padding = 0,
      },
      {
        filetype = 'NvimTree',
        text = ' File Explorer',
        highlight = 'Directory',
        text_align = 'left',
        padding = 0,
      },
      {
        filetype = 'Outline',
        text = '   Symbols ',
        text_align = 'center',
        highlight = 'Directory',
        padding = 0,
      },
    },
    show_buffer_icons = true, -- disable filetype icons for buffers
    show_buffer_close_icons = true,
    show_close_icon = true,
    show_tab_indicators = true,
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
    -- can also be a table containing 2 custom separators
    -- [focused and unfocused]. eg: { '|', '|' }
    separator_style = 'thin',
    enforce_regular_tabs = false,
    always_show_bufferline = true,
    sort_by = 'id',
  },
}
