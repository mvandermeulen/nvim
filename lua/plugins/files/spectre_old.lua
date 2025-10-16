return {
  'nvim-pack/nvim-spectre',
  event = 'BufReadPost',
  keys = {
    {
      '<leader>S',
      function()
        require('spectre').toggle()
      end,
      desc = 'Toggle Spectre',
      mode = 'n',
    },
    {
      '<leader>si',
      function()
        require('spectre').open_visual { select_word = true }
      end,
      desc = 'Search current word',
      mode = 'n',
    },
    {
      '<leader>si',
      function()
        vim.cmd 'normal! <Esc>'
        require('spectre').open_visual()
      end,
      desc = 'Search current word',
      mode = 'v',
    },
    {
      '<leader>sp',
      function()
        require('spectre').open_file_search { select_word = true }
      end,
      desc = 'Search on current file',
      mode = 'n',
    },
  },
}
