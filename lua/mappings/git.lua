local M = {}

M.mappings = {
  ["name"] = " Git",
  -- ["name"] = " Git",
  ["b"] = { '<cmd>Telescope git_branches<cr>', 'Checkout branch' },
  ["B"] = { "<CMD>lua require 'gitsigns'.blame_line()<CR>", "Show Blame" },
  ["c"] = { '<cmd>Telescope git_commits<cr>', 'Checkout commit' },
  ["C"] = { '<cmd>Telescope git_bcommits<cr>', 'Checkout commit(for current file)' },
  ["g"] = { '<cmd>Telescope git_status<cr>', 'Git Status' },
  ["G"] = { "<cmd>lua _GITUI_TOGGLE()<cr>i", "GitUI" },
  ["h"] = { "<cmd>:Gitsigns toggle_linehl<cr>", 'Toggle Highlight' },
  ["j"] = { "<CMD>lua require 'gitsigns'.next_hunk()<CR>", " Next Hunk" },
  ["k"] = { "<CMD>lua require 'gitsigns'.prev_hunk()<CR>", " Prev Hunk" },
  ["L"] = { "<cmd>lua _LAZYGIT_TOGGLE()<cr>i", " Lazygit" },
  ["p"] = { "<CMD>lua require 'gitsigns'.preview_hunk()<CR>", " Preview Hunk" },
  ["n"] = { '<cmd>Neogit<cr>', 'Neogit' },
  ["t"] = { "<cmd>:Gitsigns toggle_signs<cr>", 'Toggle Signs' },-- Should this be moved to some kind of UI menu?
  ["r"] = { "<CMD>lua require 'gitsigns'.reset_hunk()<CR>", "ﰇ Reset Hunk" },
  ["R"] = { "<CMD>lua require 'gitsigns'.reset_buffer()<CR>", " Reset Buffer" },
  ["s"] = { "<CMD>lua require 'gitsigns'.stage_hunk()<CR>", "ﴽ Stage Hunk" },
  ["u"] = {
    "<CMD>lua require 'gitsigns'.undo_stage_hunk()<CR>",
    " Undo Stage Hunk",
  },
  ["d"] = {
    "<CMD>Gitsigns diffthis HEAD<CR>",
    " Diff",
  },
}

M.options = {
  mode = "n",
  silent = true,
  noremap = true,
  prefix = "<leader>g",
  nowait = false,
}

return M

-- vim:ft=lua
