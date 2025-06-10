--[[
-- Plugins: Navigation
-- Author: Mark van der Meulen
-- Updated: 2025-06-10
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
  require('plugins.navigation.leap'),
  require('plugins.navigation.flit'),
  require('plugins.navigation.arrow'),
  require('plugins.navigation.eyeliner'),
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
  {-- asmorris/line_notes.nvim
      "asmorris/line_notes.nvim",
      dependencies = { "nvim-telescope/telescope.nvim" },
      config = function()
          require('line_notes').setup({})
      end
  },
  -- {-- tristone13th/lspmark.nvim
  --   'tristone13th/lspmark.nvim',
  --   lazy = false,
  --   config = function()
  --     require('plugins.navigation.lspmark')
  --   end,
  -- },
}

return M
