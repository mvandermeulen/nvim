--[[
-- Plugins: Navigation
-- Author: Mark van der Meulen
-- Updated: 2024-12-21
--]]

local M = {
  {-- chrisgrieser/nvim-spider
    "chrisgrieser/nvim-spider",
    lazy = true,
    config = function()
      require('plugins.navigation.spider')
    end,
  },
  {-- cbochs/portal.nvim
    'cbochs/portal.nvim',
    lazy = false,
    config = function()
      require('plugins.navigation.portal')
    end,
  },
  {-- folke/flash.nvim
    'folke/flash.nvim',
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {-- chentoast/marks.nvim
    'chentoast/marks.nvim',
    lazy = false,
    config = function()
      require('plugins.navigation.marks')
    end,
  },
  {-- Recall refines the use of Neovim marks by focusing on global marks
    'fnune/recall.nvim',
    lazy = false,
    config = function()
      require('plugins.navigation.recall')
    end,
  },
  -- {-- tris203/precognition.nvim
  --   'tris203/precognition.nvim',
  --   lazy = false,
  --   config = function()
  --     require('plugins.navigation.precognition')
  --   end,
  -- },
  {-- otavioschwanck/arrow.nvim
    'otavioschwanck/arrow.nvim',
    lazy = false,
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
    opts = {
      show_icons = true,
      leader_key = '\\', -- Recommended to be a single key
      buffer_leader_key = ',', -- Per Buffer Mappings
    },
    config = function()
      require('plugins.navigation.arrow')
    end,
  },
  require('plugins.navigation.bookmarks'),
  {-- cbochs/grapple.nvim
    "cbochs/grapple.nvim",
    opts = {
      scope = "git", -- also try out "git_branch"
    },
    event = { "BufReadPost", "BufNewFile" },
    cmd = "Grapple",
    dependencies = {
        { "nvim-tree/nvim-web-devicons", lazy = true }
    },
    keys = {
        { "<leader>Mgt", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
        { "<leader>Mgw", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
        { "<leader>Mgn", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
        { "<leader>Mg]", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
        { "<leader>Mgp", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
        { "<leader>Mg[", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
        { "<C-v>", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
    },
  },
  {-- tristone13th/lspmark.nvim
    'tristone13th/lspmark.nvim',
    lazy = false,
    config = function()
      require('plugins.navigation.lspmark')
    end,
  },
}

return M
