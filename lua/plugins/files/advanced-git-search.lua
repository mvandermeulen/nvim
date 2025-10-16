--[[
-- Advanced Git Search Plugin
-- Author: Mark van der Meulen
-- Updated: 2025-10-16
--]]


-- Link: https://github.com/aaronhallaert/advanced-git-search.nvim

return {
  'aaronhallaert/advanced-git-search.nvim',
  cmd = { 'AdvancedGitSearch' },
  config = function()
    require('telescope').setup {
      extensions = {
        advanced_git_search = {
          -- You can add custom configuration options here if needed
        },
      },
    }
    require('telescope').load_extension 'advanced_git_search'
  end,
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',
    -- Optionally, you can include diffview.nvim if you want to use it
    -- 'sindrets/diffview.nvim',
  },
  keys = {
    { '<leader>sg', '<cmd>AdvancedGitSearch<CR>', desc = 'Advanced Git Search' },
  },
}
