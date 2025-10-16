local wk = require("which-key")

-- Global Mappings
wk.add({
  { "<leader>C", "<cmd>Cheatsheet<cr>", desc = "Cheatsheet" },
  -- { "<leader>L", "<cmd>:Lazy<cr>", desc = "Lazy" },
  -- { "<leader>n", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" },
  -- { "<leader>q", "<cmd>NvimTreeClose<cr>:q<cr>", desc = "Close Window" },
  { "<leader>q", ":q<cr>", desc = "Close Window" },
  { "<leader>D", '"_dP', desc = "Blackhole Delete" },
  -- { "<leader>q", "<cmd>NvimTreeClose<cr>:q<cr>", desc = "  Close Window" },
  -- { "<leader>Q", "<cmd>NvimTreeClose<cr><cmd>qa<cr>", desc = "  Close Window" },
  -- { "<leader>x", ":TSContextDisable<cr>:TSBufDisable rainbow<cr>:TSBufDisable highlight<cr><cmd>Bdelete<cr>", desc = "  Close Buffer" },
  { "<leader>x", "<CMD>BufferDelete<CR>", desc = "Close Buffer" },
  { "<leader>;", "<c-w>w", desc = "Switch Pane" },
  -- { "<leader>y", "<CMD>YankBank<CR>", desc = "YankBank" },
  -- { "<leader>x", "<CMD>BufferDelete<CR>", desc = "  Close Buffer" },
  -- { "<C-_>", "<Plug>(comment_toggle_linewise_current)", desc = "  Comment Line" },
  -- { "<leader>", "", desc = "" },
  -- { "<leader>", "", desc = "" },
})

-- Application Mappings: <leader>a
wk.add(require('mappings.applications'))
-- AI: <leader>A
wk.add(require('mappings.ai'))
-- Buffers: <leader>b
wk.add(require('mappings.buffers'))
-- Tabs: <leader>B
wk.add(require('mappings.tabs'))
-- Copilot: <leader>c
-- Copilot Chat: <leader>cc
wk.add(require('mappings.copilot'))
-- Diagnostics: <leader>d
wk.add(require('mappings.diagnostics'))
-- Editor: <leader>e
-- Glance, GitOpen, Grapple, GistsList, GistCreate, GistCreateFromFile, Inspect, JQ, KeyAnalyzer, Learn
-- Neogit, Outline, OutlineStatus, OutlineToggle, Portal, Pretty, PinBuffer, ProjectRoot, PDF, RootDir
-- Registers, RecallMark, ReloadConfig, ReviewChanges, Redir, SQL, Stash, TabMessage, TmuxLayout
-- Unpin, VGit, WorkspacesList, WorkspacesAdd, WorksspacesAddDir, YankBank, Yazi, 
wk.add(require('mappings.editor'))
-- Find: <leader>f
wk.add(require('mappings.find'))
-- Files: <leader>F
wk.add(require('mappings.files'))
-- Git: <leader>g
wk.add(require('mappings.git'))
-- Inserts: <leader>I
wk.add(require('mappings.inserts'))
-- LSP: <leader>l
wk.add(require('mappings.lsp'))
-- Misc: <leader>m
-- wk.add(require('mappings.misc'))
-- Search: <leader>s
wk.add(require('mappings.search'))
-- Telescope: <leader>t
wk.add(require('mappings.telescope'))
-- Visits: <leader>v
wk.add(require('mappings.visits'))
-- Windows: <leader>w
wk.add(require('mappings.windows'))
-- Workspace: <leader>W
wk.add(require('mappings.workspace'))


-- Focus: <leader>af
-- wk.add({
--   { "<leader>afz", "<cmd>:ZenMode<cr>", desc = "Toggle Zen Mode" },
--   { "<leader>aft", "<cmd>:Twilight<cr>", desc = "Toggle Twilight" },
-- })

-- Marks
-- wk.add({
  -- Recall maps: Mm, Mn, Mp, Mc, Ml
  -- Bookmarks maps: Mb[ta<BS>lr[]]
  -- Grapple maps: Mg[wtnp]
  -- { "<leader>M", "", desc = "" },
  -- { "<leader>M", "", desc = "" },
-- })



-- UI: <leader>u
-- wk.add({
--   { "<leader>u", "<CMD><CR>", desc = "" },
--   { "<leader>u", "<CMD><CR>", desc = "" },
--   { "<leader>u", "<CMD><CR>", desc = "" },
-- })

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

