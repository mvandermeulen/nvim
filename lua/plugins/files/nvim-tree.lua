--[[
-- File tree Configuration
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]

-- local tree_cb = require('nvim-tree.config').nvim_tree_callback
local status_ok, nvim_tree = pcall(require, 'nvim-tree')
if not status_ok then
  return
end

--
-- This function has been generated from your
--   view.mappings.list
--   view.mappings.custom_only
--   remove_keymaps
--
-- You should add this function to your configuration and set on_attach = on_attach in the nvim-tree setup call.
--
-- Although care was taken to ensure correctness and completeness, your review is required.
--
-- Please check for the following issues in auto generated content:
--   "Mappings removed" is as you expect
--   "Mappings migrated" are correct
--
-- Please see https://github.com/nvim-tree/nvim-tree.lua/wiki/Migrating-To-on_attach for assistance in migrating.
--

local function on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  local preview = require('nvim-tree-preview')

  vim.keymap.set('n', 'P', preview.watch, opts 'Preview (Watch)')
  vim.keymap.set('n', '<Esc>', preview.unwatch, opts 'Close Preview/Unwatch')
  vim.keymap.set('n', '<C-f>', function() return preview.scroll(4) end, opts 'Scroll Down')
  vim.keymap.set('n', '<C-b>', function() return preview.scroll(-4) end, opts 'Scroll Up')
  vim.keymap.set('n', '<Tab>', function()
    local ok, node = pcall(api.tree.get_node_under_cursor)
    if ok and node then
      if node.type == 'directory' then
        api.node.open.edit()
      else
        preview.node(node, { toggle_focus = true })
      end
    end
  end, opts 'Preview')
  vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', '<2-RightMouse>', api.tree.change_root_to_node, opts('CD'))
  vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node, opts('CD'))
  vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
  vim.keymap.set('n', '<C-x>', api.node.open.horizontal, opts('Open: Horizontal Split'))
  vim.keymap.set('n', '<C-t>', api.node.open.tab, opts('Open: New Tab'))
  vim.keymap.set('n', '<', api.node.navigate.sibling.prev, opts('Previous Sibling'))
  vim.keymap.set('n', '>', api.node.navigate.sibling.next, opts('Next Sibling'))
  -- vim.keymap.set('n', 'P', api.node.navigate.parent, opts('Parent Directory'))
  vim.keymap.set('n', '<BS>', api.node.navigate.parent_close, opts('Close Directory'))
  vim.keymap.set('n', '<S-CR>', api.node.navigate.parent_close, opts('Close Directory'))
  vim.keymap.set('n', '<Tab>', api.node.open.preview, opts('Open Preview'))
  vim.keymap.set('n', 'K', api.node.navigate.sibling.first, opts('First Sibling'))
  vim.keymap.set('n', 'J', api.node.navigate.sibling.last, opts('Last Sibling'))
  vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts('Toggle Dotfiles'))
  vim.keymap.set('n', 'R', api.tree.reload, opts('Refresh'))
  vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
  vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
  vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))
  vim.keymap.set('n', '<C-r>', api.fs.rename_sub, opts('Rename: Omit Filename'))
  vim.keymap.set('n', 'x', api.fs.cut, opts('Cut'))
  vim.keymap.set('n', 'c', api.fs.copy.node, opts('Copy'))
  vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))
  vim.keymap.set('n', 'y', api.fs.copy.filename, opts('Copy Name'))
  vim.keymap.set('n', 'Y', api.fs.copy.relative_path, opts('Copy Relative Path'))
  vim.keymap.set('n', 'gy', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
  vim.keymap.set('n', '[c', api.node.navigate.git.prev, opts('Prev Git'))
  vim.keymap.set('n', ']c', api.node.navigate.git.next, opts('Next Git'))
  vim.keymap.set('n', '-', api.tree.change_root_to_parent, opts('Up'))
  vim.keymap.set('n', 's', api.node.run.system, opts('Run System'))
  vim.keymap.set('n', 'q', api.tree.close, opts('Close'))
  vim.keymap.set('n', 'g?', api.tree.toggle_help, opts('Help'))

end

nvim_tree.setup {
  on_attach = on_attach,
  sync_root_with_cwd = true,
  disable_netrw = false, -- disables netrw completely
  hijack_netrw = false, -- hijack netrw window on startup
  --[[ open_on_setup = false, -- open the tree when running this setup function ]]
  open_on_tab = false, -- opens the tree when changing/opening a new tab if the tree wasn't previously opened
  hijack_cursor = true, -- hijack the cursor in the tree to put it at the start of the filename
  update_cwd = true, -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
  hijack_unnamed_buffer_when_opening = false,
  respect_buf_cwd = true,
  -- ignore_ft_on_setup = { 'startify', 'dashboard', 'alpha' },
  -- diagnostics = { enabled = true, icon = { hint = '', info = '', warning = '', error = '' } }, -- show lsp diagnostics in the signcolumn
  git = { enable = true, ignore = false, timeout = 500 },
  filters = {
    dotfiles = false,
    custom = { '^.git$', 'node_modules', '^.cache$', '__pycache__', '^.nvim$', '.is_root_directory', '.DS_Store' },
  },
  -- filters = { dotfiles = false }, -- this option hides files and folders starting with a dot `.`
  -- git = { ignore = true },
  -- update_to_buf_dir = { enable = true, auto_open = true },
  -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
  update_focused_file = {
    enable = true,
    update_root = true, -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
    ignore_list = { '.git', 'node_modules', '.cache' }, -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
  },
  system_open = { cmd = 'open', args = { '--reveal', } }, -- configuration options for the system open command (`s` in the tree by default)
  trash = { cmd = 'trash-put', require_confirm = true },
  actions = {
    change_dir = { enable = true, global = false, restrict_above_cwd = false },
    open_file = {
      quit_on_open = false,
      resize_window = false, -- if true the tree will resize itself after opening a file
      window_picker = {
        enable = true,
        chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
        exclude = {
          filetype = { 'notify', 'Lazy', 'qf', 'diff', 'toggleterm', 'fugitiveblame', 'Outline' },
          buftype = { 'nofile', 'terminal', 'help' },
        },
      },
    },
  },
  renderer = {
    indent_markers = {
      enable = true,
      icons = { corner = '└ ', edge = '│ ', none = '  ' },
    },
    icons = {
      padding = ' ',
      symlink_arrow = ' >> ',
      glyphs = {
        default = '',
        symlink = '',
        git = {
          unstaged = '',
          staged = 'S',
          unmerged = '',
          renamed = '➜',
          deleted = '',
          untracked = 'U',
          ignored = '◌',
        },
        folder = {
          default = '',
          open = '',
          empty = '',
          empty_open = '',
          symlink = '',
        },
      },
      show = { git = true, folder = true, file = true, folder_arrow = true },
    },
    highlight_opened_files = 'name',
    highlight_git = true,
    root_folder_modifier = ':~',
    add_trailing = true,
    group_empty = true,
  },
  view = {
    number = false,
    relativenumber = false,
    width = math.floor(vim.fn.winwidth(0) * 0.18), -- Finding 15% of windows width.
    adaptive_size = true,
    -- auto_resize = true,
    preserve_window_proportions = false,
    side = 'left', -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
  },
}
