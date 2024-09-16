--[[
-- Treesitter Configuration
--
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]

local status_ok, configs = pcall(require, 'nvim-treesitter.configs')
if not status_ok then
  return
end

local ts_parsers_ok, tsconfig = pcall(require, 'config.treesitter')
if not ts_parsers_ok then
  return
end

--[[ local ft_to_parser = require('nvim-treesitter.parsers').filetype_to_parsername ]]
--[[ ft_to_parser.motoko = 'typescript' ]]

configs.setup {
  ensure_installed = tsconfig.installed,
  query_linter = {
    enable = true,
    use_virtual_text = true,
    lint_events = { 'BufWrite', 'CursorHold' },
  },
  sync_install = true,
  auto_install = true,
  ignore_install = {}, -- List of parsers to ignore installing
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = {}, -- list of language that will be disabled
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
        [']p'] = '@parameter.outer',
        [']]'] = '@block.outer',
        [']b'] = '@block.outer',
        [']a'] = '@call.outer',
        [']/'] = '@comment.outer',
      },
      goto_next_end = {
        [']F'] = '@function.outer',
        [']M'] = '@class.outer',
        [']P'] = '@parameter.outer',
        [']['] = '@block.outer',
        [']B'] = '@block.outer',
        [']A'] = '@call.outer',
        [']\\'] = '@comment.outer',
      },
      goto_previous_start = {
        ['[f'] = '@function.outer',
        ['[m'] = '@class.outer',
        ['[p'] = '@parameter.outer',
        ['[['] = '@block.outer',
        ['[b'] = '@block.outer',
        ['[a'] = '@call.outer',
        ['[/'] = '@comment.outer',
      },
      goto_previous_end = {
        ['[F'] = '@function.outer',
        ['[M'] = '@class.outer',
        ['[P'] = '@parameter.outer',
        ['[]'] = '@block.outer',
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
  },
  playground = {
    enable = true,
  },
  matchup = {
    enable = true,
  },
}
