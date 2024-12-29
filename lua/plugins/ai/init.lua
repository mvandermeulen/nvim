--[[
-- Plugins: AI
-- Author: Mark van der Meulen
-- Updated: 2024-09-21
--]]

local M = {
  {-- yetone/avante.nvim
    "yetone/avante.nvim",
    lazy = false,
    -- event = "VeryLazy",
    build = "make", -- This is Optional, only if you want to use tiktoken_core to calculate tokens count
    config = function()
      require('plugins.ai.avante')
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "zbirenbaum/copilot.lua",
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  {-- magicalne/nvim.ai
    "magicalne/nvim.ai",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require('plugins.ai.nvimai')
    end
  },
  -- {-- meeehdi-dev/bropilot.nvim
  --   'meeehdi-dev/bropilot.nvim',
  --   event = "VeryLazy", -- preload model on start
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "stevearc/dressing.nvim",
  --     "j-hui/fidget.nvim",
  --   },
  --   config = function()
  --     require('plugins.ai.bropilot')
  --   end,
  -- },
  {-- zbirenbaum/copilot.lua
    "zbirenbaum/copilot.lua",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require('plugins.ai.copilot')
    end,
  },
  {-- jonahgoldwastaken/copilot-status.nvim
    "jonahgoldwastaken/copilot-status.nvim",
    dependencies = { "zbirenbaum/copilot.lua" },
    lazy = true,
    event = "BufReadPost",
  },
  {-- CopilotC-Nvim/CopilotChat.nvim
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = 'main',
    dependencies = {
      "zbirenbaum/copilot.lua",
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    build = "make tiktoken",
    config = function()
      require('plugins.ai.copilot_chat')
    end,
  },
  { 'AndreM222/copilot-lualine' },
  {-- olimorris/codecompanion.nvim
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "iguanacucumber/magazine.nvim",
      "stevearc/dressing.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require('plugins.ai.codecompanion')
    end,
  },
}

return M
