--[[
-- Plugin: gitsigns
--
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]

require("gitsigns").setup {
  -- signs = {
  --   add = { hl = "GitSignsAdd", text = "+", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
  --   change = { hl = "GitSignsChange", text = "│", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
  --   delete = { hl = "GitSignsDelete", text = "_", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
  --   topdelete = { hl = "GitSignsDelete", text = "‾", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
  --   changedelete = { hl = "GitSignsChange", text = "~", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" }
  -- },
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = true, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {interval = 1000, follow_files = true},
  attach_to_untracked = true,
  -- git-blame provides also the time in contrast to gitsigns
  current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
  -- current_line_blame_formatter_opts = {relative_time = false},
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000,
  preview_config = {
    -- Options passed to nvim_open_win
    border = "single",
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 1
  },
  diff_opts = {internal = true},
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    map({'n', 'v'}, '<localleader>hs', ':Gitsigns stage_hunk<CR>')
    map({'n', 'v'}, '<localleader>hr', ':Gitsigns reset_hunk<CR>')
    map('n', '<localleader>hS', gs.stage_buffer)
    map('n', '<localleader>hu', gs.undo_stage_hunk)
    map('n', '<localleader>hR', gs.reset_buffer)
    map('n', '<localleader>hp', gs.preview_hunk)
    map('n', '<localleader>hb', function() gs.blame_line{full=true} end)
    map('n', '<localleader>tb', gs.toggle_current_line_blame)
    map('n', '<localleader>hd', gs.diffthis)
    map('n', '<localleader>hD', function() gs.diffthis('~') end)
    map('n', '<localleader>td', gs.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}
