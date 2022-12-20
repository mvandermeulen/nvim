-- nvim-tree
local tree_cb = require "nvim-tree.config".nvim_tree_callback
vim.g.nvim_tree_respect_buf_cwd = 1
require "nvim-tree".setup {
  disable_netrw = true,
  hijack_netrw = true,
  open_on_setup = false,
  ignore_ft_on_setup = {},
  auto_close = false,
  auto_reload_on_write = true,
  open_on_tab = false,
  hijack_cursor = false,
  update_cwd = true,
  view = {
    width = 30,
    height = 30,
    hide_root_folder = false,
    side = "left",
    auto_resize = false,
    mappings = {
      custom_only = false,
      list = {
        {key = "v", cb = tree_cb("vsplit")},
        {key = "h", cb = tree_cb("dir_up")},
        {key = "l", cb = tree_cb("cd")}
      }
    }
  },
  diagnostics = {
    enable = false,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = ""
    }
  },
  update_focused_file = {
    enable = false,
    update_cwd = false,
    ignore_list = {}
  },
  system_open = {
    cmd = nil,
    args = {}
  },
  filters = {
    dotfiles = true,
    custom = {}
  },
  actions = {
    open_file = {
      quit_on_open = true
    },
    change_dir = {
      enable = true,
      global = true
    }
  }
}
vim.api.nvim_set_keymap("n", "<Leader>o", ":NvimTreeToggle<CR>", {noremap = true, silent = true})
