local M = {}

M.setup = function()
  local lualine = require "lualine"

  -- Color table for highlights
  local colors = {
    blue = "#51afef",
    blue_text = "#0F4880",
    cyan = "#79dac8",
    cyan_text = "#008080",
    black = "#080808",
    white = "#c6c6c6",
    red = "#ff5189",
    violet = "#d183e8",
    grey = "#303030",
    bg = "#202328",
    fg = "#bbc2cf",
    yellow = "#ECBE7B",
    darkblue = "#081633",
    green = "#98be65",
    orange = "#FF8800",
    magenta = "#c678dd",
    -- cyan     = '#008080',
    -- violet   = '#a9a1e1',
    -- blue     = '#51afef',
    -- red      = '#ec5f67',
  }

  local conditions = {
    buffer_not_empty = function()
      return vim.fn.empty(vim.fn.expand "%:t") ~= 1
    end,
    hide_in_width = function()
      return vim.fn.winwidth(0) > 80
    end,
    check_git_workspace = function()
      local filepath = vim.fn.expand "%:p:h"
      local gitdir = vim.fn.finddir(".git", filepath .. ";")
      return gitdir and #gitdir > 0 and #gitdir < #filepath
    end,
  }

  -- Config
  local config = {
    options = {
      -- Disable sections and component separators
      -- theme = bubbles_theme,
      component_separators = "",
      section_separators = { left = "", right = "" },
      -- theme = "nightfox",
      -- theme = "auto",
      -- theme = "tokyonight",
      globalstatus = true,
    },
    sections = {
      -- these are to remove the defaults
      lualine_a = {
        { "mode", separator = { left = "" }, right_padding = 2 },
      },
      lualine_b = {},
      lualine_y = {},
      lualine_z = {
        -- { "location", separator = { right = "" }, left_padding = 2 },
      },
      -- These will be filled later
      lualine_c = {},
      lualine_x = {},
    },
    inactive_sections = {
      -- these are to remove the defaults
      lualine_a = {},
      lualine_v = {},
      lualine_y = {},
      lualine_z = {},
      lualine_c = {},
      lualine_x = {},
    },
  }

  -- Inserts a component in lualine_c at left section
  local function ins_left(component)
    table.insert(config.sections.lualine_c, component)
  end

  -- Inserts a component in lualine_x ot right section
  local function ins_right(component)
    table.insert(config.sections.lualine_x, component)
  end

  ins_left {
    -- filesize component
    "filesize",
    cond = conditions.buffer_not_empty,
  }

  ins_left {
    "filename",
    cond = conditions.buffer_not_empty,
    color = { fg = colors.magenta, gui = "bold" },
  }

  ins_left { "location" }

  ins_left { "FileIcon", cond = conditions.buffer_not_empty }

  ins_left { "progress", color = { fg = colors.fg, gui = "bold" } }

  ins_left {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = { error = " ", warn = " ", info = " " },
    diagnostics_color = {
      color_error = { fg = colors.red },
      color_warn = { fg = colors.yellow },
      color_info = { fg = colors.cyan },
    },
  }

  -- Insert mid section. You can make any number of sections in neovim :)
  -- for lualine it's any number greater then 2
  ins_left {
    function()
      return "%="
    end,
  }

  -- Active LSP
  ins_left {
    function(msg)
      msg = msg or "LS Inactive"
      local buf_clients = vim.lsp.buf_get_clients()
      if next(buf_clients) == nil then
        -- TODO: clean up this if statement
        if type(msg) == "boolean" or #msg == 0 then
          return "LS Inactive"
        end
        return msg
      end
      local buf_client_names = {}

      -- add client
      for _, client in pairs(buf_clients) do
        if client.name ~= "null-ls" then
          table.insert(buf_client_names, client.name)
        end
      end

      return "[" .. table.concat(buf_client_names, ", ") .. "]"
    end,
    color = { gui = "bold" },
    cond = conditions.hide_in_width,
    icon = " LSP:",
  }

  -- Active Formatter
  ins_left {
    function()
      local buf_ft = vim.bo.filetype
      local buf_client_formatter = {}

      -- add formatter

      local formatters = require "user.lsp.utils"
      local supported_formatters = formatters.active_formatter(buf_ft)
      vim.list_extend(buf_client_formatter, supported_formatters)

      if next(buf_client_formatter) == nil then
        return "Not Found"
      end

      return table.concat(buf_client_formatter, ", ")
    end,
    color = { fg = colors.green, gui = "bold" },
    cond = conditions.hide_in_width,
    icon = " Formatting:",
  }

  -- Active Diagnostics
  ins_left {
    function()
      local buf_ft = vim.bo.filetype
      local buf_client_linter = {}

      -- add linter
      local linters = require "user.lsp.utils"
      local supported_linters = linters.active_linter(buf_ft)
      vim.list_extend(buf_client_linter, supported_linters)

      if next(buf_client_linter) == nil then
        return "Not Found"
      end

      return table.concat(buf_client_linter, ", ")
    end,
    color = { fg = colors.blue, gui = "bold" },
    cond = conditions.hide_in_width,
    icon = " Diagnostics:",
  }

  -- ins_left { "filetype" }

  ins_right {
    "o:encoding", -- option component same as &encoding in viml
    fmt = string.upper, -- I'm not sure why it's upper case either ;)
    cond = conditions.hide_in_width,
    color = { fg = colors.green, gui = "bold" },
  }

  ins_right {
    "fileformat",
    fmt = string.upper,
    icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
    color = { fg = colors.green, gui = "bold" },
  }

  ins_right {
    "diff",
    -- Is it me or the symbol for modified us really weird
    symbols = { added = " ", modified = "柳 ", removed = " " },
    diff_color = {
      added = { fg = colors.green },
      modified = { fg = colors.orange },
      removed = { fg = colors.red },
    },
    cond = conditions.hide_in_width,
  }

  ins_right {
    "branch",
    icon = "",
    color = { fg = colors.blue_text, bg = colors.blue, gui = "bold" },
    separator = { right = "" },
    left_padding = 2,
  }

  -- Now don't forget to initialize lualine
  lualine.setup(config)
end

return M
