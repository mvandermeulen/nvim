local M = {}

M.mappings = {
  ["<C-/>"] = { "<Plug>(comment_toggle_linewise_current)", "Comment Line" },
}

M.options = {
  mode = "n",
  silent = true,
  noremap = false,
  nowait = true,
}

return M

-- vim:ft=lua
