local wk = require "which-key"

wk.setup {
  plugins = {
    marks = true, -- shows a list of your marks on ' and `
    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    -- the presets plugin, adds help for a bunch of default keybindings in Neovim
    -- No actual key bindings are created
    presets = {
      operators = false, -- adds help for operators like d, y, ...
      motions = false, -- adds help for motions
      text_objects = false, -- help for text objects triggered after entering an operator
      windows = true, -- default bindings on <c-w>
      nav = true, -- misc bindings to work with windows
      z = true, -- bindings for folds, spelling and others prefixed with z
      g = true, -- bindings for prefixed with g
    },
    spelling = { enabled = true, suggestions = 20 }, -- use which-key for spelling hints
  },
  icons = {
    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
    separator = "➜", -- symbol used between a key and it's label
    group = "+", -- symbol prepended to a group
  },
  window = {
    border = "double", -- none, single, double, shadow
    position = "bottom", -- bottom, top
    margin = { 1, 2, 1, 4 }, -- extra window margin [top, right, bottom, left]
    padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
  },
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
  },
  hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
  show_help = true, -- show help message on the command line when the popup is visible
  ignore_missing = false,
}

local opts = {
  mode = "n", -- NORMAL mode
  prefix = "<space>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}
local vopts = {
  mode = "v", -- VISUAL mode
  prefix = "<space>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}
-- NOTE: Prefer using : over <cmd> as the latter avoids going back in normal-mode.
-- see https://neovim.io/doc/user/map.html#:map-cmd
local vmappings = {
  ["/"] = { ":lua require('Comment.api').toggle_blockwise_op(vim.fn.visualmode())<CR>", "Comment" },
  ["j"] = { ":'<,'>SnipRun<CR>", "Run Javascript" },
  ["S"] = { ":'<,'>CarbonNowSh<CR>", "Snapshot" },
}
local mappings = {
  ["w"] = { "<cmd>w!<CR>", "Save" },
  ["q"] = { "<cmd>q!<CR>", "Quit" },
  ["/"] = { "<cmd>lua require('Comment.api').toggle_current_linewise()<CR>", "Comment" },
  ["c"] = { "<cmd>Bdelete!<CR>", "Close Buffer" },
  ["e"] = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
  ["f"] = {
    "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>",
    "Find files",
  },
  ["h"] = { '<cmd>let @/=""<CR>', "No Highlight" },
  ["m"] = { "<cmd>MarkdownPreviewToggle<CR>", "Markdown Preview" },

  L = {
    "<cmd>:put =printf('console.log('' 🔔 %s 👉 %s 👉 %s:'', %s);', line('.'), expand('%:t'), expand('<cword>'), expand('<cword>'))<cr>",
    "Javascript Log",
  },
  p = {
    name = "Packer",
    c = { "<cmd>PackerCompile<cr>", "Compile" },
    i = { "<cmd>PackerInstall<cr>", "Install" },
    r = { "<cmd>lua require('lv-utils').reload_lv_config()<cr>", "Reload" },
    s = { "<cmd>PackerSync<cr>", "Sync" },
    u = { "<cmd>PackerUpdate<cr>", "Update" },
  },

  -- " Available Debug Adapters:
  -- "   https://microsoft.github.io/debug-adapter-protocol/implementors/adapters/
  -- " Adapter configuration and installation instructions:
  -- "   https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
  -- " Debug Adapter protocol:
  -- "   https://microsoft.github.io/debug-adapter-protocol/
  -- " Debugging
  d = {
    name = "Debug",
    t = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle Breakpoint" },
    T = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Clear All Breakpoint" },
    b = { "<cmd>lua require'dap'.step_back()<cr>", "Step Back" },
    c = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
    C = { "<cmd>lua require'dap'.run_to_cursor()<cr>", "Run To Cursor" },
    d = { "<cmd>lua require'dap'.disconnect() require'dapui'.toggle()<cr>", "Disconnect" },
    g = { "<cmd>lua require'dap'.session()<cr>", "Get Session" },
    i = { "<cmd>lua require'dap'.step_into()<cr>", "Step Into" },
    o = { "<cmd>lua require'dap'.step_over()<cr>", "Step Over" },
    u = { "<cmd>lua require'dap'.step_out()<cr>", "Step Out" },
    p = { "<cmd>lua require'dap'.pause()<cr>", "Pause" },
    r = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Toggle Repl" },
    s = { "<cmd>lua require'dap'.continue() require'dapui'.toggle()<cr>", "Start" },
    R = { "<cmd>lua require'dap'.restart()<cr>", "Restart" },
    S = { "<cmd>lua require'dapui'.toggle()<cr>", "Sidebar" },
    q = { "<cmd>lua require'dap'.close()<cr>", "Quit" },
    J = { "<cmd>:'<,'>SnipRun<cr>", "Javascript Run" },
  },
  g = {
    name = "Git",
    g = { "<cmd>lua _LAZYGIT_TOGGLE()<cr>", "LazyGit" },
    n = { "<cmd>Neogit<cr>", "Neogit" },
    j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
    k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
    l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
    p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
    r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
    R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
    s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
    u = {
      "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
      "Undo Stage Hunk",
    },
    o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
    b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
    c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
    C = {
      "<cmd>Telescope git_bcommits<cr>",
      "Checkout commit(for current file)",
    },
  },

  l = {
    name = "LSP",
    r = { "<cmd>:lua require('navigator.reference').reference()<cr>", "Reference" },
    H = { "<cmd>:lua signature_help()<cr>", "Signature help" },
    -- s = { "<cmd>:lua require('navigator.symbols').document_symbols()<cr>", "Document symbols" },
    s = { "<cmd>:Telescope lsp_document_symbols<cr>", "Document symbols" },
    S = { "<cmd>:Telescope lsp_workspace_symbols<cr>", "Workspace symbols" },
    -- S = { "<cmd>:lua workspace_symbol()<cr>", "Workspace symbol" },
    d = { "<cmd>:lua require('navigator.definition').definition()<cr>", "Definition" },
    p = { "<cmd>:lua require('navigator.definition').definition_preview()<cr>", "Definition preview" },
    D = { "<cmd>:lua declaration({ border = 'rounded', max_width = 80 })<cr>", "Declaration" },
    a = { "<cmd>:lua require('navigator.codeAction').code_action()<cr>", "Code action" },
    A = { "<cmd>:lua range_code_action()<cr>", "Range code action" },
    -- r = { "<cmd>:lua require('navigator.rename').rename()<cr>", "Rename" },
    c = { "<cmd>:lua incoming_calls()<cr>", "Incoming calls" },
    C = { "<cmd>:lua outgoing_calls(<cr>", "Outgoing calls" },
    -- i = { "<cmd>:lua implementation()<cr>", "Implementation" },
    t = { "<cmd>:lua type_definition()<cr>", "Type definition" },
    B = { "<cmd>:lua require('navigator.diagnostics').show_buf_diagnostics()<cr>", "Show buf diagnostics" },
    L = { "<cmd>:lua require('navigator.diagnostics').show_diagnostics()<cr>", "Show diagnostics" },
    T = { "<cmd>:lua require('navigator.diagnostics').toggle_diagnostics()<cr>", "Toggle diagnostics" },
    b = { "<cmd>:Telescope  diagnostics<cr>", "All diagnostics" },
    K = { "<cmd>:lua require('navigator.dochighlight').hi_symbol()<cr>", "Hi Symbol" },
    w = { "<cmd>:lua add_workspace_folder()<cr>", "Add workspace folder" },
    R = { "<cmd>:lua remove_workspace_folder()<cr>", "Remove workspace folder" },
    W = { "<cmd>:lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>", "List workspace folders" },
    e = {
      "<cmd>lua vim.diagnostic.setqflist()<cr>",
      "Workspace Diagnostics",
    },
    -- f = { "<cmd>lua formatting()<cr>", "Formatting" },
    -- F = { "<cmd>lua range_formatting<cr>", "Range formatting" },

    -- a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
    -- d = {
    --   "<cmd>Telescope lsp_document_diagnostics<cr>",
    --   "Document Diagnostics",
    -- },
    -- w = {
    --   "<cmd>Telescope lsp_workspace_diagnostics<cr>",
    --   "Workspace Diagnostics",
    -- },
    -- f = { "<cmd>silent FormatWrite<cr>", "Format" },
    i = { "<cmd>LspInfo<cr>", "Info" },
    j = {
      "<cmd>lua vim.lsp.diagnostic.goto_next({popup_opts = {border = O.lsp.popup_border}})<cr>",
      "Next Diagnostic",
    },
    k = {
      "<cmd>lua vim.lsp.diagnostic.goto_prev({popup_opts = {border = O.lsp.popup_border}})<cr>",
      "Prev Diagnostic",
    },
    -- l = { "<cmd>silent lua require('lint').try_lint()<cr>", "Lint" },
    q = { "<cmd>Telescope quickfix<cr>", "Quickfix" },
    -- r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
    -- s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
    -- S = {
    --   "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
    --   "Workspace Symbols",
    -- },
  },

  s = {
    name = "Search",
    b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
    c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
    f = {
      "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>",
      "Find files",
    },
    P = { "<cmd>Telescope projects<cr>", "Projects" },
    h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
    M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
    r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
    R = { "<cmd>Telescope registers<cr>", "Registers" },
    t = { "<cmd>Telescope live_grep theme=ivy<cr>", "Find Text" },
    k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
    C = { "<cmd>Telescope commands<cr>", "Commands" },
    m = { "<cmd>Telescope marks<cr>", "Bookmarks" },
    p = {
      "<cmd>lua require('telescope.builtin.internal').colorscheme({enable_preview = true})<cr>",
      "Colorscheme with Preview",
    },
    T = { "<cmd>TodoTelescope <cr>", "TODO" },
  },

  r = {
    name = "Seacrh & Replace",
    w = { "<cmd>:lua require('spectre').open_visual({select_word=true})<cr>", "Search current word" },
    f = { "<cmd>:lua require('spectre').open_file_search()<cr>", "Search in current file" },
    r = { "<cmd>:lua require('spectre.actions').run_replace()<cr>", "Replace" },
  },

  t = {
    name = "Terminal",
    t = { ":ToggleTerm<cr>", "Toggle" },
    a = { ":ToggleTermOpenAll<cr>", "Show All" },
    c = { ":ToggleTermCloseAll<cr>", "Close All" },
  },

  T = {
    name = "Treesitter",
    i = { ":TSConfigInfo<cr>", "Info" },
    p = { ":TSPlaygroundToggle<cr>", "Playground" },
    h = { ":TSHighlightCapturesUnderCursor<cr>", "Syntax highlight" },
  },

  S = {
    name = "Sessions",
    s = { ":SaveSession<cr>", "Save Session" },
    -- s = { ":SessionSave<cr>", "Save Session" },
    S = { ":Telescope session-lens search_session<cr>", "All Sessions" },
    -- l = { ":SessionLoad<cr>", "Load Session" },
    l = { ":RestoreSession<cr>", "Load Session" },
  },

  -- S = {
  --   name = "Saerch & Replace",
  --   s = { "<cmd>:lua require('spectre').open()<cr>", "All files" },
  --   w = { "<cmd>:lua require('spectre').open_visual({select_word=true})<cr>", "Search current word" },
  --   f = { "<cmd>:lua require('spectre').open_file_search()<cr>", "Search in current file" },
  -- },

  G = {
    name = "Go To",
    d = { "<cmd>:lua require('goto-preview').goto_preview_definition()<CR>", "Definition" },
    i = { "<cmd>:lua require('goto-preview').goto_preview_implementation()<CR>", "Implementation" },
    c = { "<cmd>:lua require('goto-preview').close_all_win()<CR>", "Close" },
    r = { "<cmd>:lua require('goto-preview').goto_preview_references()<CR>", "References" },
  },
  -- z = { "<cmd>:lua require('user.utils.popup-fun').test()<CR>", "Test Popup" },
  z = { "<cmd>:lua require('user.utils.toggle').toggle_window()<CR>", "Test Popup" },
}

-- all of the mappings below are equivalent

-- method 2
wk.register(mappings, opts)
wk.register(vmappings, vopts)
-- wk.register({
--   ["<leader>"] = {
--       ["/"] = { "<cmd>CommentToggle<cr>", "Comment Lines" },
--       ["H"] = { "<cmd>let @/ = ''<cr>", "No highlight" },
--       ["G"] = {
--       name = "+Git",
--           s = { "<cmd>Neogit <cr>", "Status" },
--           r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
--           n = { "<cmd>enew<cr>", "New File" },
--       },
--   },
-- })

local opt = { noremap = true, silent = true }

-- mappings
vim.api.nvim_set_keymap("n", "<Leader>ff", [[<Cmd>lua require('telescope.builtin').find_files()<CR>]], opt)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fp",
  [[<Cmd>lua require('telescope').extensions.media_files.media_files()<CR>]],
  opt
)

vim.api.nvim_set_keymap("n", "<Leader>fb", [[<Cmd>lua require('telescope.builtin').buffers()<CR>]], opt)
vim.api.nvim_set_keymap("n", "<Leader>fh", [[<Cmd>lua require('telescope.builtin').help_tags()<CR>]], opt)
vim.api.nvim_set_keymap("n", "<Leader>fo", [[<Cmd>lua require('telescope.builtin').oldfiles()<CR>]], opt)
vim.api.nvim_set_keymap("n", "<Leader>fm", [[<Cmd> Neoformat<CR>]], opt)
-- vim.api.nvim_set_keymap("n", "<Leader>pp", [[<Cmd>lua require('lsp.lsp-ext').peek_definition()<CR>]], opt)
vim.api.nvim_set_keymap("n", "<Leader>pp", [[<Cmd>lua require('lsp.lsp-ext').test_window()<CR>]], opt)

-- dashboard stuff
vim.api.nvim_set_keymap("n", "<Leader>fw", [[<Cmd> Telescope live_grep<CR>]], opt)
vim.api.nvim_set_keymap("n", "<Leader>fn", [[<Cmd> DashboardNewFile<CR>]], opt)
vim.api.nvim_set_keymap("n", "<Leader>fb", [[<Cmd> DashboardJumpMarks<CR>]], opt)
vim.api.nvim_set_keymap("n", "<Leader>fl", [[<Cmd> SessionLoad<CR>]], opt)
vim.api.nvim_set_keymap("n", "<Leader>fs", [[<Cmd> SessionSave<CR>]], opt)

-- J = { "<cmd>:'<,'>SnipRun<cr>", "Javascript Run" },
vim.api.nvim_set_keymap("v", "<C-j>", [[<Cmd>'<,'>SnipRun<CR>]], { noremap = true, silent = false })

vim.api.nvim_set_keymap("n", "gD", [[<Cmd> lua require('goto-preview').goto_preview_definition()<CR>]], opt)
vim.api.nvim_set_keymap("n", "gI", [[<Cmd> lua require('goto-preview').goto_preview_implementation()<CR>]], opt)
vim.api.nvim_set_keymap("n", "gC", [[<Cmd>lua require('goto-preview').close_all_win()<CR>]], opt)
vim.api.nvim_set_keymap("n", "gR", [[<Cmd>lua require('goto-preview').goto_preview_references(<CR>]], opt)
