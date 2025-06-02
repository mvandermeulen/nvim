--[[
-- Plugins: File Management
-- Author: Mark van der Meulen
-- Updated: 2024-09-21
--]]


---------------------------
-- Dependencies
---------------------------

local telescope_depends = {
  { 'nvim-lua/popup.nvim' },
  { 'nvim-lua/plenary.nvim' },
  { 'crispgm/telescope-heading.nvim' },
  { 'nvim-telescope/telescope-symbols.nvim' },
  { 'nvim-telescope/telescope-file-browser.nvim' },
  { 'nvim-telescope/telescope-project.nvim' },
  { 'nvim-telescope/telescope-github.nvim' },
  { 'nvim-telescope/telescope-packer.nvim' },
  { 'nvim-telescope/telescope-node-modules.nvim' },
  { 'nvim-telescope/telescope-live-grep-raw.nvim' },
  { 'KaiSpencer/telescope-tmuxp.nvim' },
  { 'tom-anders/telescope-vim-bookmarks.nvim' },
  { 'TC72/telescope-tele-tabby.nvim' },
  { 'camgraff/telescope-tmux.nvim' },
  { 'nvim-telescope/telescope-frecency.nvim' },
  { 'cljoly/telescope-repo.nvim' },
  { 'nvim-telescope/telescope-z.nvim' },
  { 'LinArcX/telescope-changes.nvim' },
  { 'LinArcX/telescope-ports.nvim' },
  { 'neanias/telescope-lines.nvim' },
  { 'nyarthan/telescope-code-actions.nvim' },
  { 'nvim-telescope/telescope-ui-select.nvim' },
  { "debugloop/telescope-undo.nvim" },
  { 'nvim-telescope/telescope-ghq.nvim' },
  { 'nvim-telescope/telescope-smart-history.nvim' },
  { 'kiyoon/telescope-insert-path.nvim' },
  { 'ivanjermakov/telescope-file-structure.nvim' },
  { 'paopaol/telescope-git-diffs.nvim' },
  -- { 'nvim-telescope/telescope-cheat.nvim' },
}
local diff_plugin_cmds = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' }

---------------------------
-- Plugins
---------------------------

local M = {
  {-- ibhagwan/fzf-lua
    'ibhagwan/fzf-lua',
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require('plugins.files.fzf-lua')
    end,
  },
  {-- debugloop/telescope-undo.nvim
    'debugloop/telescope-undo.nvim',
    lazy = false,
    dependencies = { "nvim-telescope/telescope.nvim" },
  },
  {-- nvim-telescope/telescope.nvim
    'nvim-telescope/telescope.nvim',
    lazy = false,
    dependencies = telescope_depends,
    config = function()
      require('plugins.files.telescope')
    end,
  },
  {-- nvim-telescope/telescope-fzf-native.nvim
    'nvim-telescope/telescope-fzf-native.nvim',
    lazy = false,
    build = 'make'
  },
  {-- nvim-telescope/telescope-frecency.nvim
    "nvim-telescope/telescope-frecency.nvim",
    version = "^0.9.0",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("frecency")
    end,
  },
  {-- nvim-telescope/telescope-github.nvim
    "nvim-telescope/telescope-github.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require('telescope').load_extension('gh')
    end,
  },
  {-- paopaol/telescope-git-diffs.nvim
    'paopaol/telescope-git-diffs.nvim',
    dependencies = {
      "nvim-lua/plenary.nvim",
      'sindrets/diffview.nvim',
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require('telescope').load_extension('git_diffs')
    end,
  },
  {-- kiyoon/telescope-insert-path.nvim
    'kiyoon/telescope-insert-path.nvim',
    dependencies = { "nvim-telescope/telescope.nvim" },
  },
  {-- ivanjermakov/telescope-file-structure.nvim
    'ivanjermakov/telescope-file-structure.nvim',
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require('telescope').load_extension('file_structure')
    end,
  },
  {-- nvim-telescope/telescope-cheat.nvim
    "nvim-telescope/telescope-cheat.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require('telescope').load_extension('cheat')
    end,
  },
  {-- nvim-telescope/telescope-smart-history.nvim
    'nvim-telescope/telescope-smart-history.nvim',
    dependencies = {
      'kkharji/sqlite.lua',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('telescope').load_extension('smart_history')
    end,
  },
  {-- danielfalk/smart-open.nvim
    "danielfalk/smart-open.nvim",
    branch = "0.2.x",
    config = function()
      require("telescope").load_extension("smart_open")
    end,
    dependencies = {
      "kkharji/sqlite.lua",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
  },
  {-- FabianWirth/search.nvim
    "FabianWirth/search.nvim",
    lazy = false,
    dependencies = { "nvim-telescope/telescope.nvim" },
  },
  {-- File Management
    'kyazdani42/nvim-tree.lua',
    lazy = false,
    dependencies = {
      'b0o/nvim-tree-preview.lua',
    },
    config = function()
      require('plugins.files.nvim-tree')
    end,
  },
  {-- b0o/nvim-tree-preview.lua
    'b0o/nvim-tree-preview.lua',
    lazy = false,
    -- config = function()
    --   require('plugins.files.nvim-tree-preview')
    -- end,
  },
  { 'jghauser/mkdir.nvim', lazy = false }, -- Makes directories on save if required. Not Lua
  {-- sindrets/diffview.nvim
    'sindrets/diffview.nvim',
    cmd = diff_plugin_cmds,
    lazy = false,
    config = function()
      require('plugins.files.diffview')
    end,
  },
  {-- tanvirtin/vgit.nvim
    'tanvirtin/vgit.nvim',
    lazy = false,
    config = function()
      require('plugins.files.vgit')
    end,
  },
  {-- TimUntersberger/neogit
    'NeogitOrg/neogit',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      "sindrets/diffview.nvim",
    },
    cmd = 'Neogit',
    config = function()
      require('plugins.files.neogit')
    end,
  },
  {-- lewis6991/gitsigns.nvim
    'lewis6991/gitsigns.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('plugins.files.gitsigns')
    end,
  },
  {-- ahmedkhalf/project.nvim
    'ahmedkhalf/project.nvim',
    lazy = false,
    config = function()
      require('plugins.files.project')
    end,
  },
  {-- folke/persistence.nvim
    'folke/persistence.nvim',
    lazy = false,
    event = 'BufReadPre',
    config = function()
      require('plugins.files.persistence')
    end,
  },
  {-- stevearc/resession.nvim
    'stevearc/resession.nvim',
    lazy = false,
    config = function()
      require('plugins.files.resession')
    end,
  },
  -- {-- 
  --   '',
  --   lazy = false,
  --   config = function()
  --     require('').setup()
  --   end,
  -- },
  {-- bxrne/was.nvim
    'bxrne/was.nvim',
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require('was').setup()
    end,
  },
  {-- you-fail-me/git-drift.nvim
    'you-fail-me/git-drift.nvim',
    lazy = false,
    config = function()
      require('git-drift').setup()
    end,
  },
  {-- nick-skriabin/commitment.nvim
    'nick-skriabin/commitment.nvim',
    lazy = false,
    config = function()
      require('commitment').setup({
        stop_on_write = false,
        stop_on_useless_commit = false,
        writes_number = 30,
        check_interval = 15,
      })
    end,
  },
  {-- sessions.nvim
    'natecraddock/sessions.nvim',
    lazy = false,
    config = function()
      require('plugins.files.sessions')
    end,
  },
  {-- natecraddock/workspaces.nvim
    'natecraddock/workspaces.nvim',
    lazy = false,
    config = function()
      require('plugins.files.workspaces')
    end,
  },
  {-- Shatur/neovim-session-manager
    'Shatur/neovim-session-manager',
    lazy = false,
    config = function()
      require('plugins.files.session-manager')
    end,
  },
  {-- olimorris/persisted.nvim
    'olimorris/persisted.nvim',
    lazy = false,
    config = function()
      require('plugins.files.persisted')
    end,
  },
  {-- nosduco/remote-sshfs.nvim
    "nosduco/remote-sshfs.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
    },
  },
  {-- HawkinsT/pathfinder.nvim
    'HawkinsT/pathfinder.nvim',
    lazy = false,
    config = function()
      require('pathfinder').setup({
        open_mode = "vsplit",
        remap_default_keys = false,
      })
      vim.keymap.set('n', 'gf', require('pathfinder').gf, { noremap = true, silent = true, desc = 'Opens the next valid file after the cursor' })
      vim.keymap.set('n', 'gx', require('pathfinder').gx, { noremap = true, silent = true, desc = 'Opens the next valid URL after the cursor' })
      vim.keymap.set('n', '<leader>Pf', require('pathfinder').select_file, { desc = "Pathfinder: Select File", noremap = true, silent = true })
      vim.keymap.set('n', '<leader>PF', require('pathfinder').select_file_line, { desc = "Pathfinder: Select File Line", noremap = true, silent = true })
      vim.keymap.set('n', '<leader>Px', require('pathfinder').select_url, { desc = "Pathfinder: Select UTL", noremap = true, silent = true })
      vim.keymap.set("n", "<leader>Ph", require("pathfinder").hover_description, { desc = "Pathfinder: Hover", noremap = true, silent = true })
    end,
  },
  {-- benoror/gpg.nvim
    "benoror/gpg.nvim",
    lazy = false,
  },
  {-- art-vasilyev/yapath.nvim
    "art-vasilyev/yapath.nvim",
    config = function()
      require("yapath").setup()
      vim.keymap.set("n", "<leader>ecg", require("yapath").copy_git_url)
      vim.keymap.set("n", "<leader>ecr", require("yapath").copy_relative_path)
      vim.keymap.set("n", "<leader>ecp", require("yapath").copy_python_path)
    end,
  },
}

return M
