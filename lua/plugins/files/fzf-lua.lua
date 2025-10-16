--[[
-- FZF
-- Author: Mark van der Meulen
-- Updated: 2025-06-10
--]]

local status_ok, fzf_lua = pcall(require, 'fzf-lua')
if not status_ok then
  return
end

local fzf_config = require('helpers.plugins.fzf_config')


--------------------------------------
---------- Helper Functions ----------
--------------------------------------
-- Create KeyMap Options (kmo)
local function kmo(desc)
  return { noremap = true, silent = true, desc = desc }
end


---------------------------
---------- Setup ----------
---------------------------
fzf_lua.setup({
  fzf_config.profile_name,
  keymap = {
    builtin     = fzf_config.keymap_builtin,
    fzf         = fzf_config.keymap_fzf,
  },
  -- winopts       = fzf_config.window_configs.custom,
  git           = fzf_config.git_config,
  actions = {
    files       = fzf_config.files_actions,
    buffers     = fzf_config.buffers_actions,
  },
  lsp = {
    symbols = fzf_config.lsp_document_symbols_config,
  },
  oldfiles      = fzf_config.oldfiles_config,
  grep          = fzf_config.grep_config,
  buffers       = fzf_config.buffers_config,
  tabs          = fzf_config.tabs_config,
  files         = fzf_config.files_config,
  -- fzf_colors    = fzf_config.colorschemes_config.standard,
  fzf_opts      = fzf_config.global_fzf_opts,
  previewers    = fzf_config.fzf_previewers_config,
  defaults      = fzf_config.fzf_defaults_config,
})


------------------------------
---------- UI Setup ----------
------------------------------
fzf_lua.register_ui_select(function(_, items)
  -- use `fzf-lua` for replace vim.ui.select 
  -- https://github.com/ibhagwan/fzf-lua/wiki#ui-select-auto-size
  local min_h, max_h = 0.15, 0.70
  local h = (#items + 4) / vim.o.lines
  if h < min_h then
    h = min_h
  elseif h > max_h then
    h = max_h
  end
  return { winopts = { height = h, width = 0.60, row = 0.40 } }
end)


----------------------------------
---------- Key Mappings ----------
----------------------------------

----- Control Modifier
----- Mappings: C-p, C-x, C-, , C-., C-]
-- vim.keymap.set("n", "<C-P>", function() require('fzf-lua').live_grep_resume() end, kmo("Search"))
vim.keymap.set("n", "<C-p>", function() require('fzf-lua').live_grep() end, kmo("Search"))
-- 2025-09-20: <C-,> will be used by Claude Code going forward.
-- vim.keymap.set("n", "<C-,>", function() require('fzf-lua').files({ resume = false }) end, kmo("Files"))
-- vim.keymap.set("n", "<C-.>", function() require('fzf-lua').oldfiles() end, kmo("Recent Files"))
-- 2025-09-20: removed <C-.> mapping and replace with C-S-F via Cmd-F
vim.keymap.set("n", "<C-S-F>", function() require('fzf-lua').files({ resume = false }) end, kmo("Files"))
-- 2025-09-20: removed <C-,> mapping to avoid conflict with Claude Code.
-- vim.keymap.set("n", "<C-,>", function() require('fzf-lua').oldfiles() end, kmo("Recent Files"))

-- vim.keymap.set("n", "<C-t>", function() require('fzf-lua').tabs() end, kmo("Tabs"))
-- 2025-09-20: removed <C-]> mapping and replace with C-S-B via Cmd-B
vim.keymap.set("n", "<C-S-B>", function() require('fzf-lua').buffers() end, kmo("Buffers"))
-- vim.keymap.set("n", "<C-/>", function() require('fzf-lua').lsp_document_symbols() end, kmo("LSP Document Symbols"))
-- vim.keymap.set("n", "<C-'>", function() require('fzf-lua').lsp_live_workspace_symbols() end, kmo("Live Workspace Symbols"))
-- vim.keymap.set({ "i" }, "<C-x><C-f>",
--   function()
--     require("fzf-lua").complete_file({
--       cmd = "rg --files",
--       winopts = { preview = { hidden = "nohidden" } }
--     })
--   end, { silent = true, desc = "Fuzzy complete file" })

vim.keymap.set({ "n", "v", "i" }, "<C-x><C-f>", function() require("fzf-lua").complete_path() end, { silent = true, desc = "Fuzzy complete path" })


----- Control + Shift Modifier
vim.keymap.set("n", "<C-S-E>", function() require('fzf-lua').lsp_document_symbols() end, kmo("LSP Document Symbols"))
vim.keymap.set("n", "<C-S-W>", function() require('fzf-lua').lsp_live_workspace_symbols() end, kmo("Live Workspace Symbols"))
-- Misc
vim.keymap.set("n", "<C-S-J>", function() require('fzf-lua').commands() end, kmo("Commands"))
vim.keymap.set("n", "<C-S-K>", function() require('fzf-lua').keymaps() end, kmo("Keymaps"))
vim.keymap.set("n", "<C-S-L>", function() require('fzf-lua').lines() end, kmo("Lines"))
vim.keymap.set("n", "<C-S-P>", function() require('fzf-lua').resume() end, kmo("Resume"))
vim.keymap.set("n", "<C-S-G>", function() require('fzf-lua').grep_project() end, kmo("Grep Project"))
vim.keymap.set("n", "<C-S-T>", function() require('fzf-lua').tabs() end, kmo("Tabs"))
vim.keymap.set("n", "<C-S-U>", function() require('fzf-lua').grep_cword() end, kmo("Current Word"))


----- Leader
-- <leader>f
vim.keymap.set("n", "<leader>fb", function() require('fzf-lua').buffers() end, kmo("Buffers"))
-- vim.keymap.set("n", "<leader>fd", function() require('fzf-lua').lsp_document_symbols() end, kmo("LSP Document Symbols"))
vim.keymap.set("n", "<leader>ft", function() require('fzf-lua').tabs() end, kmo("Tabs"))
vim.keymap.set("n", "<leader>fT", function() require('fzf-lua').treesitter() end, kmo("Treesitter"))
vim.keymap.set("n", "<leader>fL", function() require('fzf-lua').lines() end, kmo("Lines"))
vim.keymap.set("n", "<leader>fo", function() require('fzf-lua').oldfiles() end, kmo("Recent Files"))
vim.keymap.set("n", "<leader>fG", function() require('fzf-lua').grep() end, kmo("Grep"))
-- vim.keymap.set("n", "<leader>fp", function() require('fzf-lua').grep_project() end, kmo("Grep Project"))
vim.keymap.set("n", "<leader>fp", function() require('fzf-lua').profiles() end, kmo("Profiles"))
vim.keymap.set("n", "<leader>fm", function() require('fzf-lua').marks() end, kmo("Marks"))
vim.keymap.set("n", "<leader>fj", function() require('fzf-lua').jumps() end, kmo("Jumps"))
vim.keymap.set("n", "<leader>fC", function() require('fzf-lua').changes() end, kmo("Changes"))
vim.keymap.set("n", "<leader>fr", function() require('fzf-lua').registers() end, kmo("Registers"))
vim.keymap.set("n", "<leader>fa", function() require('fzf-lua').autocmds() end, kmo("Autocommands"))
vim.keymap.set("n", "<leader>fk", function() require('fzf-lua').keymaps() end, kmo("Keymaps"))
vim.keymap.set("n", "<leader>fM", function() require('fzf-lua').menus() end, kmo("Menus"))
vim.keymap.set("n", "<leader>fB", function() require('fzf-lua').tmux_buffers() end, kmo("Tmux Buffers"))
-- Git
vim.keymap.set("n", "<leader>fgs", function() require('fzf-lua').git_status() end, kmo("Git Status"))
vim.keymap.set("n", "<leader>fgb", function() require('fzf-lua').git_blame() end, kmo("Git Blame"))
-- DAP
vim.keymap.set("n", "<leader>fdc", function() require('fzf-lua').dap_commands() end, kmo("DAP Commands"))
vim.keymap.set("n", "<leader>fdv", function() require('fzf-lua').dap_variables() end, kmo("DAP Variables"))
vim.keymap.set("n", "<leader>fdf", function() require('fzf-lua').dap_frames() end, kmo("DAP Frames"))
vim.keymap.set("n", "<leader>fdb", function() require('fzf-lua').dap_breakpoints() end, kmo("DAP Breakpoints"))
vim.keymap.set("n", "<leader>fdd", function() require('fzf-lua').dap_configurations() end, kmo("DAP Configurations"))
-- LSP
vim.keymap.set("n", "<leader>flr", function() require('fzf-lua').lsp_references() end, kmo("LSP References"))
vim.keymap.set("n", "<leader>fld", function() require('fzf-lua').lsp_definitions() end, kmo("LSP Definitions"))
vim.keymap.set("n", "<leader>flD", function() require('fzf-lua').lsp_declarations() end, kmo("LSP Declarations"))
vim.keymap.set("n", "<leader>flt", function() require('fzf-lua').lsp_typedefs() end, kmo("LSP Typedefs"))
vim.keymap.set("n", "<leader>fli", function() require('fzf-lua').lsp_implementations() end, kmo("LSP Implementations"))
vim.keymap.set("n", "<leader>fls", function() require('fzf-lua').lsp_document_symbols() end, kmo("LSP Document Symbols"))
vim.keymap.set("n", "<leader>flw", function() require('fzf-lua').lsp_live_workspace_symbols() end, kmo("Live Workspace Symbols"))
vim.keymap.set("n", "<leader>flW", function() require('fzf-lua').lsp_workspace_symbols() end, kmo("LSP Workspace Symbols"))
vim.keymap.set("n", "<leader>flc", function() require('fzf-lua').lsp_incoming_calls() end, kmo("LSP Incoming Calls"))
vim.keymap.set("n", "<leader>flC", function() require('fzf-lua').lsp_outgoing_calls() end, kmo("LSP Outgoing Calls"))
vim.keymap.set("n", "<leader>fla", function() require('fzf-lua').lsp_code_actions() end, kmo("LSP Code Actions"))
vim.keymap.set("n", "<leader>flf", function() require('fzf-lua').lsp_finder() end, kmo("LSP Finder"))
vim.keymap.set("n", "<leader>flx", function() require('fzf-lua').diagnostics_document() end, kmo("Document Diagnostics"))
vim.keymap.set("n", "<leader>flX", function() require('fzf-lua').diagnostics_workspace() end, kmo("Workspace Diagnostics"))

-- Tmux integration pickers
vim.keymap.set("n", '<leader>tw', function() require('helpers.plugins.fzf-pickers.tmux').tmux_windows() end, kmo('Tmux windows (current session)'))
vim.keymap.set("n", '<leader>ts', function() require('helpers.plugins.fzf-pickers.tmux').tmux_sessions() end, kmo('Tmux sessions'))
vim.keymap.set("n", '<leader>tm', function() require('helpers.plugins.fzf-pickers.tmux').code_projects() end, kmo('Code projects (~/code tmux sessions)'))
vim.keymap.set("n", '<leader>tc', function() require('helpers.plugins.fzf-pickers.tmux').claude_activity_windows() end, kmo('Claude activity windows'))


