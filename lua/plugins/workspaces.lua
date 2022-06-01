--[[
-- Workspace Plugin
--
-- Author: Mark van der Meulen
-- Updated: 09-05-2022
--]]

require('workspaces').setup {
  path = vim.fn.expand(vim.fn.stdpath 'data' .. '/workspaces/'),
  global_cd = true,
  sort = true,
  notify_info = true,
  hooks = {
    open = function()
      require('sessions').load(nil, { silent = true })
    end,
  },
}

require('telescope').load_extension('workspaces')
