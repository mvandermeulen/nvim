--[[
-- Plugins: UI
-- Author: Mark van der Meulen
-- Updated: 2024-09-21
--]]

local M = {
  { 'ray-x/guihua.lua' },
  require('plugins.ui.noice'),
  {-- dynamotn/Navigator.nvim
    'dynamotn/Navigator.nvim',
    lazy = false,
    config = function()
      require('plugins.ui.navigator')
    end,
  },
  -- {-- numToStr/Navigator.nvim
  --   'numToStr/Navigator.nvim',
  --   lazy = false,
  --   config = function()
  --     require('plugins.ui.navigator')
  --   end,
  -- },
  -- {-- hiasr/vim-zellij-navigator.nvim
  --   'hiasr/vim-zellij-navigator.nvim',
  --   lazy = false,
  --   config = function()
  --     require('vim-zellij-navigator').setup()
  --   end,
  -- },
  {-- luukvbaal/stabilize.nvim
    'luukvbaal/stabilize.nvim',
    lazy = false,
    config = function()
      require('stabilize').setup()
    end,
  },
  {-- akinsho/bufferline.nvim
    'akinsho/bufferline.nvim',
    lazy = false,
    version = '*',
    dependencies = 'kyazdani42/nvim-web-devicons',
    event = 'BufReadPre',
    config = function()
      require('plugins.ui.bufferline')
    end,
  },
  {-- rcarriga/nvim-notify
    'rcarriga/nvim-notify',
    lazy = false,
    config = function()
      require('plugins.ui.notify')
    end,
  },
  { 'MunifTanjim/nui.nvim', lazy = false },
  {-- nvim-lualine/lualine.nvim
    'nvim-lualine/lualine.nvim',
    lazy = false,
    dependencies = { 'kyazdani42/nvim-web-devicons', lazy = true },
    event = 'VimEnter',
    config = function()
      require('plugins.ui.lualine')
    end,
  },
  {-- norcalli/nvim-colorizer.lua
    'norcalli/nvim-colorizer.lua',
    lazy = false,
    event = 'BufReadPre',
    config = function()
      require('plugins.ui.colorizer')
    end,
  },
  { 'kevinhwang91/nvim-bqf', lazy = false, dependencies = { { 'junegunn/fzf' } } },
  {-- folke/trouble.nvim
    'folke/trouble.nvim',
    lazy = false,
    dependencies = 'kyazdani42/nvim-web-devicons',
    cmd = { 'TroubleToggle', 'Trouble' },
    config = function()
      require('plugins.ui.trouble')
    end,
  },
  { 'gennaro-tedesco/nvim-jqx', lazy = false },
  { 'RRethy/vim-illuminate', lazy = false, event = 'CursorHold' },
  {-- folke/todo-comments.nvim
    'folke/todo-comments.nvim',
    lazy = false,
    dependencies = 'nvim-lua/plenary.nvim',
    cmd = { 'TodoTrouble', 'TodoTelescope' },
    event = 'BufReadPost',
    config = function()
      require('plugins.ui.todo')
    end,
  },
  {-- stevearc/stickybuf.nvim
    'stevearc/stickybuf.nvim',
    lazy = false,
    config = function()
      require("stickybuf").setup()
      vim.keymap.set("n", "<leader>bP", "<cmd>:PinBuffer<CR>", { noremap = true, silent = true, desc = "Pin buffer" })
    end,
  },
  {-- Bekaboo/dropbar.nvim
    'Bekaboo/dropbar.nvim',
    lazy = false,
    enabled= true,
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make'
    },
    opts = {
        icons = {
          kinds = {
            symbols = {
              File = ' ',
              Folder = '  ',
            },
          },
          ui = {
            bar = {
              separator = '   ',
              extends = '',
            },
            menu = {
              separator = ' ',
              indicator = '',
            },
          },
        },
        bar = {
          enable = function(buf, win)
            return not vim.api.nvim_win_get_config(win).zindex
              and vim.bo[buf].buftype == ''
              and vim.bo[buf].buftype ~= 'terminal'
              and vim.bo[buf].buftype ~= 'markdown'
              and vim.api.nvim_buf_get_name(buf) ~= ''
              and not vim.wo[win].diff
          end,
        },
      },
    config = function()
      require('plugins.ui.dropbar')
    end,
  },
  require('plugins.ui.fold'),
  { 'rhysd/conflict-marker.vim', lazy = false },
  {-- rose-pine/neovim
    'rose-pine/neovim',
    lazy = false,
    name = 'rose-pine',
    version = 'v1.*',
    config = function()
      require('plugins.ui.rpine')
    end,
  },
  {-- nvim-zh/colorful-winsep.nvim
    "nvim-zh/colorful-winsep.nvim",
    config = true,
    event = { "WinLeave" },
  },
  {-- mikavilpas/yazi.nvim
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>aY",
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>Fw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open Yazi in working directory" ,
      },
      {
        '<leader>Fy',
        "<cmd>Yazi toggle<cr>",
        desc = "Yazi Toggle(Resume)",
      },
    },
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = true,
      keymaps = {
        show_help = '<f1>',
      },
    },
  },
  require('plugins.ui.winsep'),
  { 'rktjmp/lush.nvim' },
  { 'folke/tokyonight.nvim' },
  { 'rebelot/kanagawa.nvim' },
  { 'marko-cerovac/material.nvim' },
  { 'eddyekofo94/gruvbox-flat.nvim' },
  { 'shaunsingh/nord.nvim' },
  { 'navarasu/onedark.nvim' },
  { 'olimorris/onedarkpro.nvim' },
  { 'savq/melange' },
  { 'rmehri01/onenord.nvim' },
  { 'Yagua/nebulous.nvim' },
  { 'andersevenrud/nordic.nvim' },
  { 'kvrohit/substrata.nvim' },
  { 'Domeee/mosel.nvim' },
  { 'teloe/drip.nvim' },
  { 'sainnhe/gruvbox-material' },
  { 'Mofiqul/dracula.nvim' },
  { 'shaeinst/roshnivim-cs' },
  { 'rafamadriz/neon' },
  { 'clpi/cyu.lua' },
  { 'glepnir/zephyr-nvim' },
  { 'sam4llis/nvim-tundra' },
  { 'lmburns/kimbox' },
  { 'lvim-tech/lvim-colorscheme' },
  { 'mcchrish/zenbones.nvim' },
  { 'Mofiqul/vscode.nvim' },
  { 'decaycs/decay.nvim', name = 'decay' },
  { 'yashguptaz/calvera-dark.nvim' },
  { 'ishan9299/nvim-solarized-lua' },
  { 'NTBBloodbath/doom-one.nvim' },
  { 'shaunsingh/solarized.nvim' },
  { 'Mofiqul/adwaita.nvim' },
  { 'metalelf0/jellybeans-nvim' },
  { 'Murtaza-Udaipurwala/gruvqueen' },
  { 'daschw/leaf.nvim' },
  { 'AlexvZyl/nordic.nvim', name = 'alexvzyl-nordic' },
  _G.my.plugins.themes.standard_install,
  _G.my.plugins.themes.extended_install,
}

return M
