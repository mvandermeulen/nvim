if vim.g.started_by_firenvim then
  vim.g.firenvim_config = {
    globalSettings = {
      alt = 'all',
    },

    localSettings = {
      -- Don't turn firenvim on by default
      ['.*'] = {
        takeover = 'never',
      },
      ['https?://github.com/.*'] = {
        cmdline = 'firenvim',
        priority = 0,
        takeover = 'always',
      },
   }
  }
end


