--[[
-- Status Line Configuraton
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]

local status_ok, lualine = pcall(require, 'lualine')
if not status_ok then
  return
end

local status_gps_ok, gps = pcall(require, 'nvim-gps')
if not status_gps_ok then
  return
end

local hide_in_width = function()
  return vim.fn.winwidth(0) > 80
end

local icons = require 'helpers.icons'

local diagnostics = {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  sections = { 'error', 'warn' },
  symbols = { error = icons.diagnostics.Error .. ' ', warn = icons.diagnostics.Warning .. ' ' },
  colored = false,
  update_in_insert = false,
  always_visible = true,
}

local diff = {
  'diff',
  colored = true,
  -- symbols = { added = icons.git.Add .. ' ', modified = icons.git.Mod .. ' ', removed = icons.git.Remove .. ' ' }, -- changes diff symbols
  cond = hide_in_width,
}

-- local mode = {
--   'mode',
--   fmt = function(str)
--     return '-- ' .. str .. ' --'
--   end,
-- }
--

local filetype = { 'filetype', icons_enabled = true }
local branch = { 'branch', icons_enabled = true, icon = '' }
local location = { 'location', padding = 0 }

local spaces = function()
  -- return ' ' .. vim.api.nvim_buf_get_option(0, 'shiftwidth')
  return '␉' .. vim.api.nvim_buf_get_option(0, 'shiftwidth')
end

local nvim_gps = function()
  local gps_location = gps.get_location()
  if gps_location == 'error' then
    return ''
  else
    return gps.get_location()
  end
end

vim.opt.laststatus = 3

lualine.setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    -- section_separators = { left = '', right = '' },
    -- section_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    --disabled_filetypes = { "alpha", "dashboard", "toggleterm" },
    always_divide_middle = true,
    globalstatus = true,
  },
  sections = {
    lualine_a = { 'mode' },
    -- lualine_b = { { "b:gitsigns_head", icon = "" }, "diff" },
    lualine_b = { branch, diff },
    --lualine_a = { branch, diagnostics },
    --lualine_a = { branch },
    --lualine_b = { diagnostics },
    -- lualine_c = { _gps },
    lualine_c = {
      {
        'filename',
        file_status = true,
        path = 1, -- show relativ path
        shorting_target = 40,
        symbols = { modified = '[]', readonly = ' ' },
      },
    },
    -- lualine_x = { "encoding", "fileformat", "filetype" },
    -- lualine_x = { diagnostics, spaces, 'encoding', 'fileformat', filetype },
    lualine_x = { spaces, 'fileformat', 'encoding', filetype },
    lualine_y = { { nvim_gps, cond = hide_in_width } },
    lualine_z = { location, diagnostics },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  -- extensions = {},
  extensions = { 'nvim-tree', 'toggleterm', 'quickfix', 'symbols-outline' },
}

--require("lualine").setup({
--	options = {
--		icons_enabled = true,
--		component_separators = { "", "" },
--		section_separators = { "", "" },
--		disabled_filetypes = {},
--		always_divide_middle = true,
--		--theme = 'tokyonight',
--	},
--	sections = {
--		lualine_a = { "mode" },
-- lualine_b = { { "b:gitsigns_head", icon = "" }, "diff" },
--		lualine_c = {
--			{
--				"filename",
--				file_status = true,
--				path = 1, -- show relativ path
--				shorting_target = 40,
--				symbols = { modified = "[]", readonly = " " },
--			},
--		},
--		lualine_x = {
--			{ "diagnostics", sources = { "nvim_diagnostic" } },
--			"encoding",
--			"fileformat",
--			"filetype",
--		},
--		lualine_y = { "progress" },
--		lualine_z = { "location" },
--	},
--	inactive_sections = {
--		lualine_a = {},
--		lualine_b = {},
--		lualine_c = { "filename" },
--		lualine_x = { "location" },
--		lualine_y = {},
--		lualine_z = {},
--	},
--	tabline = {},
--	extensions = { "nvim-tree", "toggleterm", "quickfix", "symbols-outline" },
--})
