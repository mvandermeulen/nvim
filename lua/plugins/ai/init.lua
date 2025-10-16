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
  require('plugins.ai.claudecode'),
  {-- Davidyz/VectorCode
    'Davidyz/VectorCode',
    lazy = false,
    -- config = function()
    --   require('').setup()
    -- end,
  },
  -- {-- greggh/claude-code.nvim
  --   'greggh/claude-code.nvim',
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --   },
  --   lazy = false,
  --   config = function()
  --     require("claude-code").setup({
        -- window = {
        --   split_ratio = 0.3,      -- Percentage of screen for the terminal window (height for horizontal, width for vertical splits)
        --   position = "botright",  -- Position of the window: "botright", "topleft", "vertical", "float", etc.
        --   enter_insert = true,    -- Whether to enter insert mode when opening Claude Code
        --   hide_numbers = true,    -- Hide line numbers in the terminal window
        --   hide_signcolumn = true, -- Hide the sign column in the terminal window
        -- },
        -- refresh = {
        --   enable = true,           -- Enable file change detection
        --   updatetime = 100,        -- updatetime when Claude Code is active (milliseconds)
        --   timer_interval = 1000,   -- How often to check for file changes (milliseconds)
        --   show_notifications = true, -- Show notification when files are reloaded
        -- },
        -- git = {
        --   use_git_root = true,     -- Set CWD to git root when opening Claude Code (if in git project)
        -- },
        -- shell = {
        --   separator = '&&',        -- Command separator used in shell commands
        --   pushd_cmd = 'pushd',     -- Command to push directory onto stack (e.g., 'pushd' for bash/zsh, 'enter' for nushell)
        --   popd_cmd = 'popd',       -- Command to pop directory from stack (e.g., 'popd' for bash/zsh, 'exit' for nushell)
        -- },
        -- command = "claude",        -- Command used to launch Claude Code
        -- command_variants = {
        --   continue = "--continue", -- Resume the most recent conversation
        --   resume = "--resume",     -- Display an interactive conversation picker
        --   verbose = "--verbose",   -- Enable verbose logging with full turn-by-turn output
        -- },
  --       keymaps = {
  --         toggle = {
  --           normal = "<C-,>",       -- Normal mode keymap for toggling Claude Code, false to disable
  --           terminal = "<C-,>",     -- Terminal mode keymap for toggling Claude Code, false to disable
  --           variants = {
  --             continue = "<leader>cC", -- Normal mode keymap for Claude Code with continue flag
  --             verbose = "<leader>cV",  -- Normal mode keymap for Claude Code with verbose flag
  --           },
  --         },
  --         window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
  --         scrolling = true,         -- Enable scrolling keymaps (<C-f/b>) for page up/down
  --       }
  --     })
  --   end,
  -- },
  -- {-- 
  --   '',
  --   lazy = false,
  --   config = function()
  --     require('').setup()
  --   end,
  -- },

}

return M
