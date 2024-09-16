local M = {}

M.mappings = {
  name = 'Treesitter',
  c = { '<cmd>:TSContextToggle<cr>', 'Treesitter Context Toggle' },
  h = { '<cmd>TSHighlightCapturesUnderCursor<cr>', 'Highlight' },
  p = { '<cmd>TSPlaygroundToggle<cr>', 'Playground' },
}

M.options = {
  mode = "n",
  silent = true,
  noremap = true,
  prefix = "<leader>/",
  nowait = true,
}

return M
