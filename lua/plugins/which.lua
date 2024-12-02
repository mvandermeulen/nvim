--[[
-- Which Key Menu
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]

-- disable v
-- local presets = require("which-key.plugins.presets")
-- presets.operators["v"] = nil
local status_ok, which_key = pcall(require, 'which-key')
if not status_ok then
  return
end

local default_options = { noremap = true, silent = true }

local opts = { prefix = '<leader>', mode = 'n', default_options }
local localopts = { prefix = '<localleader>', mode = 'n', default_options }

local m_opts = {
  mode = 'n', -- NORMAL mode
  prefix = 'm',
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

local vopts = {
  mode = 'v', -- VISUAL mode
  prefix = '<leader>',
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

local setup = {
  plugins = {
    marks = true, -- shows a list of your marks on ' and `
    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
    },
    presets = {
      operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
      motions = false, -- adds help for motions
      text_objects = true, -- help for text objects triggered after entering an operator
      windows = true, -- default bindings on <c-w>
      nav = true, -- misc bindings to work with windows
      z = true, -- bindings for folds, spelling and others prefixed with z
      g = true, -- bindings for prefixed with g
    },
  },
  operators = { gc = 'Comments' },
  key_labels = {
    -- override the label used to display some keys. It doesn't effect WK in any other way.
    -- For example:
    -- ["<space>"] = "SPC",
    -- ["<cr>"] = "RET",
    -- ["<tab>"] = "TAB",
  },
  icons = {
    breadcrumb = '»', -- symbol used in the command line area that shows your active key combo
    separator = '➜', -- symbol used between a key and it's label
    group = '', -- symbol prepended to a group
  },
  window = {
    border = 'none', -- none, single, double, shadow
    position = 'bottom', -- bottom, top
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
    winblend = 30,
  },
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
    align = 'left', -- align columns left, center or right
  },
  ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
  hidden = {
    '<silent>',
    '<cmd>',
    '<Cmd>',
    '<cr>',
    '<CR>',
    'call',
    'lua',
    'require',
    '^:',
    '^ ',
  }, -- hide mapping boilerplate
  show_help = true, -- show help message on the command line when the popup is visible
  triggers = 'auto', -- automatically setup triggers
  -- triggers = {"<leader>"} -- or specify a list manually
  triggers_blacklist = {
    -- list of mode / prefixes that should never be hooked by WhichKey
    -- this is mostly relevant for key maps that start with a native binding
    -- most people should not need to change this
    i = { 'j', 'k' },
    v = { 'j', 'k' },
  },
}

local non_leader_mappings = {
  ga = { '<Plug>(EasyAlign)', 'Align', mode = 'x' },
  sa = 'Add surrounding',
  sd = 'Delete surrounding',
  sh = 'Highlight surrounding',
  sr = 'Replace surrounding',
  sF = 'Find left surrounding',
  sf = 'Replace right surrounding',
  sn = '# of lines to search for surrounding',
  ss = { '<Plug>Lightspeed_s', 'Search 2-character forward' },
}

local m_mappings = {
  a = { '<cmd>BookmarkAnnotate<cr>', 'Annotate' },
  c = { '<cmd>BookmarkClear<cr>', 'Clear' },
  m = { '<cmd>BookmarkToggle<cr>', 'Toggle' },
  h = { '<cmd>lua require("harpoon.mark").add_file()<cr>', 'Harpoon' },
  j = { '<cmd>BookmarkNext<cr>', 'Next' },
  k = { '<cmd>BookmarkPrev<cr>', 'Prev' },
  s = {
    '<cmd>lua require(\'telescope\').extensions.vim_bookmarks.all({ hide_filename=false, prompt_title="bookmarks", shorten_path=false })<cr>',
    'Show',
  },
  x = { '<cmd>BookmarkClearAll<cr>', 'Clear All' },
  u = { '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>', 'Harpoon UI' },
}

local mappings = {
  ['<Tab>'] = { '<cmd>e#<cr>', 'Switch to previously opened buffer' },
  ['e'] = { '<cmd>NvimTreeToggle<cr>', 'Explorer' },
  ['q'] = { '<cmd>NvimTreeClose<cr>:q<cr>', 'Quit Tab' },
  ['x'] = { ':TSContextDisable<cr>:TSBufDisable rainbow<cr>:TSBufDisable highlight<cr><cmd>Bdelete<cr>', 'Close Buffer' },
  -- ['/'] = { '<Plug>(comment_toggle_linewise_current)', 'Comment' },
  --[[ ['/'] = { '<cmd>lua require("Comment.api").toggle_current_linewise()<CR>', 'Comment' }, ]]
  --["R"] = { '<cmd>lua require("renamer").rename()<cr>', "Rename" },
  a = require('mappings.applications').mappings,
  b = {
    name = 'Buffers',
    b = {
      "<cmd>lua require'telescope.builtin'.buffers({ sort_mru = true, ignore_current_buffer = true })<cr>",
      'Find buffer',
    },
    a = { '<cmd>BufferLineCloseLeft<cr><cmd>BufferLineCloseRight<cr>', 'Close all but the current buffer' },
    d = { '<cmd>Bdelete!<CR>', 'Close Buffer' },
    f = { '<cmd>BufferLinePick<cr>', 'Pick buffer' },
    l = { '<cmd>BufferLineCloseLeft<cr>', 'Close all buffers to the left' },
    p = { '<cmd>BufferLineMovePrev<cr>', 'Move buffer prev' },
    n = { '<cmd>BufferLineMoveNext<cr>', 'Move buffer next' },
    r = { '<cmd>BufferLineCloseRight<cr>', 'Close all BufferLines to the right' },
    x = { '<cmd>BufferLineSortByDirectory<cr>', 'Sort BufferLines automatically by directory' },
    L = { '<cmd>BufferLineSortByExtension<cr>', 'Sort BufferLines automatically by extension' },
    s = { '<cmd>noautocmd w<CR>', 'Save (no autocmd)' },
  },
  C = { '<cmd>:Cheatsheet<cr>', 'Cheatsheet' },
  d = require('mappings.diagnostics').mappings,
  f = require('mappings.files').mappings,
  g = require('mappings.git').mappings,
  h = require('mappings.harpoon').mappings,
  l = {
    name = ' LSP',
    A = { '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', 'Add Workspace Folder' },
    D = { '<cmd>tab split | lua vim.lsp.buf.declaration()<cr>', 'Go To Declaration' },
    F = { '<cmd>LspToggleAutoFormat<cr>', 'Toggle Autoformat' },
    I = { '<cmd>lua vim.lsp.buf.implementation()<cr>', 'Show implementations' },
    K = { '<cmd>lua vim.lsp.buf.hover()<cr>', 'Hover Commands' },
    L = { '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>', 'List Workspace Folders' },
    R = { '<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename' },
    S = { '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', 'Workspace Symbols' },
    W = { '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', 'Remove Workspace Folder' },
    a = { '<cmd>lua vim.lsp.buf.code_action()<cr>', 'Code Action' },
    d = { '<cmd>tab split | lua vim.lsp.buf.definition()<cr>', 'Go To Definition' },
    e = { '<cmd>Telescope diagnostics bufnr=0<cr>', 'Document Diagnostics' },
    f = { '<cmd>lua vim.lsp.buf.formatting()<cr>', 'Format' },
    h = { '<cmd>lua vim.lsp.buf.signature_help()<cr>', 'Signature Help' },
    j = { '<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>', 'Next Diagnostic in Buffer' },
    k = { '<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>', 'Prev Diagnostic in Buffer' },
    l = { '<cmd>lua vim.diagnostic.open_float()<CR>', 'Line diagnostics' },
    n = { '<cmd>lua vim.diagnostic.goto_next()<cr>', 'Next Diagnostic' },
    p = { '<cmd>lua vim.diagnostic.goto_prev()<cr>', 'Prev Diagnostic' },
    q = { '<cmd>lua vim.diagnostic.set_loclist()<cr>', 'Quickfix' },
    r = { '<cmd>lua vim.lsp.buf.references()<cr>', 'References' },
    s = { '<cmd>Telescope lsp_document_symbols<cr>', 'Document Symbols' },
    t = { '<cmd>lua vim.lsp.buf.type_definition()<cr>', 'Type Definition' },
    w = { '<cmd>Telescope diagnostics<cr>', 'Workspace Diagnostics' },
  },
  L = { '<cmd>:Lazy<cr>', 'Lazy' },
  m = require('mappings.misc').mappings,
  o = { '<cmd>SymbolsOutline<cr>', 'Symbols Outline' },
  s = require('mappings.search').mappings,
  -- S = require('mappings.settings').mappings,
  t = require('mappings.terminal').mappings,
  T = require('mappings.telescope').mappings,
  w = require('mappings.window').mappings,
  W = require('mappings.workspace').mappings,
  -- z = require('mappings.focus').mappings,
}

local avante_mappings = {
    { "<leader>aa", '<ESC><CMD>AvanteAsk<CR>', desc = "Avante Ask", mode = "n", nowait = true, remap = false },
}


local yank_mappings = {
    { "<leader>y", '<ESC><CMD>YankBank<CR>', desc = "Yank Bank", mode = "n", nowait = true, remap = false },
}


local vmappings = {
  ['/'] = { '<ESC><CMD>lua require("Comment.api").toggle_linewise_op(vim.fn.visualmode())<CR>', 'Comment' },
  s = { "<esc><cmd>'<,'>SnipRun<cr>", 'Run range' },
}

which_key.setup(setup)
which_key.register(non_leader_mappings) -- register non leader based mappings
which_key.register(mappings, opts)
which_key.register(avante_mappings, opts)
which_key.register(yank_mappings, opts)
which_key.register(vmappings, vopts)
--which_key.register(m_mappings, m_opts)


