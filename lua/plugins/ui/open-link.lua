--[[
-- Open Link Plugin
-- Author: Mark van der Meulen
-- Updated: 2025-10-16
--]]


-- Link: https://github.com/elentok/open-link.nvim

return {
  'elentok/open-link.nvim',
  init = function()
    local expanders = require 'open-link.expanders'
    require('open-link').setup {
      expanders = {
        -- expands "{user}/{repo}" to the github repo URL
        expanders.github,

        -- expands "format-on-save#15" the issue/pr #15 in the specified github project
        -- ("format-on-save" is the shortcut/keyword)
        expanders.github_issue_or_pr('format-on-save', 'elentok/format-on-save.nvim'),

        -- expands "MYJIRA-1234" and "myotherjira-1234" to the specified Jira URL
      },
    }
  end,
  cmd = { 'OpenLink', 'PasteImage' },
  keys = {
    {
      '<leader>vl',
      '<cmd>OpenLink<cr>',
      desc = ' Open link under the cursor',
    },
    {
      '<leader>Ii',
      '<cmd>PasteImage<cr>',
      desc = ' Paste image from clipboard',
    },
  },
}
