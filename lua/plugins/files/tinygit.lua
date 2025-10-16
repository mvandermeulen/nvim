return {
  'chrisgrieser/nvim-tinygit',
  cmd = 'TinyGit',
  keys = {
    {
      '<localleader>gs',
      function()
        require('tinygit').interactiveStaging()
      end,
      desc = 'TinyGit: Interactive Staging',
    },
    {
      '<localleader>gc',
      function()
        require('tinygit').smartCommit()
      end,
      desc = 'TinyGit: Smart Commit',
    },
    {
      '<localleader>gp',
      function()
        require('tinygit').push()
      end,
      desc = 'TinyGit: Push',
    },
    -- {
    --   '<leader>gf',
    --   function()
    --     require('tinygit').searchFileHistory()
    --   end,
    --   desc = 'TinyGit: Search File History',
    -- },
    -- {
    --   '<leader>gl',
    --   function()
    --     require('tinygit').lineHistory()
    --   end,
    --   desc = 'TinyGit: Line History',
    -- },
    {
      '<localleader>gF',
      function()
        require('tinygit').functionHistory()
      end,
      desc = 'TinyGit: Function History',
    },
    {
      '<localleader>ga',
      function()
        require('tinygit').amendNoEdit()
      end,
      desc = 'TinyGit: Amend (No Edit)',
    },
    {
      '<localleader>gA',
      function()
        require('tinygit').amendOnlyMsg()
      end,
      desc = 'TinyGit: Amend (Only Message)',
    },
    {
      '<localleader>gx',
      function()
        require('tinygit').fixupCommit()
      end,
      desc = 'TinyGit: Fixup Commit',
    },
  },
  dependencies = {
    { 'stevearc/dressing.nvim', lazy = true },
    { 'nvim-telescope/telescope.nvim', lazy = true },
    { 'rcarriga/nvim-notify', lazy = true },
  },
  config = function()
    require('tinygit').setup {
      historySearch = {
        diffPopup = {
          width = 0.8,
          height = 0.8,
          border = 'single',
        },
      },
    }
  end,
}
