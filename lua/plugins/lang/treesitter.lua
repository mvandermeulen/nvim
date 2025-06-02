--[[
-- Treesitter Configuration
--
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]


local log = require('plenary.log').new({ plugin = 'mason', level = 'debug', use_console = true })
local function mylog(msg, level)
  local level = level or 'debug'
  log.debug(msg)
  if level == 'info' or level == 'warn' or level == 'error' then
    vim.notify(msg, vim.log.levels.INFO, { title = 'Mason' })
  end
end

local status_ok, configs = pcall(require, 'nvim-treesitter.configs')
if not status_ok then
  mylog('Treesitter not found', 'error')
  return
end

local ts_parsers_ok, tsconfig = pcall(require, 'config.treesitter')
if not ts_parsers_ok then
  mylog('Treesitter parsers not found', 'error')
  return
end

--[[ local ft_to_parser = require('nvim-treesitter.parsers').filetype_to_parsername ]]
--[[ ft_to_parser.motoko = 'typescript' ]]

configs.setup {
  ensure_installed = tsconfig.installed,
  query_linter = {
    enable = true,
    use_virtual_text = true,
    lint_events = { 'BufWrite' },
    -- lint_events = { 'BufWrite', 'CursorHold' },
  },
  sync_install = true,
  auto_install = true,
  ignore_install = {}, -- List of parsers to ignore installing
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = function(_, buf) -- function(lang, buf)
      -- Disable in large number of line
      local max_n_lines = 20000
      if vim.api.nvim_buf_line_count(buf) > max_n_lines then
          return true
      end

      -- Disable in large buffer size
      local max_filesize = 100 * 1024 -- 100 KB
      ---@diagnostic disable-next-line: undefined-field
      local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
          return true
      end
    end,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  indent = { enable = true, disable = { 'css' } },
  autopairs = { { enable = true } },
  autotag = {
    enable = true,
    disable = { 'xml' },
  },
  textobjects = {
    select = {
      enable = true,
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
        ['al'] = '@loop.outer',
        ['il'] = '@loop.inner',
        ['ib'] = '@block.inner',
        ['ab'] = '@block.outer',
        ['ir'] = '@parameter.inner',
        ['ar'] = '@parameter.outer',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']f'] = '@function.outer',
        [']m'] = '@class.outer',
        [']o'] = '@parameter.outer',
        -- [']]'] = '@block.outer',
        [']b'] = '@block.outer',
        [']a'] = '@call.outer',
        [']/'] = '@comment.outer',
      },
      goto_next_end = {
        [']F'] = '@function.outer',
        [']M'] = '@class.outer',
        [']O'] = '@parameter.outer',
        -- [']['] = '@block.outer',
        [']B'] = '@block.outer',
        [']A'] = '@call.outer',
        [']\\'] = '@comment.outer',
      },
      goto_previous_start = {
        ['[f'] = '@function.outer',
        ['[m'] = '@class.outer',
        ['[o'] = '@parameter.outer',
        -- ['[['] = '@block.outer',
        ['[b'] = '@block.outer',
        ['[a'] = '@call.outer',
        ['[/'] = '@comment.outer',
      },
      goto_previous_end = {
        ['[F'] = '@function.outer',
        ['[M'] = '@class.outer',
        ['[O'] = '@parameter.outer',
        -- ['[]'] = '@block.outer',
        ['[B'] = '@block.outer',
        ['[A'] = '@call.outer',
        ['[\\'] = '@comment.outer',
      },
    },
  },
  rainbow = {
    enable = true,
    extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
    max_file_lines = 2000, -- Do not enable for files with more than specified lines
    termcolors = { '3', '4', '1', '3', '4', '1', '3', '4' },
  },
  playground = {
    enable = true,
  },
  matchup = {
    enable = true,
  },
}

-- mylog('Treesitter loaded')
