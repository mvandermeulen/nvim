--[[
-- Plugins: File Management
-- Author: Mark van der Meulen
-- Updated: 2025-06-17
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
  { 'nvim-telescope/telescope-live-grep-args.nvim' },
  { 'nvim-telescope/telescope-frecency.nvim' },
  { 'nvim-telescope/telescope-ui-select.nvim' },
  { 'nvim-telescope/telescope-ghq.nvim' },
  { 'nvim-telescope/telescope-smart-history.nvim' },
  { 'KaiSpencer/telescope-tmuxp.nvim' },
  { 'tom-anders/telescope-vim-bookmarks.nvim' },
  { 'TC72/telescope-tele-tabby.nvim' },
  { 'camgraff/telescope-tmux.nvim' },
  { 'cljoly/telescope-repo.nvim' },
  { 'nvim-telescope/telescope-z.nvim' },
  { 'LinArcX/telescope-changes.nvim' },
  { 'LinArcX/telescope-ports.nvim' },
  { 'neanias/telescope-lines.nvim' },
  { 'nyarthan/telescope-code-actions.nvim' },
  { "debugloop/telescope-undo.nvim" },
  { 'kiyoon/telescope-insert-path.nvim' },
  { 'ivanjermakov/telescope-file-structure.nvim' },
  { 'paopaol/telescope-git-diffs.nvim' },
  { 'Marskey/telescope-sg' },
  { 'tsakirist/telescope-lazy.nvim' },
  { 'fdschmidt93/telescope-egrepify.nvim' },
  { 'dhruvmanila/telescope-bookmarks.nvim' },
  { 'scottmckendry/pick-resession.nvim' },
  -- { 'nvim-telescope/telescope-cheat.nvim' },
}
-- local diff_plugin_cmds = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' }

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
  {-- nvim-telescope/telescope-live-grep-args.nvim
    "nvim-telescope/telescope-live-grep-args.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require('telescope').load_extension('live_grep_args')
    end,
  },
  {-- fdschmidt93/telescope-egrepify.nvim
    "fdschmidt93/telescope-egrepify.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require('telescope').load_extension('egrepify')
    end,
  },
  {-- camgraff/telescope-tmux.nvim
    "camgraff/telescope-tmux.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require('telescope').load_extension('tmux')
    end,
  },
  {-- tsakirist/telescope-lazy.nvim
    "tsakirist/telescope-lazy.nvim",
    lazy = true,
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require('telescope').load_extension('lazy')
    end,
  },
  {-- Marskey/telescope-sg
    "Marskey/telescope-sg",
    lazy = true,
    dependencies = { "nvim-telescope/telescope.nvim" },
  },
  {-- dhruvmanila/telescope-bookmarks.nvim
    "dhruvmanila/telescope-bookmarks.nvim",
    lazy = true,
    dependencies = {
        "kkharji/sqlite.lua",
        "nvim-telescope/telescope.nvim",
    },
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
  -- {-- File Management
  --   'kyazdani42/nvim-tree.lua',
  --   lazy = false,
  --   dependencies = {
  --     'b0o/nvim-tree-preview.lua',
  --   },
  --   config = function()
  --     require('plugins.files.nvim-tree')
  --   end,
  -- },
  -- {-- b0o/nvim-tree-preview.lua
  --   'b0o/nvim-tree-preview.lua',
  --   lazy = false,
  --   -- config = function()
  --   --   require('plugins.files.nvim-tree-preview')
  --   -- end,
  -- },
  -- {-- sindrets/diffview.nvim
  --   'sindrets/diffview.nvim',
  --   cmd = diff_plugin_cmds,
  --   lazy = false,
  --   config = function()
  --     require('plugins.files.diffview')
  --   end,
  -- },
  { 'jghauser/mkdir.nvim', lazy = false }, -- Makes directories on save if required. Not Lua
  require('plugins.files.neo-tree'), -- Neo-tree
  require('plugins.files.diffviews'),
  require('plugins.files.tinygit'),
  require('plugins.files.advanced-git-search'),
  require('plugins.files.grug-far'),
  require('plugins.files.spectre'),
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
  {-- SuperBo/fugit2.nvim
    'SuperBo/fugit2.nvim',
    build = false,
    opts = {
      width = 100,
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
      'nvim-lua/plenary.nvim',
      {
        'chrisgrieser/nvim-tinygit', -- optional: for Github PR view
        dependencies = { 'stevearc/dressing.nvim' }
      },
    },
    cmd = { 'Fugit2', 'Fugit2Diff', 'Fugit2Graph' },
    keys = {
      { '<leader>gF', mode = 'n', '<cmd>Fugit2<cr>' }
    }
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
  -- {-- bxrne/was.nvim
  --   'bxrne/was.nvim',
  --   lazy = false,
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --   },
  --   config = function()
  --     require('was').setup()
  --   end,
  -- },
  {-- you-fail-me/git-drift.nvim
    'you-fail-me/git-drift.nvim',
    lazy = false,
    enabled = false, -- TODO: This plugin keeps making neovim crash
    config = function()
      require('git-drift').setup()
    end,
  },
  {-- nick-skriabin/commitment.nvim
    'nick-skriabin/commitment.nvim',
    lazy = false,
    enabled = false, -- TODO: This plugin keeps making neovim unstable
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
  -- DOES NOT WORK ON MACOS WITHOUT DISABLING SIP
  -- {-- nosduco/remote-sshfs.nvim
  --   "nosduco/remote-sshfs.nvim",
  --   dependencies = { "nvim-telescope/telescope.nvim" },
  --   opts = {
  --   },
  -- },
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
