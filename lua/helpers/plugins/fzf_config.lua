--[[
-- Helpers: FZF Config
--
-- Author: Mark van der Meulen
-- Updated: 2025-06-10
--]]

local actions = require('fzf-lua.actions')

local M = {
  oldfiles = {
      prompt = "History> ",
      cwd_only = false,
      stat_file = true, -- verify files exist on disk
      include_current_session = true, -- include bufs from current session
  },
  buffers = {
      prompt = "Buffers> ",
      ignore_current_buffer = true,
      file_icons = true, -- show file icons?
      color_icons = true, -- colorize file|git icons
      sort_lastused = true, -- sort buffers() by last used
      show_unloaded = true, -- show unloaded buffers
      cwd_only = false, -- buffers for the cwd only
      cwd = nil, -- buffers list for a given dir
      keymap = { builtin = { ['<C-d>'] = false } },
      actions = { ['ctrl-x'] = false, ['ctrl-d'] = { actions.buf_del, actions.resume } },
      -- actions = {
      --     -- actions inherit from 'actions.buffers' and merge
      --     -- by supplying a table of functions we're telling
      --     -- fzf-lua to not close the fzf window, this way we
      --     -- can resume the buffers picker on the same window
      --     -- eliminating an otherwise unaesthetic win "flash"
      --     ["ctrl-x"] = { fn = actions.buf_del, reload = true },
      -- },
  },
  tabs = {
      prompt = "Tabs❯ ",
      tab_title = "Tab",
      tab_marker = "<<",
      -- current_tab_only = true, -- Only show buffers from current tab
      file_icons = true, -- show file icons?
      color_icons = true, -- colorize file|git icons
      actions = {
          -- actions inherit from 'actions.buffers' and merge
          ["default"] = actions.buf_switch,
          ["default"] = actions.resume,
          ["ctrl-x"] = { fn = actions.buf_del, reload = true },
      },
      -- fzf_opts = {
      --     -- hide tabnr
      --     ["--delimiter"] = "'[\\):]'",
      --     ["--with-nth"] = "2..",
      -- },
  },
  grep = {
    rg_opts = "--no-heading --line-number "
        .. "--column --smart-case --hidden "
        .. [[ --glob "!{**/.git/*,**/node_modules/*,**/package-lock.json,pnpm-lock.yaml,**/yarn.lock,.vscode-server,.virtualenvs}" ]],
  },
  files = {
    prompt = "Files> ",
    multiprocess = true, -- run command in a separate process
    git_icons = true, -- show git icons?
    file_icons = true, -- show file icons?
    color_icons = true, -- colorize file|git icons
    fd_opts = '--color=never --type f --hidden --follow --exclude .git --exclude yarn.lock --exclude venv --exclude .venv',
    find_opts = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
    rg_opts = "--color=never --files --hidden --follow --glob '!{.git,.venv,venv}/*'",
    -- rg_opts = "--color=never --files --hidden --follow -g '!.git' -g '!.venv' -g '!venv'",
  },
}

return M
