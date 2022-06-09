local M = {}

M.mappings = {
  ["name"] = " Git",
  ["b"] = { '<cmd>Telescope git_branches<cr>', 'Checkout branch' },
  ["c"] = { '<cmd>Telescope git_commits<cr>', 'Checkout commit' },
  ["C"] = { '<cmd>Telescope git_bcommits<cr>', 'Checkout commit(for current file)' },
  ["g"] = { '<cmd>Telescope git_status<cr>', 'Open changed file' },
  ["j"] = { "<CMD>lua require 'gitsigns'.next_hunk()<CR>", " Next Hunk" },
  ["k"] = { "<CMD>lua require 'gitsigns'.prev_hunk()<CR>", " Prev Hunk" },
  ["l"] = { "<CMD>lua require 'gitsigns'.blame_line()<CR>", " Blame" },
  ["p"] = { "<CMD>lua require 'gitsigns'.preview_hunk()<CR>", " review Hunk" },
  ["n"] = { '<cmd>Neogit<cr>', 'Open Neogit' },
  ["t"] = 'Open Gitui', -- comand in toggleterm.lua
  ["T"] = { '<cmd>GitBlameToggle<cr>', 'Toggle Blame' },-- Should this be moved to some kind of UI menu?
  ["r"] = { "<CMD>lua require 'gitsigns'.reset_hunk()<CR>", "ﰇ Reset Hunk" },
  ["R"] = { "<CMD>lua require 'gitsigns'.reset_buffer()<CR>", " Reset Buffer" },
  ["s"] = { "<CMD>lua require 'gitsigns'.stage_hunk()<CR>", "ﴽ Stage Hunk" },
  ["u"] = {
    "<CMD>lua require 'gitsigns'.undo_stage_hunk()<CR>",
    " Undo Stage Hunk",
  },
  ["h"] = { "<CMD>GitHL<CR>", " Highlight number column" },
  ["d"] = {
    "<CMD>Gitsigns diffthis HEAD<CR>",
    " Diff",
  },
  -- ["L"] = { "<CMD>lua require('utils.terminals')._LAZYGIT_TOGGLE()<CR>", " Lazygit" },
  ["L"] = { "<cmd>lua _LAZYGIT_TOGGLE()<CR>", " Lazygit" },
}

M.options = {
  mode = "n",
  silent = true,
  noremap = true,
  prefix = "<leader><leader>",
  nowait = false,
}

return M

-- vim:ft=lua
