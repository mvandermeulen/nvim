local M = {}

M.mappings = {
  ["name"] = " Telescope",
  ["a"] = {
    ["name"] = "ﰍ Web browse",
    ["b"] = {
      "<CMD>lua require('browse').browse({ bookmarks = require('configs.telescope.browse') })<CR>",
      " Browse bookmarks",
    },
    ["o"] = {
      "<CMD>lua require('browse').open_bookmarks({ bookmarks = require('configs.telescope.browse') })<CR>",
      " Open bookmarks",
    },
    ["i"] = { "<CMD>lua require('browse').input_search()<CR>", " Input search" },
  },
  ["b"] = { "<CMD>Telescope buffers<CR>", " Buffers" },
  ["c"] = { "<CMD>Telescope neoclip<CR>", " Neoclip" },
    -- C = { '<cmd>lua require("fzf-lua").command_history()<cr>', ' Command History' },
  ["e"] = { "<CMD>Telescope env<CR>", " Variable" },
  ["f"] = {
    ["name"] = " File operations",
    ["f"] = { "<CMD>Telescope find_files<CR>", " Find files" },
    ["F"] = {
      "<CMD>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<CR>",
      " Find files drop",
    },
    ["o"] = { "<CMD>Telescope oldfiles<CR>", " Old files" },
    ["w"] = { "<CMD>Telescope live_grep<CR>", " Word search [L]" },
    ["W"] = { "<CMD>Telescope grep_string<CR>", " Word search" },
    ["i"] = { "<CMD>Telescope media_files<CR>", " Media files" },
    ["z"] = { "<CMD>Telescope file_browser<CR>", " File browser" },
    ["c"] = { "<CMD>Telescope zoxide list<CR>", " ZOxide" },
  },
  ["g"] = {
    ["name"] = " Git files",
    ["f"] = { "<CMD>Telescope git_files<CR>", " Files" },
    ["t"] = { "<CMD>Telescope git_stash<CR>", " Stash" },
    ["s"] = { "<CMD>Telescope git_status<CR>", " Status" },
    ["c"] = { "<CMD>Telescope git_commits<CR>", " Commits" },
    ["b"] = { "<CMD>Telescope git_branches<CR>", " Branches" },
    ["m"] = { "<CMD>Telescope git_bcommits<CR>", " BCommits" },
    ["r"] = { "<CMD>Telescope repo<CR>", " Repositories" },
  },
  ["h"] = {
    ["name"] = " Help",
    ["h"] = { "<CMD>Telescope help_tags<CR>", " Help tags" },
    ["m"] = { "<CMD>Telescope man_pages<CR>", " Man Pages" },
    ["c"] = { "<CMD>Telescope cheatsheet<CR>", " Cheatsheet" },
    ["o"] = { "<CMD>Telescope vim_options<CR>", "הּ Vim options" },
    ["p"] = { "<CMD>Telescope commands<CR>", " Vim commands" },
    ["k"] = { "<CMD>Telescope keymaps<CR>", " Vim Mappings" },
    ["a"] = { "<CMD>Telescope autocommands<CR>", " Vim autocmds" },
  },
  ["H"] = {
    ["name"] = "History",
    ["s"] = { "<CMD>Telescope search_history<CR>", " Search history" },
    ["c"] = { "<CMD>Telescope command_history<CR>", " Command history" },
  },
  ["k"] = { "<CMD>Telescope pickers<CR>", " Pickers" },
  ["l"] = { "<CMD>Telescope resume<CR>", "Load previous state" },
  ["m"] = { "<CMD>Telescope marks<CR>", "Marks" },
  ["n"] = { "<CMD>Telescope notify<CR>", " Notifications" },
  ["p"] = {
    ["name"] = " Projects",
    ["o"] = { "<CMD>Telescope projects<CR>", "Open" },
    ["l"] = { "<CMD>Telescope resume<CR>", "Load Previous" },
    ["w"] = { "<CMD>Telescope workspaces<CR>", "Workspaces" },
  },
  ["P"] = { "<CMD>Telescope projects<CR>", "" },
  ["r"] = { "<CMD>Telescope registers<CR>", " Registers" },
  ["s"] = {
    ["name"] = "Glyphs and symbols",
    -- ["name"] = "ﲃ Glyphs and symbols",
    ["s"] = { "<CMD>Telescope symbols<CR>", " Symbols" },
    ["e"] = { "<CMD>Telescope emoji<CR>", "  Emojis" },
  },
  ["t"] = { "<CMD>Telescope filetypes<CR>", " Filetypes" },
  ["w"] = {
    ["name"] = " Code",
    ["s"] = { "<CMD>Telescope spell_suggest<CR>", " Spelling" },
    ["t"] = { "<CMD>Telescope colorscheme<CR>", " Change theme" },
    ["l"] = {
      ["name"] = " LSP",
      ["w"] = { "<CMD>Telescope lsp_dynamic_workspace_symbols<CR>", " Dynamic workspace symbols" },
      ["A"] = { "<CMD>Telescope lsp_range_code_actions<CR>", " Range code actions" },
      ["s"] = { "<CMD>Telescope lsp_workspace_symbols<CR>", " Workspace symbols" },
      ["S"] = { "<CMD>Telescope lsp_document_symbols<CR>", " Document symbols" },
      ["D"] = { "<CMD>Telescope lsp_type_definitions<CR>", " Type definitions" },
      ["i"] = { "<CMD>Telescope lsp_implementations<CR>", " Implementations" },
      ["a"] = { "<CMD>Telescope lsp_code_actions<CR>", " Code actions" },
      ["d"] = { "<CMD>Telescope lsp_definitions<CR>", " Definitions" },
      ["r"] = { "<CMD>Telescope lsp_references<CR>", " References" },
    },
  },
  ["z"] = { "<CMD>Telescope current_buffer_fuzzy_find<CR>", " FZF" },
}

M.options = {
  mode = "n",
  prefix = "<leader>T",
  silent = true,
  noremap = true,
  nowait = false,
}

return M

-- vim:ft=lua
