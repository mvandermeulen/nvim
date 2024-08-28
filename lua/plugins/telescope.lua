--[[
-- Telescope Configuration
--
-- Author: Mark van der Meulen
-- Updated: 2024-08-22
--]]

local status_ok, telescope = pcall(require, 'telescope')
if not status_ok then
  return
end

local actions = require 'telescope.actions'
local action_layout = require 'telescope.actions.layout'
-- local icons = require 'helpers.icons'


-----------------------------------------------
-- Telescope Setup
-----------------------------------------------
telescope.setup {
  extensions = {
    tele_tabby = {
        use_highlighter = true,
    },
    repo = {
      list = {
        search_dirs = {
          "~/projects",
          "~/resources",
          "~/Documents/2023",
        },
      },
    },
  },
  defaults = {
    file_ignore_patterns = { 'node_modules', '.terraform', '%.jpg', '%.png' },
    vimgrep_arguments = {
      'rg',
      '--follow',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
    },
    mappings = {
      i = {
        -- Close on first esc instead of gonig to normal mode
        -- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/mappings.lua
        ['<esc>'] = actions.close,
        ['<C-j>'] = actions.move_selection_next,
        ['<PageUp>'] = actions.results_scrolling_up,
        ['<PageDown>'] = actions.results_scrolling_down,
        ['<C-k>'] = actions.move_selection_previous,
        ['<A-q>'] = actions.send_selected_to_qflist,
        ['<C-q>'] = actions.send_to_qflist,
        ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
        ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
        ['<cr>'] = actions.select_default,
        ['<c-v>'] = actions.select_vertical,
        ['<c-s>'] = actions.select_horizontal,
        ['<c-t>'] = actions.select_tab,
        ['<c-p>'] = action_layout.toggle_preview,
        ['<c-o>'] = action_layout.toggle_mirror,
        ['<c-h>'] = actions.which_key,
      },
    },
    path_display = { 'smart' },
    prompt_prefix = '> ',
    selection_caret = ' ',
    entry_prefix = '  ',
    multi_icon = '<>',
    initial_mode = 'insert',
    scroll_strategy = 'cycle',
    selection_strategy = 'reset',
    sorting_strategy = 'descending',
    layout_strategy = 'horizontal',
    layout_config = {
      width = 0.95,
      height = 0.85,
      -- preview_cutoff = 120,
      prompt_position = 'top',
      horizontal = {
        preview_width = function(_, cols, _)
          if cols > 200 then
            return math.floor(cols * 0.4)
          else
            return math.floor(cols * 0.6)
          end
        end,
      },
      vertical = { width = 0.9, height = 0.95, preview_height = 0.5 },
      flex = { horizontal = { preview_width = 0.9 } },
    },
    file_sorter = require('telescope.sorters').get_fzf_sorter,
    generic_sorter = require('telescope.sorters').get_fzf_sorter,
    winblend = 0,
    border = {},
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    color_devicons = true,
    use_less = true,
    set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
  },
}

-----------------------------------------------
-- Telescope Toggleterm Setup
-----------------------------------------------
-- require("telescope-toggleterm").setup {
--    telescope_mappings = {
--       -- <ctrl-c> : kill the terminal buffer (default) .
--       ["<C-c>"] = require("telescope-toggleterm").actions.exit_terminal,
--    },
-- }

-----------------------------------------------
-- Load Extensions
-----------------------------------------------
--telescope.load_extension("zoxide")
telescope.load_extension('projects')
telescope.load_extension('fzf')
telescope.load_extension('heading')
telescope.load_extension('file_browser')
telescope.load_extension('notify')
telescope.load_extension('vim_bookmarks')
--telescope.load_extension('frecency')
--telescope.load_extension('software-licenses')
telescope.load_extension('repo')
telescope.load_extension('z')
telescope.load_extension('changes')
telescope.load_extension('ports')
telescope.load_extension('lines')
telescope.load_extension("ui-select")
-- telescope.load_extension('telescope-code-actions')
-- telescope.load_extension('toggleterm')


