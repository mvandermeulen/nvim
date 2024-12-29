--[[
-- Plugins: Integration Plugins
-- Author: Mark van der Meulen
-- Updated: 2024-12-23
--]]

local M = {
  {
    "Rawnly/gist.nvim",
    lazy = false,
    cmd = { "GistCreate", "GistCreateFromFile", "GistsList" },
    config = function()
      require('plugins.integration.gists')
    end,
  },
  -- `GistsList` opens the selected gif in a terminal buffer,
  -- nvim-unception uses neovim remote rpc functionality to open the gist in an actual buffer
  -- and prevents neovim buffer inception
  {
    "samjwill/nvim-unception",
    lazy = false,
    init = function() vim.g.unception_block_while_host_edits = true end
  },
  {
    "moyiz/git-dev.nvim",
    lazy = false,
  },
}

return M
