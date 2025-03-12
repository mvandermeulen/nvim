--[[
-- Plugins: Language
-- Author: Mark van der Meulen
-- Updated: 2024-09-21
--]]

local treesitter_depends = {
  { 'nvim-treesitter/nvim-treesitter-textobjects' },
  { 'p00f/nvim-ts-rainbow' },
  { 'eckon/treesitter-current-functions' },
}

local M = {
  {-- nvim-treesitter
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    dependencies = treesitter_depends,
    config = function()
      require('plugins.lang.treesitter')
    end,
    name = "treesitter",
    build = ':TSUpdate',
  },
  {-- nvim-treesitter-context
    'romgrk/nvim-treesitter-context',
    lazy = false,
    config = function()
      require('plugins.lang.treesitter-context')
    end,
    name = "treesitter-context",
  },
  require('plugins.lang.context_vt'),
  {-- Pair completion ie. parentheses
    'windwp/nvim-autopairs',
    lazy = false,
    config = function()
      require('plugins.lang.autopairs')
    end,
    name = "autopairs",
  },
  {-- nvim-cmp
    'hrsh7th/nvim-cmp',
    lazy = false,
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-buffer' }, -- buffer completions
      { 'hrsh7th/cmp-path' }, -- path completions
      { 'hrsh7th/cmp-cmdline' }, -- cmdline completions
      { 'hrsh7th/cmp-calc' },
      { 'hrsh7th/cmp-nvim-lua' },
      { 'onsails/lspkind-nvim' },
      { 'famiu/bufdelete.nvim' },
    },
    config = function()
      require('plugins.lang.cmp')
    end,
    name = "cmp",
  },
  {-- LuaSnip
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require('plugins.lang.luasnip')
    end,
  },
  { 'neovim/nvim-lspconfig', lazy = false },
  {-- icholy/lsplinks.nvim
    "icholy/lsplinks.nvim",
    config = function()
      local lsplinks = require("lsplinks")
      lsplinks.setup()
      vim.keymap.set("n", "gx", lsplinks.gx)
    end
  },
  {-- SmiteshP/nvim-navic
    'SmiteshP/nvim-navic',
    lazy = false,
    dependencies = {
      {'neovim/nvim-lspconfig'},
    },
  },
  { 'nvimtools/none-ls.nvim', lazy = false },
  { 'jay-babu/mason-null-ls.nvim', lazy = false },
  { 'WhoIsSethDaniel/mason-tool-installer.nvim', lazy = false },
  { 'mhartington/formatter.nvim', lazy = false },
  {-- williamboman/mason.nvim
    'williamboman/mason.nvim',
    lazy = false,
    dependencies = {
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason-lspconfig.nvim'},
      {'jay-babu/mason-null-ls.nvim'},
      {'nvimtools/none-ls.nvim'},
      {'WhoIsSethDaniel/mason-tool-installer.nvim'},
    },
    config = function()
      require('plugins.lang.mason')
    end,
    name = "mason",
  },
  {-- ray-x/lsp_signature.nvim
    'ray-x/lsp_signature.nvim',
    lazy = false,
    dependencies = {
      {'neovim/nvim-lspconfig'},
    },
    config = function()
      require('plugins.lang.lsp-signature')
    end,
    name = "lsp-signature",
  },
  {-- rmagatti/goto-preview
    "rmagatti/goto-preview",
    event = "BufEnter",
    config = true,
    keys = {
      {
        "<leader>pd",
        "<cmd>lua require('goto-preview').goto_preview_definition()<CR>",
        noremap = true,
        desc = "goto preview definition",
      },
      {
        "<leader>pD",
        "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>",
        noremap = true,
        desc = "goto preview declaration",
      },
      {
        "<leader>pi",
        "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
        noremap = true,
        desc = "goto preview implementation",
      },
      {
        "<leader>py",
        "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
        noremap = true,
        desc = "goto preview type definition",
      },
      {
        "<leader>pr",
        "<cmd>lua require('goto-preview').goto_preview_references()<CR>",
        noremap = true,
        desc = "goto preview references",
      },
      {
        "<leader>pP",
        "<cmd>lua require('goto-preview').close_all_win()<CR>",
        noremap = true,
        desc = "close all preview windows",
      },
    },
  },
  {-- hedyhli/outline.nvim
    'hedyhli/outline.nvim',
    lazy = false,
    config = function()
      require('plugins.lang.outline')
    end,
    name = "Outline",
  },
  {-- aznhe21/actions-preview.nvim
    'aznhe21/actions-preview.nvim',
    lazy = false,
    config = function()
      require("actions-preview").setup {
        diff = {
          algorithm = "patience",
          ignore_whitespace = true,
        },
        telescope = require("telescope.themes").get_dropdown { winblend = 10 },
      }
      vim.keymap.set({ "v", "n" }, "ga", require("actions-preview").code_actions)
    end,
  },
  {-- mfussenegger/nvim-dap
    'mfussenegger/nvim-dap',
    lazy = false,
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        config = require("plugins.lang.dapui"),
        dependencies = {
          "nvim-neotest/nvim-nio",
        },
      },
      { "jay-babu/mason-nvim-dap.nvim" },
    },
    config = function()
      require('plugins.lang.dap')
    end,
  },
  {-- mfussenegger/nvim-dap-python
    'mfussenegger/nvim-dap-python',
    lazy = false,
    config = function()
      require('plugins.lang.dap-python')
    end,
  },
  {-- theHamsta/nvim-dap-virtual-text
    'theHamsta/nvim-dap-virtual-text',
    lazy = false,
    config = function()
      require('plugins.lang.dap-virtual-text')
    end,
  },
  {-- nvim-telescope/telescope-dap.nvim
    "nvim-telescope/telescope-dap.nvim",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require('telescope').load_extension('dap')
    end,
  },
  { 'cuducos/yaml.nvim', ft = { 'yaml' } }, -- Language Specific
  {-- roobert/action-hints.nvim
    "roobert/action-hints.nvim",
    config = function()
      require("action-hints").setup({
        template = {
          definition = { text = " ⊛", color = "#add8e6" },
          references = { text = " ↱%s", color = "#ff6666" },
        },
        use_virtual_text = true,
      })
    end,
  },
  {-- antosha417/nvim-lsp-file-operations
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-tree.lua",
    },
    config = function()
      require("lsp-file-operations").setup()
    end,
  },
  {-- cenk1cenk2/jq.nvim
    "cenk1cenk2/jq.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "grapp-dev/nui-components.nvim",
    },
    config = function()
      require("jq").setup()
    end,
  },
  {-- artemave/workspace-diagnostics.nvim
    'artemave/workspace-diagnostics.nvim',
    lazy = false,
  },
  {-- jubnzv/virtual-types.nvim
    'jubnzv/virtual-types.nvim',
    lazy = false,
  },
  {-- dnlhc/glance.nvim
    'dnlhc/glance.nvim',
    cmd = 'Glance',
    lazy = false,
    config = function()
      require('plugins.lang.glance')
    end,
  },
  {
    "zeioth/garbage-day.nvim",
    dependencies = "neovim/nvim-lspconfig",
    event = "VeryLazy",
    enabled = false,-- This might be breaking copilot?
    opts = {
      grace_period = 600,
      notifications = true,
    }
  },
  {-- amnn/lsp-echohint.nvim
    'amnn/lsp-echohint.nvim',
    lazy = false,
    config = function()
      require('lsp-echohint').setup({
        auto_enable = true,
      })
    end,
  },
  -- {-- 
  --   '',
  --   lazy = false,
  --   config = function()
  --     require('').setup()
  --   end,
  -- },
  {-- linrongbin16/lsp-progress.nvim
    'linrongbin16/lsp-progress.nvim',
    lazy = false,
    config = function()
      require('lsp-progress').setup()
    end,
  },
  {-- mhanberg/output-panel.nvim
    "mhanberg/output-panel.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("output_panel").setup({
        max_buffer_size = 5000 -- default
      })
    end,
    cmd = { "OutputPanel" },
    keys = {
      {
        "<leader>lp",
        vim.cmd.OutputPanel,
        mode = "n",
        desc = "Panel: Server Logs",
      },
    }
  }
}

return M
