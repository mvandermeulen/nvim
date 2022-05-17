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
    group = '+', -- symbol prepended to a group
  },
  window = {
    border = 'none', -- none, single, double, shadow
    position = 'bottom', -- bottom, top
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
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
  ['/'] = { '<cmd>lua require("Comment.api").toggle_current_linewise()<CR>', 'Comment' },
  --["R"] = { '<cmd>lua require("renamer").rename()<cr>', "Rename" },
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
  c = {
    name = 'Clipboard',
    s = { '<cmd>lua require("neoclip").start()', 'Start Clipboard Recording' },
    p = { '<cmd>lua require("neoclip").pause()', 'Pause Clipboard Recording' },
    t = { '<cmd>lua require("neoclip").toggle()', 'Toggle Clipboard Recording' },
    -- t = { '<cmd>lua require("neoclip").toggle()', 'Toggle Clipboard Recording' },
  },
  d = {
    name = 'Diagnostics',
    d = { '<cmd>Trouble document_diagnostics<cr>', 'Document Diagnostic' },
    i = { '<cmd>LspInstallInfo<cr>', 'LSP Install Info' },
    l = { '<cmd>Trouble loclist<cr>', 'Loclist' },
    q = { '<cmd>Trouble quickfix<cr>', 'Quickfix' },
    r = { '<cmd>Trouble lsp_references<cr>', 'LSP References' },
    t = { '<cmd>TodoTrouble<cr>', 'Todos' },
    T = { '<cmd>TroubleToggle<cr>', 'Toggle Trouble' },
    w = { '<cmd>Trouble workspace_diagnostics<cr>', 'Workspace Diagnostics' },
  },
  f = {
    name = 'Files',
    b = { '<cmd>Telescope file_browser<cr>', 'File browser' },
    f = {
      "<cmd>lua require'telescope.builtin'.find_files({ find_command = {'fd', '--hidden', '--type', 'file', '--follow'}})<cr>",
      'Find File',
    },
    p = { '<cmd>NvimTreeToggle<cr>', 'Toogle Tree' },
    r = { '<cmd>Telescope oldfiles<cr>', 'Open Recent File' },
    T = { '<cmd>NvimTreeFindFile<CR>', 'Find in Tree' },
  },
  F = {
    name = 'Find',
    b = { '<cmd>Telescope git_branches<cr>', 'Checkout branch' },
    c = { '<cmd>Telescope colorscheme<cr>', 'Colorscheme' },
    f = {
      "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>",
      'Find files',
    },
    t = { '<cmd>Telescope live_grep theme=ivy<cr>', 'Find Text' },
    h = { '<cmd>Telescope help_tags<cr>', 'Help' },
    i = { "<cmd>lua require('telescope').extensions.media_files.media_files()<cr>", 'Media' },
    l = { '<cmd>Telescope resume<cr>', 'Last Search' },
    M = { '<cmd>Telescope man_pages<cr>', 'Man Pages' },
    r = { '<cmd>Telescope oldfiles<cr>', 'Recent File' },
    R = { '<cmd>Telescope registers<cr>', 'Registers' },
    k = { '<cmd>Telescope keymaps<cr>', 'Keymaps' },
    C = { '<cmd>Telescope commands<cr>', 'Commands' },
  },
  g = {
    name = 'Git',
    b = { '<cmd>Telescope git_branches<cr>', 'Checkout branch' },
    B = { '<cmd>GitBlameToggle<cr>', 'Toggle Blame' },
    c = { '<cmd>Telescope git_commits<cr>', 'Checkout commit' },
    C = { '<cmd>Telescope git_bcommits<cr>', 'Checkout commit(for current file)' },
    d = { '<cmd>Gitsigns diffthis HEAD<cr>', 'Diff' },
    g = { '<cmd>Telescope git_status<cr>', 'Open changed file' },
    j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", 'Next Hunk' },
    k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", 'Prev Hunk' },
    l = { '<cmd>lua _LAZYGIT_TOGGLE()<CR>', 'Lazygit' },
    n = { '<cmd>Neogit<cr>', 'Open Neogit' },
    p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", 'Preview Hunk' },
    r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", 'Reset Hunk' },
    R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", 'Reset Buffer' },
    s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", 'Stage Hunk' },
    t = 'Open Gitui', -- comand in toggleterm.lua
    u = { "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", 'Undo Stage Hunk' },
  },
  h = {
    name = 'Harpoon',
    a = { "<cmd>lua require('harpoon.mark').add_file()<cr>", 'Add file' },
    u = { "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", 'Open Menu' },
    ['1'] = { "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", 'Open File 1' },
    ['2'] = { "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", 'Open File 2' },
    ['3'] = { "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", 'Open File 3' },
    ['4'] = { "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", 'Open File 4' },
  },
  l = {
    name = 'LSP',
    A = { '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', 'Add Workspace Folder' },
    D = { '<cmd>lua vim.lsp.buf.declaration()<cr>', 'Go To Declaration' },
    F = { '<cmd>LspToggleAutoFormat<cr>', 'Toggle Autoformat' },
    I = { '<cmd>lua vim.lsp.buf.implementation()<cr>', 'Show implementations' },
    K = { '<cmd>lua vim.lsp.buf.hover()<cr>', 'Hover Commands' },
    L = { '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>', 'List Workspace Folders' },
    R = { '<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename' },
    S = { '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', 'Workspace Symbols' },
    W = { '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', 'Remove Workspace Folder' },
    a = { '<cmd>lua vim.lsp.buf.code_action()<cr>', 'Code Action' },
    d = { '<cmd>lua vim.lsp.buf.definition()<cr>', 'Go To Definition' },
    e = { '<cmd>Telescope diagnostics bufnr=0<cr>', 'Document Diagnostics' },
    f = { '<cmd>lua vim.lsp.buf.formatting()<cr>', 'Format' },
    h = { '<cmd>lua vim.lsp.buf.signature_help()<cr>', 'Signature Help' },
    i = { '<cmd>LspInfo<cr>', 'Info' },
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
  m = {
    name = 'Misc',
    a = {
      "<cmd>lua require'telegraph'.telegraph({cmd='gitui', how='tmux_popup'})<cr>",
      'Test Telegraph',
    },
    h = { '<cmd>nohlsearch<CR>', 'No Highlight' },
    l = { '<cmd>lua vim.lsp.codelens.run()<cr>', 'CodeLens Action' },
    o = { '<cmd>SymbolsOutline<cr>', 'Outline' },
    p = { '<cmd>PackerSync<cr>', 'PackerSync' },
    s = { '<cmd>SymbolsOutline<cr>', 'Toggle SymbolsOutline' },
    z = { '<cmd>ZenMode<cr>', 'Toggle ZenMode' },
  },
  p = {
    name = 'Packer',
    c = { '<cmd>PackerCompile<cr>', 'Compile' },
    i = { '<cmd>PackerInstall<cr>', 'Install' },
    s = { '<cmd>PackerSync<cr>', 'Sync' },
    S = { '<cmd>PackerStatus<cr>', 'Status' },
    u = { '<cmd>PackerUpdate<cr>', 'Update' },
  },
  s = {
    name = 'Search',
    a = { '<cmd>Telescope autocommands<cr>', 'Auto Commands' },
    c = { '<cmd>Telescope commands<cr>', 'Commands' },
    C = { '<cmd>Telescope colorscheme<cr>', 'Colorscheme' },
    h = { '<cmd>Telescope help_tags<cr>', 'Find Help' },
    H = { '<cmd>Telescope heading<cr>', 'Find Header' },
    j = { '<cmd>Telescope jumplist<cr>', 'Jumplist' },
    k = { '<cmd>Telescope keymaps<cr>', 'Keymaps' },
    m = { '<cmd>require("telescope").extensions.macroscope.default()<cr>', 'Macros' },
    M = { '<cmd>Telescope man_pages<cr>', 'Man Pages' },
    n = { "<cmd>lua require('telescope').extensions.neoclip.default()<cr>", 'Neoclip' },
    N = { '<cmd>Telescope notify<cr>', 'Notifications' },
    p = { '<cmd>Telescope projects<cr>', 'Projects' },
    P = {
      "<cmd>lua require('telescope.builtin.internal').colorscheme({enable_preview = true})<cr>",
      'Colorscheme with Preview',
    },
    R = { '<cmd>Telescope registers<cr>', 'Registers' },
    s = { '<cmd>Telescope grep_string<cr>', 'Text under cursor' },
    S = { '<cmd>Telescope symbols<cr>', 'Search Emoji' },
    t = { '<cmd>Telescope live_grep<cr>', 'Text' },
    T = { '<cmd>Telescope treesitter<cr>', 'Treesitter' },
  },
  S = {
    name = 'Surround',
    ['.'] = { "<cmd>lua require('surround').repeat_last()<cr>", 'Repeat' },
    a = { "<cmd>lua require('surround').surround_add(true)<cr>", 'Add' },
    d = { "<cmd>lua require('surround').surround_delete()<cr>", 'Delete' },
    r = { "<cmd>lua require('surround').surround_replace()<cr>", 'Replace' },
    q = { "<cmd>lua require('surround').toggle_quotes()<cr>", 'Quotes' },
    b = { "<cmd>lua require('surround').toggle_brackets()<cr>", 'Brackets' },
  },
  t = {
    name = 'Terminal',
    ['1'] = { '<cmd>:1ToggleTerm<cr>', '1' },
    ['2'] = { ':2ToggleTerm<cr>', '2' },
    ['3'] = { ':3ToggleTerm<cr>', '3' },
    ['4'] = { ':4ToggleTerm<cr>', '4' },
    n = { 'Node' },
    u = { 'NCDU' },
    t = { 'Htop' },
    p = { 'Python' },
    f = { '<cmd>ToggleTerm direction=float<cr>', 'Float' },
    h = { '<cmd>ToggleTerm size=10 direction=horizontal<cr>', 'Horizontal' },
    v = { '<cmd>ToggleTerm size=80 direction=vertical<cr>', 'Vertical' },
  },
  T = {
    name = 'Treesitter',
    c = { '<cmd>:TSContextToggle<cr>', 'Treesitter Context Toggle' },
    h = { '<cmd>TSHighlightCapturesUnderCursor<cr>', 'Highlight' },
    p = { '<cmd>TSPlaygroundToggle<cr>', 'Playground' },
  },
  w = {
    name = 'Window',
    p = { '<c-w>x', 'Swap' },
    q = { '<cmd>:q<cr>', 'Close' },
    s = { '<cmd>:new<cr>', 'Empty Horizontal Split' },
    S = { '<cmd>:split<cr>', 'Horizontal Split' },
    t = { '<cmd>:tabnew<cr>', 'New Tab' },
    T = { '<c-w>t', 'Move to new tab' },
    ['='] = { '<c-w>=', 'Equally size' },
    v = { '<cmd>:vnew<cr>', 'Empty Vertical Split' },
    V = { '<cmd>:vsplit<cr>', 'Vertical Split' },
    w = {
      "<cmd>lua require('nvim-window').pick()<cr>",
      'Choose window to jump',
    },
  },
  W = {
    name = 'Workspaces',
    l = { '<cmd>lua require("sessions").load()<cr>', 'Load Session' },
    s = { '<cmd>lua require("sessions").save()<cr>', 'Save Session' },
    S = { '<cmd>lua require("sessions").stop_autosave()<cr>', 'Stop Session' },
    p = { "<cmd>lua require('telescope').extensions.projects.projects()<cr>", 'Projects' },
  },
  z = {
    name = 'Focus',
    z = { ':ZenMode<cr>', 'Toggle Zen Mode' },
    t = { ':Twilight<cr>', 'Toggle Twilight' },
  },
}

local vmappings = {
  ['/'] = { '<ESC><CMD>lua require("Comment.api").toggle_linewise_op(vim.fn.visualmode())<CR>', 'Comment' },
  s = { "<esc><cmd>'<,'>SnipRun<cr>", 'Run range' },
}

which_key.setup(setup)
which_key.register(non_leader_mappings) -- register non leader based mappings
which_key.register(mappings, opts)
which_key.register(vmappings, vopts)
--which_key.register(m_mappings, m_opts)
