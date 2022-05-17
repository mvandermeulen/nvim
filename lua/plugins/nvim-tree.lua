--[[
-- File tree Configuration
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]

local g = vim.g

-- vim.g.nvim_tree_auto_ignore_ft = { 'alpha' } -- Don't open tree on specific fiypes.
vim.g.nvim_tree_git_hl = 1 -- 0 by default, will enable file highlight for git attributes (can be used without the icons).
vim.g.nvim_tree_highlight_opened_files = 1 -- 0 by default, will enable folder and file icon highlight for opened files/directories.
vim.g.nvim_tree_root_folder_modifier = ':~' -- This is the default. See :help filename-modifiers for more options
vim.g.nvim_tree_add_trailing = 1 -- 0 by default, append a trailing slash to folder names
vim.g.nvim_tree_group_empty = 1 --  0 by default, compact folders that only contain a single folder into one node in the file tree
vim.g.nvim_tree_icon_padding = ' ' -- one space by default, used for rendering the space between the icon and the filename. Use with caution, it could break rendering if you set an empty string depending on your font.
vim.g.nvim_tree_symlink_arrow = ' >> ' --  defaults to ' ➛ '. used as a separator between symlinks' source and target.
vim.g.nvim_tree_respect_buf_cwd = 1 -- 0 by default, will change cwd of nvim-tree to that of new buffer's when opening nvim-tree.
vim.g.nvim_tree_show_icons = { git = 1, folders = 1, files = 1, folder_arrows = 1 }
vim.g.nvim_tree_icons = {
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
}

local tree_cb = require('nvim-tree.config').nvim_tree_callback

local status_ok, nvim_tree = pcall(require, 'nvim-tree')
if not status_ok then
  return
end

nvim_tree.setup {
  disable_netrw = true, -- disables netrw completely
  hijack_netrw = true, -- hijack netrw window on startup
  open_on_setup = false, -- open the tree when running this setup function
  open_on_tab = false, -- opens the tree when changing/opening a new tab if the tree wasn't previously opened
  hijack_cursor = true, -- hijack the cursor in the tree to put it at the start of the filename
  update_cwd = true, -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
  hijack_unnamed_buffer_when_opening = false,
  -- ignore_ft_on_setup = { 'startify', 'dashboard', 'alpha' },
  diagnostics = { enabled = true, icon = { hint = '', info = '', warning = '', error = '' } }, -- show lsp diagnostics in the signcolumn
  git = { enable = true, ignore = true, timeout = 500 },
  filters = {
    dotfiles = false,
    custom = { '.git', 'node_modules', '.cache', '__pycache__', '.nvim', '.is_root_directory', '.DS_Store' },
  },
  -- filters = { dotfiles = false }, -- this option hides files and folders starting with a dot `.`
  -- git = { ignore = true },
  update_to_buf_dir = { enable = true, auto_open = true },
  -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
  update_focused_file = {
    enable = true,
    update_cwd = false, -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
    ignore_list = { '.git', 'node_modules', '.cache' }, -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
  },
  system_open = { cmd = nil, args = {} }, -- configuration options for the system open command (`s` in the tree by default)
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
          filetype = { 'notify', 'packer', 'qf', 'diff', 'toggleterm', 'fugitiveblame', 'Outline' },
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
  },
  view = {
    number = false,
    relativenumber = false,
    width = math.floor(vim.fn.winwidth(0) * 0.18), -- Finding 15% of windows width.
    auto_resize = true,
    preserve_window_proportions = false,
    side = 'left', -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
    mappings = {
      custom_only = true, -- custom only false will merge the list with the default mappings. If true, it will only use your list to set the mappings
      -- list of mappings to set on the tree manually
      list = {
        { key = { '<CR>', 'o', '<2-LeftMouse>' }, cb = tree_cb 'edit' },
        { key = { '<2-RightMouse>', '<C-]>' }, cb = tree_cb 'cd' },
        { key = '<C-v>', cb = tree_cb 'vsplit' },
        { key = '<C-x>', cb = tree_cb 'split' },
        { key = '<C-t>', cb = tree_cb 'tabnew' },
        { key = '<', cb = tree_cb 'prev_sibling' },
        { key = '>', cb = tree_cb 'next_sibling' },
        { key = 'P', cb = tree_cb 'parent_node' },
        { key = '<BS>', cb = tree_cb 'close_node' },
        { key = '<S-CR>', cb = tree_cb 'close_node' },
        { key = '<Tab>', cb = tree_cb 'preview' },
        { key = 'K', cb = tree_cb 'first_sibling' },
        { key = 'J', cb = tree_cb 'last_sibling' },
        { key = 'I', cb = tree_cb 'toggle_ignored' },
        { key = 'H', cb = tree_cb 'toggle_dotfiles' },
        { key = 'R', cb = tree_cb 'refresh' },
        { key = 'a', cb = tree_cb 'create' },
        { key = 'd', cb = tree_cb 'remove' },
        { key = 'r', cb = tree_cb 'rename' },
        { key = '<C-r>', cb = tree_cb 'full_rename' },
        { key = 'x', cb = tree_cb 'cut' },
        { key = 'c', cb = tree_cb 'copy' },
        { key = 'p', cb = tree_cb 'paste' },
        { key = 'y', cb = tree_cb 'copy_name' },
        { key = 'Y', cb = tree_cb 'copy_path' },
        { key = 'gy', cb = tree_cb 'copy_absolute_path' },
        { key = '[c', cb = tree_cb 'prev_git_item' },
        { key = ']c', cb = tree_cb 'next_git_item' },
        { key = '-', cb = tree_cb 'dir_up' },
        { key = 's', cb = tree_cb 'system_open' },
        { key = 'q', cb = tree_cb 'close' },
        { key = 'g?', cb = tree_cb 'toggle_help' },
      },
    },
  },
}
