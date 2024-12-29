local M = {}

M.mappings = {
  name = 'Window',
  p = { '<c-w>x', 'Swap' },
  q = { '<cmd>:q<cr>', 'Close' },
  s = { '<cmd>:new<cr>', 'Empty Horizontal Split' },
  S = { '<cmd>:split<cr>', 'Horizontal Split' },
  t = { '<cmd>:tabnew<cr>', 'New Tab' },
  l = { '<CMD>tablast<CR>', ' Last Tab' },
  f = { '<CMD>tabfirst<CR>', ' First Tab' },
  r = { '<CMD>tabrewind<CR>', ' Rewind' },
  ['='] = { '<c-w>=', 'Equally size' },
  v = { '<cmd>:vnew<cr>', 'Empty Vertical Split' },
  V = { '<cmd>:vsplit<cr>', 'Vertical Split' },
  w = { "<cmd>lua require('nvim-window').pick()<cr>", 'Choose window to jump' },
}

--[[ M.options = { ]]
--[[   mode = "n", ]]
--[[   silent = true, ]]
--[[   noremap = true, ]]
--[[   prefix = "<leader>/", ]]
--[[   nowait = true, ]]
--[[ } ]]

return M



