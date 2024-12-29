return {
  'tomasky/bookmarks.nvim',
  event = 'FileType',
  keys = {
    { '<leader>Mbt', function() require('bookmarks').bookmark_toggle() end, desc = 'Toggle mark' },
    { '<leader>Mba', function() require('bookmarks').bookmark_ann() end, desc = 'Annotate mark' },
    { '<leader>Mb<BS>', function() require('bookmarks').bookmark_clean() end, desc = 'Clean buffer marks' },
    { '<leader>Mb]', function() require('bookmarks').bookmark_next() end, desc = 'Jump to next mark' },
    { '<leader>Mb[', function() require('bookmarks').bookmark_prev() end, desc = 'Jump to previous mark' },
    { '<leader>Mbl', function() require('bookmarks').bookmark_list() end, desc = 'List marks' },
    { '<leader>Mbr', function() require('bookmarks').bookmark_clear_all() end, desc = 'Remove all marks' },
  },
  opts = {
    save_file = vim.fn.stdpath('state') .. '/bookmarks.json',
    keywords = {
      ['@t'] = ' ',
      ['@w'] = ' ',
      ['@f'] = '⛏ ',
      ['@n'] = ' ',
    },
  }
}
