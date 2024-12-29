--[[
-- FZF
-- Author: Mark van der Meulen
-- Updated: 16-05-2022
--]]

local status_ok, fzf_lua = pcall(require, 'fzf-lua')
if not status_ok then
  return
end

-- local actions = require 'fzf-lua.actions'
local actions = require('fzf-lua.actions')

fzf_lua.setup({
  "borderless",
  keymap = {
    builtin = {
      ["<C-p>"] = "toggle-preview",
      ['<M-f>'] = 'toggle-fullscreen',
      ['<M-d>'] = 'preview-page-down',
      ['<M-u>'] = 'preview-page-up',
      ['<M-k>'] = 'first',
      ['<M-j>'] = 'last',
    },
    fzf = {
      ['ctrl-r']      = 'select-all+accept',
      ["ctrl-a"]      = "beginning-of-line",
      ["ctrl-e"]      = "end-of-line",
      ["alt-a"]       = "toggle-all",
      ["alt-g"]       = "first",
      ["alt-G"]       = "last",
      ["f3"]          = "toggle-preview-wrap",
      ["f4"]          = "toggle-preview",
      ["ctrl-f"]      = "preview-page-down",
      ["ctrl-b"]      = "preview-page-up",
      -- ["tab"]         = "down",
      -- ["shift-tab"]   = "up",
    },
  },
  winopts = {
    border = "none",
    height = 0.75,
    width = 0.80,
    preview = {
      border = "none",
      layout = 'flex',
      flip_columns = 180,
      scrollbar = 'float',
      -- default = 'bat',
      -- horizontal = 'right:50%',
      delay = 50,
      -- scrollbar = false,
      -- winopts = { number = false },
      -- hidden = "hidden",
    },
  },
  actions = {
    files = {
      ["enter"] = actions.file_edit_or_qf,
      ['default'] = actions.file_edit_or_qf,
      ['ctrl-t'] = actions.file_tabedit,
      ['ctrl-x'] = actions.file_split,
      ['ctrl-v'] = actions.file_vsplit,
    },
  },
  oldfiles = {
    include_current_session = true,
  },
})

local function kmo(desc)
  return { noremap = true, silent = true, desc = desc }
end

-- vim.keymap.set("n", "<C-P>", function() require('fzf-lua').live_grep_resume() end, kmo("Search"))
vim.keymap.set("n", "<C-p>", function() require('fzf-lua').live_grep() end, kmo("Search"))
vim.keymap.set("n", "<C-,>", function() require('fzf-lua').files({ resume = false }) end, kmo("Files"))
vim.keymap.set("n", "<C-.>", function() require('fzf-lua').oldfiles() end, kmo("Recent Files"))
-- vim.keymap.set("n", "<C-t>", function() require('fzf-lua').tabs() end, kmo("Tabs"))
vim.keymap.set("n", "<C-]>", function() require('fzf-lua').buffers() end, kmo("Buffers"))
vim.keymap.set("n", "<C-/>", function() require('fzf-lua').lsp_document_symbols() end, kmo("LSP Document Symbols"))
vim.keymap.set("n", "<C-'>", function() require('fzf-lua').lsp_live_workspace_symbols() end, kmo("Live Workspace Symbols"))
-- <leader>f
vim.keymap.set("n", "<leader>fb", function() require('fzf-lua').buffers() end, kmo("Buffers"))
vim.keymap.set("n", "<leader>ft", function() require('fzf-lua').tabs() end, kmo("Tabs"))
vim.keymap.set("n", "<leader>fT", function() require('fzf-lua').treesitter() end, kmo("Treesitter"))
vim.keymap.set("n", "<leader>fL", function() require('fzf-lua').lines() end, kmo("Lines"))
vim.keymap.set("n", "<leader>fo", function() require('fzf-lua').oldfiles() end, kmo("Recent Files"))
vim.keymap.set("n", "<leader>fc", function() require('fzf-lua').grep_cword() end, kmo("Current Word"))
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
vim.keymap.set("n", "<C-S-K>", function() require('fzf-lua').commands() end, kmo("Commands"))

-- vim.keymap.set({ "i" }, "<C-x><C-f>",
--   function()
--     require("fzf-lua").complete_file({
--       cmd = "rg --files",
--       winopts = { preview = { hidden = "nohidden" } }
--     })
--   end, { silent = true, desc = "Fuzzy complete file" })

vim.keymap.set({ "n", "v", "i" }, "<C-x><C-f>", function() require("fzf-lua").complete_path() end, { silent = true, desc = "Fuzzy complete path" })
