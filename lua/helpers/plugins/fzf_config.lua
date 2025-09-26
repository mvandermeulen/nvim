--[[
-- Helpers: FZF Config
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-15
--]]

local config = require("fzf-lua.config")
local actions = require('fzf-lua.actions')
local icons = require('helpers.ui.icons')


local fzf_custom_profile_name = "ivy"

local fzf_custom_paths_my_files = {
  ".config/nvim/config.lua",
  ".gitconfig",
  ".python_startup_local.py",
  ".zshrc",
  ".zshenv",
  "resources/configs/nvim",
  "resources/configs/shell_config",
  "resources/configs/scripts",
  "resources/configs/zsh_config/zsh.d",
  "resources/tmux",
  "resources/dots",
  "scripts",
  "projects",
  "code/100_PROJECTS",
}
local fzf_custom_paths_my_projects = {
  "resources/configs/scripts",
  "resources/configs/nvim",
  "resources/configs/shell_config",
  "resources/configs/zsh_config/zsh.d",
  "resources/tmux",
  "resources/dots",
  "projects",
  "scripts",
  "code/100_PROJECTS",
}
local fzf_custom_paths_all_configs = {
  my_files_config     = fzf_custom_paths_my_files,
  my_projects_config  = fzf_custom_paths_my_projects,
}

---------- FZF Options ----------
local fzf_global_fzf_opts = {
  ["--layout"]      = "default",
  ["--marker"]      = "+",
  ['--cycle']       = true,
  ["--highlight-line"] = true,
  ["--prompt"]      = "❯ ",
  ["--info"]        = "right",
  ["--border"]      = "rounded",
  ["--ansi"]        = true, -- enable ANSI color codes
}
local fzf_files_fzf_opts = {
  ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-files-history",
}
local fzf_grep_fzf_opts = {
  ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-grep-history",
}


---------- Previewers Config ----------
local fzf_previewers_config = {
  builtin = {
    syntax_limit_b = 1024 * 100, -- 100KB
  },
}

---------- Colourschemes ----------
-- see https://github.com/junegunn/fzf/wiki/Color-schemes#color-configuration
local fzf_colorschemes_config = {
  standard = {
    ["fg"]      = { "fg", "Normal" },
    ["bg"]      = { "bg", "Normal" },
    ["hl"]      = { "fg", "Comment" },
    ["fg+"]     = { "fg", "Normal" },
    ["bg+"]     = { "bg", "FzfLuaCurrentLine" },
    ["hl+"]     = { "fg", "Statement" },
    ["pointer"] = { "fg", "Normal" },
    ["marker"]  = { "fg", "Keyword" },
    ["gutter"]  = { "bg", "Normal" },
    ["border"]  = { "fg", 'FloatBorder' },
  },

}

---------- Ripgrep Config ----------
local rg_ignore_dirs = {
  ".git",
  ".*_cache",
  "postgres-data",
  "edgedb-data",
  ".vscode",
  "**/playground/*",
  "*.pyc",
  "**/__pycache__/*",
  "**.venv/*",
  "**venv/*",
  "**_oldvenv/*",
  "**/__snapshots__",
  "tests/data",
  "**/.dist/*",
  "**/.output/*",
  "**/node_modules/*",
}
local rg_ignore_files = { "*.min.css", "*.svg", "pnpm-lock.yaml", "package-lock.json", "edgedb.toml" }
local rg_ignore_arg = ("--glob '!{%s}' --glob '!{%s}'"):format(
  table.concat(rg_ignore_dirs, ","),
  table.concat(rg_ignore_files, ",")
)
local fzf_files_rg_cmd = "rg %s --color=never --files --hidden %s"
local fzf_files_custom_rg_cmd = "rg %s --color=never --files --hidden %s"

---------- Git Config ----------
local fzf_git_config = {
  icons = {
    ["M"] = { icon = icons.git.Mod, color = "yellow" },
    ["D"] = { icon = icons.git.RemoveAlt, color = "red" },
    ["A"] = { icon = icons.git.Add, color = "green" },
    ["R"] = { icon = icons.git.Rename, color = "yellow" },
    ["C"] = { icon = icons.git.Mod, color = "yellow" },
    ["T"] = { icon = icons.git.Mod, color = "magenta" },
    ["?"] = { icon = icons.git.Untrack, color = "magenta" },
  },
  status = {
    cmd = 'git status -su',
    winopts = {
      preview = { vertical = 'down:70%', horizontal = 'right:40%' },
    },
  },
}

---------- Window Options ----------
local fzf_window_configs = {
  large = {
    height = 0.9,
    width = 0.9,
    row = 0.5,
    col = 0.5,
    anchor = 'center',
    preview = {
      layout = 'horizontal',
      horizontal = 'right:50%',
    },
  },
  vertical = {
    height = 0.9,
    width = 0.8,
    row = 0.5,
    col = 0.5,
    anchor = 'center',
    preview = {
      layout = 'vertical',
      vertical = 'up:50%',
    },
  },
  fullscreen = {
    width = 1.0,
    height = 1.0,
    row = 0.0,
    col = 0.0,
    anchor = 'NW',
  },
  cursor = {
    relative = 'cursor',
    row = 1.01,
    col = 0,
    width = 0.2,
    height = 0.2,
  },
  custom = {
    border = "rounded",
    height = 0.80,
    width = 0.80,
    preview = {
      border = "rounded",
      layout = 'flex',
      flip_columns = 180,
      scrollbar = 'float',
      scrolloff = "-2",
      delay = 50,
    },
  },
}


---------- Keymaps ----------
local fzf_keymap_builtin = {
  ["<M-Esc>"]         = "hide",     -- hide fzf-lua, `:FzfLua resume` to continue
  ["<F1>"]            = "toggle-help",
  ["<F2>"]            = "toggle-fullscreen",
  ["<F3>"]            = "toggle-preview-wrap",
  ["<F4>"]            = "toggle-preview",
  -- ["<C-p>"]           = "toggle-preview",
  ['<M-f>']           = 'toggle-fullscreen',
  ["<S-down>"]        = "preview-page-down",
  ["<S-up>"]          = "preview-page-up",
  ["<PageDown>"]      = "preview-page-down",
  ["<PageUp>"]        = "preview-page-up",
  -- ['<M-d>'] = 'preview-page-down',
  -- ['<M-u>'] = 'preview-page-up',
  -- ['<M-k>'] = 'first',
  -- ['<M-j>'] = 'last',
}
local fzf_keymap_fzf = {
  ["ctrl-z"]      = "abort",
  ["ctrl-u"]      = "unix-line-discard",
  ['ctrl-r']      = 'select-all+accept',
  ["ctrl-f"]      = "half-page-down",
  ["ctrl-b"]      = "half-page-up",
  ["ctrl-a"]      = "beginning-of-line",
  ["ctrl-e"]      = "end-of-line",
  ["alt-a"]       = "toggle-all",
  ["alt-g"]       = "first",
  ["alt-G"]       = "last",
  -- Previews
  ["f3"]          = "toggle-preview-wrap",
  ["f4"]          = "toggle-preview",
  -- ["ctrl-f"]      = "preview-page-down",
  -- ["ctrl-b"]      = "preview-page-up",
  ["shift-down"]  = "preview-page-down",
  ["shift-up"]    = "preview-page-up",
  -- ["tab"]         = "down",
  -- ["shift-tab"]   = "up",
}

---------- LSP Document Symbols ----------
local fzf_lsp_document_symbols_actions = {
  ["default"] = actions.lsp_document_symbol_vsplit,
  ["ctrl-x"]  = actions.lsp_document_symbol_split,
  ["ctrl-v"]  = actions.lsp_document_symbol_vsplit,
  ["ctrl-t"]  = actions.lsp_document_symbol_tabedit,
}
local fzf_lsp_document_symbols_config = {
  prompt = "LSP Document Symbols> ",
  file_icons = true, -- show file icons?
  color_icons = true, -- colorize file|git icons
  ignore_current_buffer = false, -- ignore current buffer
  cwd_only = false, -- symbols for the cwd only
  cwd = nil, -- symbols list for a given dir
  -- disable filename matching
  fzf_cli_args = '--nth 2..',
  actions = fzf_lsp_document_symbols_actions,
}

---------- OldFiles ----------
local fzf_oldfiles_config = {
  prompt = "History> ",
  cwd_only = false,
  stat_file = true, -- verify files exist on disk
  include_current_session = true, -- include bufs from current session
}

---------- Tabs ----------
local tabs_fzf_actions = {
  -- actions inherit from 'actions.buffers' and merge
  -- ["default"] = actions.buf_switch,
  ["default"] = actions.resume,
  ["ctrl-x"] = { fn = actions.buf_del, reload = true },
}
local fzf_tabs_config = {
  prompt = "Tabs❯ ",
  tab_title = "Tab",
  tab_marker = "<<",
  -- current_tab_only = true, -- Only show buffers from current tab
  file_icons = true, -- show file icons?
  color_icons = true, -- colorize file|git icons
  actions = tabs_fzf_actions,
  -- fzf_opts = {
  --     -- hide tabnr
  --     ["--delimiter"] = "'[\\):]'",
  --     ["--with-nth"] = "2..",
  -- },
}

---------- Grep ----------
local grep_fzf_actions = {
  ["alt-i"]   = actions.toggle_ignore,
  ["alt-h"]   = actions.toggle_hidden,
}
local fzf_grep_config = {
  -- rg_opts = "--no-heading --line-number "
  --   .. "--column --smart-case --hidden "
  --   .. [[ --glob "!{**/.git/*,**/node_modules/*,**/package-lock.json,pnpm-lock.yaml,**/yarn.lock,.vscode-server,.virtualenvs}" ]],
  fzf_opts = fzf_grep_fzf_opts,
  -- disable filename matching
  fzf_cli_args = '--nth 2..',
  rg_opts = table.concat({
    "--column",
    "--line-number",
    "--no-heading",
    "--color=always",
    "--colors=line:fg:magenta",
    "--colors=column:fg:magenta",
    "--colors=path:fg:white",
    "--colors=match:fg:blue",
    "--smart-case",
    "--max-columns=4096",
    "--hidden",
    '--glob=!**/.local/**',
    '--glob=!**/.rustup/**',
    '--glob=!**/node_modules/**',
    '--glob=!**/.cargo/**',
    '--glob=!**/.continue/**',
    '--glob=!**/.mozilla/**',
    '--glob=!**/go/pkg/mod/**',
    '--glob=!**/Code/User/**',
    '--glob=!**/.git/**',
    '--glob=!**/.npm/**',
    '--glob=!**/.cache/**',
    "-e",
  }, " "),
  -- https://github.com/ibhagwan/fzf-lua/wiki#can-i-use-ripgreps---globiglob-option-with-live_grep
  rg_glob = true, -- enable glob parsing
  -- first returned string is the new search query
  -- second returned string are (optional) additional rg flags
  -- @return string, string?
  rg_glob_fn = function(query, opts)
    local regex, flags = query:match("^(.-)%s%-%-(.*)$")
    -- If no separator is detected will return the original query
    return (regex or query), flags
  end,
  glob_flag = "--iglob", -- case insensitive globs
  -- Ex: Find all occurrences of "enable" but only in the "plugins" directory.
  -- With this change, I can sort of get the same behaviour in live_grep.
  -- ex: > enable --*/plugins/*
  -- I still find this a bit cumbersome. There's probably a better way of doing this.
  glob_separator = "%s%-%-", -- query separator pattern (lua): ' --'
  actions = grep_fzf_actions,
}

---------- Files ----------
local file_fzf_actions = {
  ["enter"]   = actions.file_edit_or_qf,
  ['default'] = actions.file_edit_or_qf,
  ['ctrl-t']  = actions.file_tabedit,
  ['ctrl-x']  = actions.file_split,
  ['ctrl-v']  = actions.file_vsplit,
  ["alt-i"]   = actions.toggle_ignore,
  ["alt-h"]   = actions.toggle_hidden,
  ["alt-f"]   = actions.toggle_follow,
  ["ctrl-r"]  = function(_, ctx)
    local o = vim.deepcopy(ctx.__call_opts)
    o.root = o.root == false
    o.cwd = nil
    o.buf = ctx.__CTX.bufnr
    -- Utils.pick.open(ctx.__INFO.cmd, o)
  end
}
config.set_action_helpstr(file_fzf_actions["ctrl-r"], "toggle-root-dir")
file_fzf_actions["alt-c"] = file_fzf_actions["ctrl-r"]
local fzf_files_config = {
  prompt = "Files> ",
  multiprocess = true, -- run command in a separate process
  git_icons = true, -- show git icons?
  file_icons = false, -- show file icons?
  color_icons = false, -- colorize file|git icons
  -- cmd = table.concat({
  --   'fd --type f --hidden --follow',
  --   '--exclude .git',
  --   '--exclude node_modules',
  --   '--exclude .cargo',
  --   '--exclude .mozilla',
  --   '--exclude .cache',
  --   '--exclude .npm',
  --   '--exclude .rustup',
  --   '--exclude .dotnet',
  --   '--exclude go/pkg/mod',
  --   '--exclude Code/User',
  --   '--exclude .local',
  --   '--exclude .continue',
  -- }, ' '),
  fd_opts = '--color=never --type f --hidden --follow --exclude .git --exclude yarn.lock --exclude venv --exclude .venv',
  find_opts = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
  rg_opts = "--color=never --files --hidden --follow --glob '!{.git,.venv,venv}/*'",
  fzf_opts = fzf_files_fzf_opts,
  -- rg_opts = "--color=never --files --hidden --follow -g '!.git' -g '!.venv' -g '!venv'",
}

---------- Buffers ----------
local buffer_fzf_actions = {
  ['default'] = actions.buf_edit,
  ["enter"]   = actions.buf_edit,
  ['ctrl-x']  = actions.buf_split,
  ['ctrl-v']  = actions.buf_vsplit,
  ['ctrl-t']  = actions.buf_tabedit,
  ['ctrl-d']  = { actions.buf_del, actions.resume },
}
local buffer_fzf_keymap = {
  builtin = { ['<C-d>'] = false },
}
local fzf_buffers_config = {
  prompt = "Buffers> ",
  ignore_current_buffer = true,
  file_icons = true, -- show file icons?
  color_icons = true, -- colorize file|git icons
  sort_lastused = true, -- sort buffers() by last used
  show_unloaded = true, -- show unloaded buffers
  cwd_only = false, -- buffers for the cwd only
  cwd = nil, -- buffers list for a given dir
  keymap = buffer_fzf_keymap,
  actions = buffer_fzf_actions,
  -- actions = {
  --     -- actions inherit from 'actions.buffers' and merge
  --     -- by supplying a table of functions we're telling
  --     -- fzf-lua to not close the fzf window, this way we
  --     -- can resume the buffers picker on the same window
  --     -- eliminating an otherwise unaesthetic win "flash"
  --     ["ctrl-x"] = { fn = actions.buf_del, reload = true },
  -- },
}

---------- Defaults ----------
local fzf_global_defaults_config = {
  formatter = "path.dirname_first",
}

local M = {
  profile_name         = fzf_custom_profile_name,
  -- LSP Document Symbols
  lsp_document_symbols_actions = fzf_lsp_document_symbols_actions,
  lsp_document_symbols_config = fzf_lsp_document_symbols_config,
  -- OldFiles
  oldfiles_config       = fzf_oldfiles_config,
  -- Buffers
  buffers_actions       = buffer_fzf_actions,
  buffers_keymap        = buffer_fzf_keymap,
  buffers_config        = fzf_buffers_config,
  -- Tabs
  tabs_actions          = tabs_fzf_actions,
  tabs_config           = fzf_tabs_config,
  -- Grep
  grep_actions          = grep_fzf_actions,
  grep_config           = fzf_grep_config,
  -- Files
  files_actions         = file_fzf_actions,
  files_config          = fzf_files_config,
  files_rg_cmd          = fzf_files_rg_cmd,
  files_custom_rg_cmd   = fzf_files_custom_rg_cmd,
  -- Keymaps
  keymap_builtin        = fzf_keymap_builtin,
  keymap_fzf            = fzf_keymap_fzf,
  -- Defaults
  fzf_defaults_config  = fzf_global_defaults_config,
  -- FZF Opts Config
  global_fzf_opts       = fzf_global_fzf_opts,
  files_fzf_opts        = fzf_files_fzf_opts,
  grep_fzf_opts         = fzf_grep_fzf_opts,
  -- Window Options
  window_configs        = fzf_window_configs,
  -- Git Config
  git_config            = fzf_git_config,
  -- Ripgrep Config
  rg_ignore_arg         = rg_ignore_arg,
  rg_ignore_dirs        = rg_ignore_dirs,
  rg_ignore_files       = rg_ignore_files,
  -- Colorschemes
  colorschemes_config   = fzf_colorschemes_config,
  -- Previewers
  fzf_previewers_config = fzf_previewers_config,
  -- Custom Paths
  fzf_custom_paths      = fzf_custom_paths_all_configs,
}



return M
