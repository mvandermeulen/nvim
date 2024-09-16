local M = {}

M.mappings = {
  name = 'Window',
  p = { '<c-w>x', 'Swap' },
  q = { '<cmd>:q<cr>', 'Close' },
  s = { '<cmd>:new<cr>', 'Empty Horizontal Split' },
  S = { '<cmd>:split<cr>', 'Horizontal Split' },
  t = { '<cmd>:tabnew<cr>', 'New Tab' },
  T = { '<c-w>t', 'Move to new tab' },
  ['='] = { '<c-w>=', 'Equally size' },
  v = { '<cmd>:vnew<cr>', 'Empty Vertical Split' },
  V = { '<cmd>:vsplit<cr>', 'Vertical Split' },
  w = {
    "<cmd>lua require('nvim-window').pick()<cr>",
    'Choose window to jump',
  },
}

--[[ M.options = { ]]
--[[   mode = "n", ]]
--[[   silent = true, ]]
--[[   noremap = true, ]]
--[[   prefix = "<leader>/", ]]
--[[   nowait = true, ]]
--[[ } ]]

return M



