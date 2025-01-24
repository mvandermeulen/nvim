local wk = require("which-key")

function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end


-- Global Mappings
wk.add({
  { "<leader>C", "<cmd>Cheatsheet<cr>", desc = "Cheatsheet" },
  { "<leader>L", "<cmd>:Lazy<cr>", desc = "Lazy" },
  { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" },
  { "<leader>q", "<cmd>NvimTreeClose<cr>:q<cr>", desc = "Close Window" },
  -- { "<leader>q", "<cmd>NvimTreeClose<cr>:q<cr>", desc = "  Close Window" },
  -- { "<leader>Q", "<cmd>NvimTreeClose<cr><cmd>qa<cr>", desc = "  Close Window" },
  -- { "<leader>x", ":TSContextDisable<cr>:TSBufDisable rainbow<cr>:TSBufDisable highlight<cr><cmd>Bdelete<cr>", desc = "  Close Buffer" },
  { "<leader>x", "<CMD>BufferDelete<CR>", desc = "Close Buffer" },
  -- { "<leader>x", "<CMD>BufferDelete<CR>", desc = "  Close Buffer" },
  -- { "<C-_>", "<Plug>(comment_toggle_linewise_current)", desc = "  Comment Line" },
  -- { "<leader>", "", desc = "" },
  -- { "<leader>", "", desc = "" },
})

-- Application Mappings: <leader>a
wk.add({
  { "<leader>aC", "<cmd>Cheatsheet<cr>", desc = "Cheatsheet" },
  { "<leader>an", "<cmd>Notifications<cr>", desc = "󰵙 Notifications" },
  { "<leader>aS", "<cmd>FzfLua<cr>", desc = "Fuzzy Search" },
  { "<leader>aT", "<cmd>Telescope<cr>", desc = "  Telescope Extensions" },
  { "<leader>ay", "<ESC><CMD>YankBank<CR>", desc = " YankBank" },
  { "<leader>au", "<ESC><CMD>UrlView<CR>", desc = "Buffer URL View" },
  { "<leader>aL", "<ESC><CMD>UrlView lazy<CR>", desc = "Lazy URL View" },
})

-- Clipboard: <leader>ac
wk.add({
  { "<leader>ach", "<cmd>:Telescope neoclip<cr>", desc = "History" },
  { "<leader>acm", "<cmd>lua require('telescope').extensions.macroscope.default()<cr>", desc = "Macros" },
  { "<leader>acp", "<cmd>:Telescope neoclip plus<cr>", desc = "Yank to Plus" },
  { "<leader>acP", '<cmd>lua require("neoclip").pause()<cr>', desc = "Pause Recording" },
  { "<leader>acs", "<cmd>:Telescope neoclip star<cr>", desc = "Yank to Star" },
  { "<leader>acS", '<cmd>lua require("neoclip").start()<cr>', desc = "Start Recording" },
  { "<leader>act", '<cmd>lua require("neoclip").toggle()<cr>', desc = "Toggle Recording" },
  { "<leader>acu", "<cmd>:Telescope neoclip unnamed<cr>", desc = "Yank to Unnamed" },
})


-- Focus: <leader>af
-- wk.add({
--   { "<leader>afz", "<cmd>:ZenMode<cr>", desc = "Toggle Zen Mode" },
--   { "<leader>aft", "<cmd>:Twilight<cr>", desc = "Toggle Twilight" },
-- })


-- Gist: <leader>ag
wk.add({
  { "<leader>agc", "<CMD>GistCreate<CR>", desc = "Create from Selection" },
  { "<leader>agf", "<CMD>GistCreateFromFile<CR>", desc = "Create from File" },
  { "<leader>agl", "<CMD>GistsList<CR>", desc = "List Gists" },
})


-- SSHFS: <leader>as
wk.add({
  { "<leader>asc", "<cmd>RemoteSSHFSConnect<cr>", desc = "Connect" },
  { "<leader>asd", "<cmd>RemoteSSHFSDisconnect<cr>", desc = "Disconnect" },
  { "<leader>ase", "<cmd>RemoteSSHFSEdit<cr>", desc = "Edit" },
  { "<leader>asf", "<cmd>RemoteSSHFSFindFiles<cr>", desc = "Find Files" },
  { "<leader>asg", "<cmd>RemoteSSHFSLiveGrep<cr>", desc = "Live Grep" },
  { "<leader>as", "<cmd><cr>", desc = "" },
})


-- Terminal: <leader>at
wk.add({
  { '<leader>at1', ':1ToggleTerm<cr>', desc = '1' },
  { '<leader>at2', ':2ToggleTerm<cr>', desc = '2' },
  { '<leader>at3', ':3ToggleTerm<cr>', desc = '3' },
  { '<leader>at4', ':4ToggleTerm<cr>', desc = '4' },
  { '<leader>atc', "<cmd>:ToggleTermSendCurrentLine<cr>", desc = 'Send Current Line' },
  { '<leader>atf', "<CMD>ToggleTerm direction=float<CR>", desc = "Float" },
  { '<leader>atH', "<CMD>ToggleTerm size=10 direction=horizontal<CR>", desc = "Horizontal" },
  { '<leader>ati', "<cmd>ToggleTasksInfo<cr>", desc = 'Tasks Info' },
  { '<leader>ats', "<cmd>:ToggleTermSendVisualSelection<cr>", desc = 'Send Selection' },
  { '<leader>att', "<cmd>Telescope toggletasks spawn<cr>", desc = 'Spawn Task' },
  { '<leader>atT', "<cmd>Telescope toggletasks select<cr>", desc = 'Select Task' },
  { '<leader>atv', "<CMD>ToggleTerm size=80 direction=vertical<CR>", desc = "Vertical" },
})

-- Treesitter: <leader>aT
wk.add({
  { "<leader>aTc", "<cmd>:TSContextToggle<cr>", desc = "Context Toggle" },
  { "<leader>aTm", "<cmd>TSModuleInfo<cr>", desc = "Module Info" },
  { "<leader>aTC", "<cmd>TSConfigInfo<cr>", desc = "Config Info" },
  { "<leader>aTi", "<cmd>TSInstallInfo<cr>", desc = "Install Info" },
  { "<leader>aTv", "<cmd>NvimContextVtToggle<CR>", desc = "VT Context: Toggle" },
  -- { "<leader>aTh", "<cmd>TSHighlightCapturesUnderCursor<cr>", desc = "Highlight" },
  -- { "<leader>aTp", "<cmd>TSPlaygroundToggle<cr>", desc = "Playground" },
})


-- Avante: <leader>A
wk.add({
  { '<leader>ACn', '<cmd>AvanteConflictNextConflict<CR>', desc = 'Avante: Next Conflict' },
  { '<leader>ACp', '<cmd>AvanteConflictPrevConflict<CR>', desc = 'Avante: Prev Conflict' },
  { '<leader>ASo', '<cmd>AvanteSwitchProvider openai<CR>', desc = 'Avante Use: OpenAI' },
  { '<leader>ASa', '<cmd>AvanteSwitchProvider claude<CR>', desc = 'Avante Use: Claude' },
  { '<leader>ASc', '<cmd>AvanteSwitchProvider copilot<CR>', desc = 'Avante Use: Copilot' },
  { '<leader>ASg', '<cmd>AvanteSwitchProvider gemini<CR>', desc = 'Avante Use: Gemini' },
  { '<leader>AR', '<cmd>AvanteShowRepoMap<CR>', desc = 'Avante: Repo Map' },
  { '<leader>At', "<cmd>AvanteToggle<CR>", desc = "Avante: Toggle" },
  { '<leader>Af', "<cmd>AvanteFocus<CR>", desc = "Avante: Focus" },
  { '<leader>Ac', "<cmd>AvanteChat<CR>", desc = "Avante: Chat" },
  { '<leader>Ab', "<cmd>AvanteBuild<CR>", desc = "Avante: Build" },
  { '<leader>A<BS>', '<cmd>AvanteClear<CR>', desc = "Avante: Clear" },
  { '<M-.>', "<cmd>AvanteToggle<CR>", desc = "Avante: Toggle" },
})


-- Buffers: <leader>b
wk.add({
  { '<leader>bb', "<CMD>lua require'telescope.builtin'.buffers({ sort_mru = true, ignore_current_buffer = true })<CR>", desc = 'Find buffer' },
  { '<leader>ba', '<CMD>BufferLineCloseLeft<CR><CMD>BufferLineCloseRight<CR>', desc = 'Close All but current' },
  { '<leader>bc', "<CMD>BufferLinePickClose<CR>", desc = "Pick Close" },
  -- { '<leader>bc', "<CMD>BufferLinePickClose<CR>", desc = " Pick close" },
  -- { '<leader>bd', '<CMD>TSContextDisable<CR><CMD>TSBufDisable rainbow<CR><CMD>TSBufDisable highlight<CR><CMD>Bdelete<CR>', desc = 'Close Buffer' },
  { '<leader>bd', '<CMD>BufferDelete<CR>', desc = 'Delete Buffer' },
  { '<leader>bf', '<CMD>BufferLinePick<CR>', desc = ' Pick buffer' },
  { '<leader>bg', "<CMD>BufferLineGroupClose<CR>", desc = "  Group close" },
  { '<leader>bl', '<CMD>BufferLineCloseLeft<CR>', desc = ' Close left' },
  { '<leader>bp', '<CMD>BufferLineMovePrev<CR>', desc = ' Move previous' },
  { '<leader>bn', '<CMD>BufferLineMoveNext<CR>', desc = ' Move next' },
  { '<leader>br', '<CMD>BufferLineCloseRight<CR>', desc = ' Close right' },
  { '<leader>bs', '<CMD>noautocmd w<CR>', desc = 'Save no autocmd' },
  { '<leader>bS', '<CMD>setlocal winfixbuf<CR>', desc = 'Sticky Buffer' },
  { '<leader>bP', '<CMD>PinBuffer<CR>', desc = ' 󰐃 Pin Buffer' },
  -- Sort
  { '<leader>bsd', "<CMD>BufferLineSortByDirectory<CR>", desc = " Directory" },
  { '<leader>bst', "<CMD>BufferLineSortByTabs<CR>", desc = "Tabs" },
  { '<leader>bse', "<CMD>BufferLineSortByExtension<CR>", desc = "  Extension" },
  { '<leader>bsr', "<CMD>BufferLineSortByRelativeDirectory<CR>", desc = " Relative Directory" },
})


-- Tabs: <leader>B
wk.add({
  { '<leader>Bh', "<CMD>tablast<CR>", desc = " Last" },
  { '<leader>Bl', "<CMD>tabfirst<CR>", desc = " First" },
  { '<leader>Bk', "<CMD>tabonly<CR>", desc = "Only" },
  { '<leader>Bj', "<CMD>tabrewind<CR>", desc = " Rewind" },
})


-- Copilot: <leader>c
wk.add({
  { "<leader>ce", "<cmd>Copilot enable<cr>", desc = "Enable" },
  { "<leader>cd", "<cmd>Copilot disable<cr>", desc = "Disable" },
  { "<leader>ct", "<cmd>Copilot toggle<cr>", desc = "Toggle" },
  { "<leader>cs", "<cmd>Copilot status<cr>", desc = "Status" },
  { "<leader>cv", "<cmd>Copilot version<cr>", desc = "Version" },
  { "<leader>cp", "<cmd>Copilot panel<cr>", desc = "Panel" },
  { "<leader>ca", "<cmd>Copilot auth<cr>", desc = "Auth" },
  { "<leader>cS", "<cmd>Copilot suggestion<cr>", desc = "Suggestion" },
  { "<leader>ca", "<cmd>Copilot attach<cr>", desc = "Attach" },
  { "<leader>cD", "<cmd>Copilot detach<cr>", desc = "Detach" },
})


-- Copilot Chat: <leader>cc
wk.add({
  { '<leader>cca', "<cmd>CopilotChatAnnotations<CR>", desc = "Add a comment" },
  { "<leader>ccd", "<Cmd>CopilotChatDocs<CR>", desc = "Document code" },
  { '<leader>ccD', "<cmd>CopilotChatDebugInfo<cr>", desc = "Show diff" },
  { '<leader>cce', "<cmd>CopilotChatExplain<cr>", desc = "Explain code" },
  { '<leader>ccf', "<cmd>CopilotChatFixError<cr>", desc = "Fix Error" },
  { "<leader>ccF", "<Cmd>CopilotChatFixDiagnostic<CR>", desc = "Fix diagnostic" },
  { "<leader>ccm", "<Cmd>CopilotChatCommit<CR>", desc = "Write commit message for the change" },
  { "<leader>ccM", "<Cmd>CopilotChatCommitStaged<CR>", desc = "Write commit message for the change in staged"},
  { '<leader>cco', "<cmd>CopilotChatOpen<cr>", desc = "Open chat" },
  { "<leader>ccO", "<Cmd>CopilotChatOptimize<CR>", desc = "Optimize code" },
  { '<leader>ccq', "<cmd>CopilotChatClose<cr>", desc = "Close chat" },
  { '<leader>ccr', "<cmd>CopilotChatRefactor<cr>", desc = "Refactor code" },
  { "<leader>ccR", "<Cmd>CopilotChatReview<CR>", desc = "Review code" },
  { '<leader>ccs', "<cmd>CopilotChatSuggestion<cr>", desc = "Provide suggestion" },
  { "<leader>cct", "<Cmd>CopilotChatTests<CR>", desc = "Generate tests" },
  { '<leader>cct', "<cmd>CopilotChatToggle<cr>", desc = "Toggle chat" },
  { '<leader>ccX', "<cmd>CopilotChatReset<cr>", desc = "Reset chat" },
  -- Custom Prompts
  { "<leader>ccw", "<Cmd>CopilotChatWording<CR>", desc = "Improve wording" },
  -- Models
  { "<leader>cc.", "<Cmd>CopilotChatModels<CR>", desc = "Available Models" },
  { "<leader>cc_", "<Cmd>CopilotChatModel<CR>", desc = "Current Model" },
  { "<leader>ccA", "<cmd>CopilotChatAgents<cr>", desc = "Agents" },
})



-- Copilot Chat: <leader>cc
-- wk.add({
--   { "<leader>", "<cmd><cr>", desc = "" },
--   { "<leader>", "<cmd><cr>", desc = "" },
--   { "<leader>", "<cmd><cr>", desc = "" },
--   { "<leader>", "<cmd><cr>", desc = "" },
--   { "<leader>", "<cmd><cr>", desc = "" },
--   { "<leader>", "<cmd><cr>", desc = "" },
--   { "<leader>", "<cmd><cr>", desc = "" },
--   { "<leader>", "<cmd><cr>", desc = "" },
--   { "<leader>", "<cmd><cr>", desc = "" },
--   { "<leader>", "<cmd><cr>", desc = "" },
-- })

-- Diagnostics: <leader>d
wk.add({
  { '<leader>dd', '<cmd>Trouble diagnostics<cr>', desc = 'Document Diagnostic' },
  { '<leader>di', '<cmd>LspInfo<cr>', desc = 'LSP Info' },
  { '<leader>dl', '<cmd>Trouble loclist<cr>', desc = 'Loclist' },
  { '<leader>dq', '<cmd>Trouble quickfix<cr>', desc = 'Quickfix' },
  { '<leader>dr', '<cmd>Trouble lsp_references<cr>', desc = 'LSP References' },
  { '<leader>ds', "<cmd>lua _G.my.helpers.server:vdm_start_server()<cr>", desc = 'Start Server' },
  { '<leader>dt', '<cmd>TodoTrouble<cr>', desc = 'Todos' },
  { '<leader>dT', '<cmd>TroubleToggle<cr>', desc = 'Toggle Trouble' },
  -- { '<leader>dw', '<cmd>Trouble workspace_diagnostics<cr>', desc = 'Workspace Diagnostics' },
  { '<leader>dx', '<cmd>LspRestart<cr>', desc = 'LSP Restart' },
})


-- Files: <leader>ff
wk.add({
  { '<leader>ffb', '<cmd>Telescope file_browser<cr>', desc = ' File Browser' },
  -- { '<leader>fff', "<cmd>lua require'telescope.builtin'.find_files({ find_command = {'fd', '--hidden', '--type', 'file', '--follow'}})<cr>", desc = 'Find File' },
  { '<leader>fff', '<cmd>lua require("helpers.plugins.telescope").find_files()<CR>', desc = 'Find File' },
  { '<leader>ffg', '<cmd>lua require("helpers.plugins.telescope").live_grep()<CR>', desc = 'Live Grep' },
  { '<leader>ffp', '<cmd>NvimTreeToggle<cr>', desc = ' Toggle Tree' },
  { '<leader>ffr', '<cmd>Telescope oldfiles<cr>', desc = 'Open Recent File' },
  { '<leader>fft', '<cmd>NvimTreeFindFile<CR>', desc = 'Find in Tree' },
})


-- File: <leader>F
wk.add({
  { '<leader>Fr', '<cmd>CopyFileRelativePath<cr>', desc = 'Copy Relative File Path' },
  { '<leader>FR', '<cmd>CopyFileRelativePathWithLine<cr>', desc = 'Copy Relative File Path with Line' },
  { '<leader>Fpr', '<cmd>CopyRelativePath<cr>', desc = 'Copy Relative Path' },
  { '<leader>Fa', '<cmd>CopyFileAbsolutePath<cr>', desc = 'Copy Absolute File Path' },
  { '<leader>FA', '<cmd>CopyFileAbsolutePathWithLine<cr>', desc = 'Copy Absolute File Path with Line' },
  { '<leader>Fpa', '<cmd>CopyAbsolutePath<cr>', desc = 'Copy Absolute Path' },
  { '<leader>Fn', '<cmd>CopyFileName<cr>', desc = 'Copy Filename' },
  -- { '<leader>F', '<cmd><cr>', desc = '' },
})

-- Git: <leader>g
wk.add({
  { '<leader>gb', '<CMD>Telescope git_branches<CR>', desc = '  Checkout branch' },
  -- { '<leader>gB', "<CMD>lua require 'gitsigns'.blame_line()<CR>", desc = "Show Blame" },
  { '<leader>gc', '<CMD>Telescope git_commits<CR>', desc = 'Checkout commit' },
  { '<leader>gC', '<CMD>Telescope git_bcommits<CR>', desc = 'Checkout commit(for current file)' },
  { '<leader>gd', "<CMD>Gitsigns diffthis HEAD<CR>", desc = " 󰉢 Diff" },
  { '<leader>gG', "<CMD>lua _GITUI_TOGGLE()<CR>i", desc = "GitUI" },
  { '<leader>gh', "<CMD>Gitsigns toggle_linehl<CR>", desc = 'Toggle Highlight' },
  { '<leader>gj', "<CMD>lua require 'gitsigns'.next_hunk()<CR>", desc = " Next Hunk" },
  { '<leader>gk', "<CMD>lua require 'gitsigns'.prev_hunk()<CR>", desc = " Prev Hunk" },
  { '<leader>gL', "<CMD>lua _LAZYGIT_TOGGLE()<CR>i", desc = " Lazygit" },
  { '<leader>gn', '<CMD>Neogit<CR>', desc = 'Neogit' },
  { '<leader>gp', "<CMD>lua require 'gitsigns'.preview_hunk()<CR>", desc = " Preview Hunk" },
  { '<leader>gr', "<CMD>lua require 'gitsigns'.reset_hunk()<CR>", desc = "ﰇ Reset Hunk" },
  { '<leader>gR', "<CMD>lua require 'gitsigns'.reset_buffer()<CR>", desc = " Reset Buffer" },
  { '<leader>gs', "<CMD>lua require 'gitsigns'.stage_hunk()<CR>", desc = "Stage Hunk" },
  { '<leader>gS', '<CMD>Telescope git_status<CR>', desc = '  Git Status' },
  { '<leader>gt', "<CMD>Gitsigns toggle_signs<CR>", desc = 'Toggle Signs' },-- Should this be moved to some kind of UI menu?
  { '<leader>gu', "<CMD>lua require 'gitsigns'.undo_stage_hunk()<CR>", desc = "Undo Stage Hunk" },
})


-- Github Repo: <leader>go
wk.add({
  { "<leader>gog", "<CMD>lua require('helpers.plugins.github').open_git_repo()<CR>", desc = "Open Repo" },
  { "<leader>gox", "<CMD>lua require('helpers.plugins.github').close_git_repo()<CR>", desc = "Close Repo Buffers" },
  { "<leader>goc", "<CMD>lua require('helpers.plugins.github').clean_git_repo()<CR>", desc = "Clean Repo" },
})

-- Inserts: <leader>I
wk.add({
  { "<leader>Ie", "<CMD>lua EscapePair()<CR>", desc = "Escape Pair" },
  { "<leader>If", "<CMD>lua require('helpers.utils.fs').insert_file_path()<CR>", desc = "File Path" },
  { "<leader>It", "<CMD>lua require('helpers.user.todos').insert_todo_and_comment()<CR>", desc = "Todo with Comment" },
  { "<leader>Ip", "<CMD>lua require('helpers.utils').add_project_from_line(vim.fn.getline('.'))<CR>", desc = "Project" },
  -- { "<leader>I", "", desc = "" },
  -- { "<leader>I", "", desc = "" },
})


-- LSP: <leader>l
wk.add({
  { '<leader>lA', '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', desc = 'Add Workspace Folder' },
  { '<leader>lD', '<cmd>lua vim.lsp.buf.declaration()<cr>', desc = 'Go To Declaration' },
  { '<leader>lF', '<cmd>LspToggleAutoFormat<cr>', desc = 'Toggle Autoformat' },
  { '<leader>lI', '<cmd>lua vim.lsp.buf.implementation()<cr>', desc = 'Show implementations' },
  { '<leader>lK', '<cmd>lua vim.lsp.buf.hover()<cr>', desc = 'Hover Commands' },
  { '<leader>lL', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>', desc = 'List Workspace_Folders' },
  { '<leader>lR', '<cmd>lua vim.lsp.buf.rename()<cr>', desc = 'Rename' },
  { '<leader>lS', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', desc = 'Workspace Symbols' },
  { '<leader>lW', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', desc = 'Remove Workspace Folder' },
  { '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<cr>', desc = 'Code Action' },
  { '<leader>ld', '<cmd>lua vim.lsp.buf.definition()<cr>', desc = 'Go To Definition' },
  { '<leader>le', '<cmd>Telescope diagnostics bufnr=0<cr>', desc = 'Document Diagnostics' },
  { '<leader>lf', '<cmd>lua vim.lsp.buf.formatting()<cr>', desc = 'Format' },
  { '<leader>lh', '<cmd>lua vim.lsp.buf.signature_help()<cr>', desc = 'Signature Help' },
  { '<leader>lj', '<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>', desc = 'Next Diagnostic in Buffer' },
  { '<leader>lk', '<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>', desc = 'Prev Diagnostic in Buffer' },
  { '<leader>ll', '<cmd>lua vim.diagnostic.open_float()<CR>', desc = 'Line diagnostics' },
  { '<leader>ln', '<cmd>lua vim.diagnostic.goto_next()<cr>', desc = 'Next Diagnostic' },
  { '<leader>lp', '<cmd>lua vim.diagnostic.goto_prev()<cr>', desc = 'Prev Diagnostic' },
  { '<leader>lq', '<cmd>lua vim.diagnostic.set_loclist()<cr>', desc = 'Quickfix' },
  { '<leader>lr', '<cmd>lua vim.lsp.buf.references()<cr>', desc = 'References' },
  { '<leader>ls', '<cmd>Telescope lsp_document_symbols<cr>', desc = 'Document Symbols' },
  { '<leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<cr>', desc = 'Type Definition' },
  { '<leader>lw', '<cmd>Telescope diagnostics<CR>', desc = 'Workspace Diagnostics' },
})


-- LSP Marks: <leader>lm
wk.add({
  { "<leader>lmt", "<CMD>lua require('lspmark.bookmarks').toggle_bookmark({with_comment=false})<CR>", desc = "Toggle Mark" },
  { "<leader>lmc", "<CMD>lua require('lspmark.bookmarks').toggle_bookmark({with_comment=true})<CR>", desc = "Toggle Comment Mark" },
  { "<leader>lmm", "<CMD>lua require('lspmark.bookmarks').modify_comment()<CR>", desc = "Modify Comment" },
  { "<leader>lms", "<CMD>lua require('lspmark.bookmarks').show_comment()<CR>", desc = "Show Comment" },
})


-- LSP Python: <leader>lP
wk.add({
  { "<leader>lPg", function() require("helpers.lang.pyenv").get_current_venv(true) end, desc = "Get Current Venv" },
  { "<leader>lPv", function() require("helpers.lang.pyenv").select_venv() end, desc = "Select Venv" },
  { "<leader>lPl", function() require("helpers.lang.pyenv").set_venv(vim.fn.getcwd()) end, desc = "Set Venv to Local Directory" },
  { "<leader>lPh", function() require("helpers.lang.pyenv").set_venv(os.getenv("HOME")) end, desc = "Set Venv to Home Directory" },
})

-- Misc: <leader>m
wk.add({
  -- Check mappings/init.lua for use of: mr, mp
  -- Check plugins/utils/initlua for use of: mz, m., ms, mn, mH
  { "<leader>ma", "<CMD>lua vim.lsp.codelens.run()<CR>", desc = "CodeLens Action" },
  { "<leader>mh", "<CMD>nohlsearch<CR>", desc = "No Highlight" },
  { "<leader>ml", "<CMD>Gitsigns toggle_linehl<CR>", desc = "Toggle Line Highlight" },
  -- { "<leader>mt", "<CMD>lua require'telegraph'.telegraph({cmd='gitui', how='tmux_popup'})<CR>", desc = "Test Telegraph" },
  { "<leader>mw", "<CMD>Gitsigns toggle_word_diff<CR>", desc = "Toggle Word Diff"},
  { "<leader>mi", "<CMD>LspToggleInlayHints<CR>", desc = "Toggle Inlay Hints"},
  -- { "<leader>mz", "<CMD>ZenMode<CR>", desc = "Toggle ZenMode" },
  -- { "<leader>m", "", desc = "" },
})


-- Marks
-- wk.add({
  -- Recall maps: Mm, Mn, Mp, Mc, Ml
  -- Bookmarks maps: Mb[ta<BS>lr[]]
  -- Grapple maps: Mg[wtnp]
  -- { "<leader>M", "", desc = "" },
  -- { "<leader>M", "", desc = "" },
-- })



-- Search: <leader>s
wk.add({
  { '<leader>sa', '<cmd>Telescope autocommands<cr>', desc = 'Auto Commands' },
  { '<leader>sb', '<cmd>Telescope git_branches<cr>', desc = 'Checkout branch' },
  { '<leader>sc', '<cmd>Telescope commands<cr>', desc = 'Commands' },
  { '<leader>sC', '<cmd>Telescope colorscheme<cr>', desc = 'Colorscheme' },
  { '<leader>sf', "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>", desc = 'Find files' },
  { '<leader>sh', '<cmd>Telescope help_tags<cr>', desc = 'Find Help' },
  { '<leader>sH', '<cmd>Telescope heading<cr>', desc = 'Find Header' },
  { '<leader>si', "<cmd>lua require('telescope').extensions.media_files.media_files()<cr>", desc = 'Media' },
  { '<leader>sj', '<cmd>Telescope jumplist<cr>', desc = 'Jumplist' },
  { '<leader>sk', '<cmd>Telescope keymaps<cr>', desc = 'Keymaps' },
  { '<leader>sl', '<cmd>Telescope resume<cr>', desc = 'Last Search' },
  { '<leader>sm', '<cmd>require("telescope").extensions.macroscope.default()<cr>', desc = 'Macros' },
  { '<leader>sM', '<cmd>Telescope man_pages<cr>', desc = 'Man Pages' },
  { '<leader>sn', "<cmd>lua require('telescope').extensions.neoclip.default()<cr>", desc = 'Neoclip' },
  { '<leader>sN', '<cmd>Telescope notify<cr>', desc = ' Notifications' },
  { '<leader>sp', '<cmd>Telescope projects<cr>', desc = ' Projects' },
  { '<leader>sP', "<cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<cr>", desc = 'Colorscheme with Preview' },
  { '<leader>sr', '<cmd>Telescope oldfiles<cr>', desc = 'Recent File' },
  { '<leader>sR', '<cmd>Telescope registers<cr>', desc = 'Registers' },
  { '<leader>ss', '<cmd>Telescope grep_string<cr>', desc = 'Text under cursor' },
  { '<leader>sS', '<cmd>Telescope symbols<cr>', desc = 'Search Symbols' },
  { '<leader>st', '<cmd>Telescope live_grep<cr>', desc = 'Text' },
  { '<leader>sT', '<cmd>Telescope treesitter<cr>', desc = 'Treesitter' },
})


-- Telescope: <leader>t
wk.add({
  { '<leader>tb', "<CMD>Telescope buffers<CR>", desc = " Buffers" },
  { '<leader>tc', "<CMD>Telescope neoclip<CR>", desc = " Neoclip" },
  { '<leader>tC', "<CMD>Telescope cheat<CR>", desc = " Cheat" },
  { '<leader>te', "<CMD>Telescope env<CR>", desc = " Variable" },
  { '<leader>tk', "<CMD>Telescope pickers<CR>", desc = " Pickers" },
  { '<leader>tl', "<CMD>Telescope resume<CR>", desc = "Load previous state" },
  { '<leader>tm', "<CMD>Telescope marks<CR>", desc = " Marks" },
  { '<leader>tf', function() require("telescope").extensions.frecency.frecency() end, desc = "  Recent Files" },
  { '<leader>tF', "<CMD>Telescope file_structure<CR>", desc = " File Structure" },
  { '<leader>tm', "<CMD>Telescope heading<CR>", desc = "󰉫 Markdown Headings" },
  { '<leader>tn', "<CMD>Telescope notify<CR>", desc = " Notifications" },
  { '<leader>tp', "<cmd>lua require('telescope').extensions.projects.projects()<cr>", desc = ' Projects' },
  { '<leader>tq', "<CMD>Telescope ghq<CR>", desc = '  ghq' },
  { '<leader>tr', "<CMD>Telescope registers<CR>", desc = " Registers" },
  { "<leader>tR", "<CMD>Telescope recall<CR>", desc = " Recall" },
  { "<leader>ts", "<CMD>lua require('search').open()<CR>", desc = " Search" },
  { '<leader>tt', "<CMD>Telescope filetypes<CR>", desc = " Filetypes" },
  { '<leader>tu', function() require("telescope").extensions.undo.undo({ side_by_side = true }) end, desc = "󰑖 Undo" },
  { '<leader>tz', "<CMD>Telescope current_buffer_fuzzy_find<CR>", desc = " Current Buffer Fuzzy Find" },
  -- Web Browsing
  { '<leader>twb', "<CMD>lua require('browse').browse({ bookmarks = require('configs.telescope.browse') })<CR>", desc = " Browse bookmarks" },
  { '<leader>two', "<CMD>lua require('browse').open_bookmarks({ bookmarks = require('configs.telescope.browse') })<CR>", desc = " Open bookmarks" },
  { '<leader>twi', "<CMD>lua require('browse').input_search()<CR>", desc = "Input search" },
  -- Files
  { '<leader>tff', "<CMD>Telescope find_files<CR>", desc = " Find files" },
  { '<leader>tfF', "<CMD>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<CR>", desc = " Find files drop" },
  { '<leader>tfo', "<CMD>Telescope oldfiles<CR>", desc = " Old files" },
  { '<leader>tfw', "<CMD>Telescope live_grep<CR>", desc = " Word search [L]" },
  { '<leader>tfW', "<CMD>Telescope grep_string<CR>", desc = "Word search" },
  { '<leader>tfi', "<CMD>Telescope media_files<CR>", desc = "Media files" },
  { '<leader>tfz', "<CMD>Telescope file_browser<CR>", desc = " File browser" },
  { '<leader>tfc', "<CMD>Telescope zoxide list<CR>", desc = "ZOxide" },
  -- Git
  { '<leader>tgf', "<CMD>Telescope git_files<CR>", desc = " Files" },
  { '<leader>tgt', "<CMD>Telescope git_stash<CR>", desc = " Stash" },
  { '<leader>tgs', "<CMD>Telescope git_status<CR>", desc = " Status" },
  { '<leader>tgc', "<CMD>Telescope git_commits<CR>", desc = " Commits" },
  { '<leader>tgb', "<CMD>Telescope git_branches<CR>", desc = " Branches" },
  { '<leader>tgm', "<CMD>Telescope git_bcommits<CR>", desc = " BCommits" },
  { '<leader>tgd', function() require('telescope').extensions.git_diffs.diff_commits() end, desc = " Diffs" },
  { '<leader>tgr', "<CMD>Telescope repo<CR>", desc = " Repositories" },
  { '<leader>tG', group = ' Github' },
  { '<leader>tGi', function() require('telescope').extensions.gh.issues() end, desc = 'Issues' },
  { '<leader>tGp', function() require('telescope').extensions.gh.pull_request() end, desc = 'Pull Request' },
  { '<leader>tGg', function() require('telescope').extensions.gh.gist() end, desc = 'Gist' },
  { '<leader>tGr', function() require('telescope').extensions.gh.run() end, desc = 'Run GH' },
  -- Help
  { '<leader>thh', "<CMD>Telescope help_tags<CR>", desc = " Help tags" },
  { '<leader>thm', "<CMD>Telescope man_pages<CR>", desc = " Man Pages" },
  { '<leader>thc', "<CMD>Telescope cheatsheet<CR>", desc = " Cheatsheet" },
  { '<leader>tho', "<CMD>Telescope vim_options<CR>", desc = "הּ Vim options" },
  { '<leader>thp', "<CMD>Telescope commands<CR>", desc = " Vim commands" },
  { '<leader>thk', "<CMD>Telescope keymaps<CR>", desc = " Vim Mappings" },
  { '<leader>tha', "<CMD>Telescope autocommands<CR>", desc = "Vim autocmds" },
  -- History
  { '<leader>tHs', "<CMD>Telescope search_history<CR>", desc = " Search history" },
  { '<leader>tHc', "<CMD>Telescope command_history<CR>", desc = " Command history" },
  -- Glyphs and symbols
  { '<leader>tss', "<CMD>Telescope symbols<CR>", desc = " Symbols" },
  { '<leader>tse', "<CMD>Telescope emoji<CR>", desc = "  Emojis" },
  -- Code
  { '<leader>tcs', "<CMD>Telescope spell_suggest<CR>", desc = " Spelling" },
  { '<leader>tct', "<CMD>Telescope colorscheme<CR>", desc = " Change theme" },
  -- LSP
  { '<leader>tclw', "<CMD>Telescope lsp_dynamic_workspace_symbols<CR>", desc = " Dynamic workspace symbols" },
  { '<leader>tclA', "<CMD>Telescope lsp_range_code_actions<CR>", desc = " Range code actions" },
  { '<leader>tcls', "<CMD>Telescope lsp_workspace_symbols<CR>", desc = " Workspace symbols" },
  { '<leader>tclS', "<CMD>Telescope lsp_document_symbols<CR>", desc = " Document symbols" },
  { '<leader>tclD', "<CMD>Telescope lsp_type_definitions<CR>", desc = " Type definitions" },
  { '<leader>tcli', "<CMD>Telescope lsp_implementations<CR>", desc = " Implementations" },
  { '<leader>tcla', "<CMD>Telescope lsp_code_actions<CR>", desc = " Code actions" },
  { '<leader>tcld', "<CMD>Telescope lsp_definitions<CR>", desc = " Definitions" },
  { '<leader>tclr', "<CMD>Telescope lsp_references<CR>", desc = " References" },
})



-- Visits: <leader>v
wk.add({
  { "<leader>va", function() require("mini.visits").add_label() end, desc = "Add label" },
  { "<leader>vr", function() require("mini.visits").remove_label() end, desc = "Remove label" },
  { "<leader>vs", function() require("mini.visits").select_label("", nil) end, desc = "Select label (cwd)", },
  { "<leader>vS", function() require("mini.visits").select_label("", "") end, desc = "Select label (all)", },
  { "<leader>vv", function() require("mini.visits").select_path(vim.uv.cwd()) end, desc = "Visited path (cwd)", },
  { "<leader>vV", function() require("mini.visits").select_path("") end, desc = "Visited path (all)", },
  { "<leader>vp", function() require("mini.visits").list_paths() end, desc = "List Paths", },
  { "<leader>vl", function() require("mini.visits").list_labels() end, desc = "List Labels", },
  { "]v", function() require("mini.visits").iterate_paths("forward") end, desc = "Next visited path", },
  { "[v", function() require("mini.visits").iterate_paths("backward") end, desc = "Previous visited path", },
  { "]V", function() require("mini.visits").iterate_paths("last") end, desc = "Last visited path", },
  { "[V", function() require("mini.visits").iterate_paths("first") end, desc = "First visited path", },
})

-- Windows: <leader>w
wk.add({
  { '<leader>wp', '<c-w>x', desc = 'Swap' },
  { '<leader>wq', '<cmd>:q<cr>', desc = 'Close' },
  { '<leader>ws', '<cmd>:new<cr>', desc = 'Empty Horizontal Split' },
  { '<leader>wS', '<cmd>:split<cr>', desc = 'Horizontal Split' },
  { '<leader>wt', '<cmd>:tabnew<cr>', desc = 'New Tab' },
  { '<leader>wl', '<CMD>tablast<CR>', desc = ' Last Tab' },
  { '<leader>wf', '<CMD>tabfirst<CR>', desc = ' First Tab' },
  { '<leader>wr', '<CMD>tabrewind<CR>', desc = ' Rewind' },
  { '<leader>w=', '<c-w>=', desc = 'Equally size' },
  { '<leader>wv', '<cmd>:vnew<cr>', desc = 'Empty Vertical Split' },
  { '<leader>wV', '<cmd>:vsplit<cr>', desc = 'Vertical Split' },
  -- { '<leader>ww', "<cmd>lua require('nvim-window').pick()<cr>", desc = 'Choose window to jump' },
})

-- Workspace: <leader>W
wk.add({
  { '<leader>Wc', '<cmd>SessionStop<cr>', desc = ' Cancel Persistence' },
  { '<leader>Wd', '<cmd>SessionDelete<cr>', desc = ' Delete Persistence' },
  { '<leader>Wl', '<cmd>lua require("sessions").load()<cr>', desc = ' Load Session' },
  { '<leader>WL', '<cmd>SessionLoadLast<cr>', desc = ' Latest Persisted' },
  { '<leader>Ws', '<cmd>lua require("sessions").save()<cr>', desc = ' Save Session' },
  { '<leader>Wx', '<cmd>lua require("sessions").stop_autosave()<cr>', desc = 'Stop Session' },
  { '<leader>Wp', "<cmd>lua require('telescope').extensions.projects.projects()<cr>", desc = ' Projects' },
  { '<leader>WP', function() require('telescope').extensions.persisted.persisted() end, desc = '  Persisted' },
  { '<leader>Wo', '<cmd>SessionSelect<cr>', desc = '  Open Persisted' },
  { '<leader>WS', '<cmd>SessionSave<cr>', desc = '󰆓 Save Persistence' },
})


-- GPT
-- wk.add({
--   { "<leader>ag", "", desc = "" },
-- })


-- Telescope
-- wk.add({
--   { "<leader>a", "", desc = "" },
-- })


-- Terminal
-- wk.add({
--   { "<leader>a", "", desc = "" },
-- })


-- wk.add({
--   { "<leader>a", "", desc = "" },
-- })

--
-- wk.add({
--   { "<leader>o", ":Oil --float <CR>", desc = "Toggle Oil" },
-- })
--
-- wk.add({
--   { "<leader>f", "<cmd> :Telescope find_files <CR>", desc = "List Files" },
-- })
--
-- wk.add({
--   { "<leader>f", group = "FileManagement" },
--   {
--     "<leader>fa",
--     "<cmd> :Telescope find_files follow=true no_ignore=true hidden=true <CR>",
--     desc = "Find All Files (inc Hidden)",
--   },
-- })

-- wk.add({
--   { "<leader>b", "<cmd> :Telescope buffers<CR>", desc = "List Buffers" },
-- })
--
-- wk.add({
--   { "<leader>b",  group = "BufferManagement" },
--   { "<leader>bX", "<cmd> :bd! <CR>",         desc = "Force Close Current Buffer" },
--   { "<leader>bx", "<cmd> :bd <CR>",          desc = "Close Current Buffer" },
-- })
--
-- -- search
-- wk.add({
--   { "<leader>s", "<cmd> :Telescope live_grep <CR>", desc = "Search" },
-- })

--nnoremap gpd <cmd>lua require('goto-preview').goto_preview_definition()<CR>
--nnoremap gpt <cmd>lua require('goto-preview').goto_preview_type_definition()<CR>
--nnoremap gpi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>
--nnoremap gpD <cmd>lua require('goto-preview').goto_preview_declaration()<CR>
--nnoremap gP <cmd>lua require('goto-preview').close_all_win()<CR>
--nnoremap gpr <cmd>lua require('goto-preview').goto_preview_references()<CR>
--lsp
-- wk.add({
--   {
--     { "<leader>l",  group = "Lsp Actions" },
--     { "<leader>la", "<cmd> lua vim.lsp.buf.code_action()<CR>",                         desc = "Code Action" },
--     { "<leader>lg", "<cmd> lua vim.lsp.buf.definition()<CR>",                          desc = "Go To Definition" },
--     { "<leader>ld", "<cmd> lua require('goto-preview').goto_preview_definition()<CR>", desc = "Go To Definition In Preview" },
--     { "<leader>lq", "<cmd> lua require('goto-preview').close_all_win()<CR>",           desc = "Close Preview" },
--     { "<leader>lh", "<cmd> lua vim.lsp.buf.hover()<CR>",                               desc = "Hover" },
--     {
--       "<leader>li",
--       "<cmd>lua vim.lsp.buf.implementation()<CR>",
--       desc = "Go To Implementation",
--     },
--     { "<leader>lp", "<cmd>lua vim.lsp.buf.format()<CR>",         desc = "Format" },
--     { "<leader>lr", "<cmd>lua vim.lsp.buf.references()<CR>",     desc = "Go To References" },
--     { "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", desc = "Signature Help" },
--   },
-- })

-- wk.add({
--   { "<leader>e",  group = "Diagnostics" },
--   { "<leader>eg", "<cmd> Telescope diagnostics <CR>",          desc = "Show Diagnostics" },
--   { "<leader>eh", "<cmd> lua vim.diagnostic.open_float()<CR>", desc = "Error Hover" },
--   { "<leader>el", "<cmd> Telescope diagnostics bufnr=0 <CR>",  desc = "Show Diagnostics In Current Buffer" },
--   { "<leader>en", "<cmd> lua vim.diagnostic.goto_next()<CR>",  desc = "Error Next" },
--   { "<leader>ep", "<cmd> lua vim.diagnostic.goto_prev()<CR>",  desc = "Error Prev" },
-- })
--
-- wk.add({
--   { "<leader>x",  group = "Execute" },
--   { "<leader>xr", "<cmd> Rest run <CR>",                  desc = "Execute current http file" },
--   { "<leader>xe", "<cmd> Telescope rest select_env <cr>", desc = "Select Env" }
-- })
--
-- wk.add({
--   { "<leader>v",  group = "Emoji" },
--   { "<leader>ve", "<cmd>IconPickerInsert emoji<cr>",     desc = "Emoji" },
--   { "<leader>vn", "<cmd>IconPickerInsert nerd_font<cr>", desc = "Nerd Font" },
--   { "<leader>vg", "<cmd>IconPickerInsert symbols<cr>",   desc = "glyphs" },
--   { "<leader>vs", "<cmd>IconPickerInsert alt_cont<cr>",  desc = "Symbol" },
-- })

-- map("n", "<leader>gn", "]s")
-- map("n", "<leader>gp", "[s")
-- map("n", "<leader>gg", "zg")
-- map("n", "<ESC>", "<cmd> :noh <CR>")
-- map("x", "p", "P")

