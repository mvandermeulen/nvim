--[[
-- Key Mappings
--
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]


-----------------------------------------------
-- Helpers
-----------------------------------------------

default_options = { noremap = true, silent = true }
expr_options = { noremap = true, expr = true, silent = true }

-- Function for make mapping easier.
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

require("helpers.unimpaired")

-----------------------------------------------
-- Map Leader Key & Local Leader
-----------------------------------------------

map("n", "<Space>", "<NOP>", default_options) -- map the leader key
vim.g.mapleader = " "

require("mappings.local")


-----------------------------------------------
-- Mappings: NORMAL mode
-----------------------------------------------

-------------------------------
-- Standard Keys
-------------------------------
map("n", ";", ":") -- Remap semicolon for commands
map("n", ";;", ";") -- Remap semicolon for commands
map("n", "0", "^") -- use 0 to go to first char of line
map("n", "n", "nzz", default_options) -- center search results
map("n", "N", "Nzz", default_options) -- center search results
map("n", "k", "v:count == 0 ? 'gk' : 'k'", expr_options) -- Deal with visual line wraps
map("n", "j", "v:count == 0 ? 'gj' : 'j'", expr_options) -- Deal with visual line wraps
map("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>", default_options) -- Cancel search highlighting with ESC
map("n", "m/", "<cmd>MarksListAll<CR>", default_options) -- Marks from all opened buffers


-------------------------------
-- Arrow Keys
-------------------------------
map("n", "<Left>", ":vertical resize +1<CR>", default_options)
map("n", "<Right>", ":vertical resize -1<CR>", default_options)
map("n", "<Up>", ":resize -1<CR>", default_options)
map("n", "<Down>", ":resize +1<CR>", default_options)


-------------------------------
-- Function Keys
-------------------------------
map("n", "<F13>", ":NvimTreeToggle<cr>", default_options)
map("n", "<F14>", ":Twilight<CR>", default_options)
map("n", "<F16>", ":ZenMode<CR>", default_options)


-------------------------------
-- Leader Keys
-------------------------------

-- NOTE: These should be mapped in the which-key plugin configuration

-- Easier save/open/close
--keymap("n", "<Leader>w", ":w<CR>")                                      -- write with w
--keymap("n", "<Leader>q", ":q<CR>")                                      -- quit with q
--keymap("n", "<Leader>qq", ":q!<CR>")                                    -- space + qq to force quit
--map('n', '<leader>j', [[<cmd>m-2|j<cr>]])                                 -- Join line above at end of current
-- map("n", "<leader><leader>M", ":lua require'telegraph'.telegraph({how='tmux_popup', cmd='man '})<Left><Left><Left>", default_options)

-------------------------------
-- Keys w Modifiers
-------------------------------
map("n", "<TAB>", ":bnext<CR>", default_options)
map("n", "<S-TAB>", ":bprevious<CR>", default_options)


--------------------
-- Shift Modifier
--------------------
map("n", "<S-Right>", ":tabnext<CR>")
map("n", "<S-Left>", ":tabprev<CR>")
map("n", "<S-Up>", ":BufferLineCyclePrev<CR>")
map("n", "<S-Down>", ":BufferLineCycleNext<CR>")
map("n", "<S-L>", ":tabnext<CR>")
map("n", "<S-H>", ":tabprev<CR>")
map("n", "<S-CR>", ":Twilight<CR>", default_options)
map("n", "<S-Space>", ":ZenMode<CR>", default_options)


--------------------
-- Meta Modifier
--------------------
map("n", "<M-j>", [[<cmd>m.+1<cr>==]])
map("n", "<M-k>", [[<cmd>m.-2<cr>==]])
map("i", "<M-j>", [[<esc><cmd>m.+1<cr>==]])
map("i", "<M-k>", [[<esc><cmd>m.-2<cr>==]])
map("n", "<M-S-Up>", ":resize -2<CR>")
map("n", "<M-S-Down>", ":resize +2<CR>")
map("n", "<M-S-Left>", ":vertical resize -2<CR>")
map("n", "<M-S-Right>", ":vertical resize +2<CR>")


--------------------
-- Ctrl Modifier
--------------------
-- map("n", "<C-e>", "2<C-e>")
-- map("n", "<C-y>", "2<C-y>")
-- map("n", "<C-U>", "<Esc>viwUi", default_options) -- Capitalize word on letter
map("n", "<C-S>", ":w<CR>") -- write with w
map("n", "<C-T>", "<cmd>lua require('telescope').extensions.tele_tabby.list()<CR>") -- write with w
map("n", "<C-CR>", ":NvimTreeToggle<CR>", default_options)
-- map("n", "<C-/>", "<Plug>(comment_toggle_linewise_current)", default_options)
-- map("n", "<C-->", "<Plug>(comment_toggle_linewise_current)", default_options)
map("n", "<C-\\>", "<Plug>(comment_toggle_linewise_current)", default_options)


-- Term
--map('t', '<Esc>', '<C-\\><C-n>')

-- Tab switch buffer
-- Buffer switching.
--map("n", "<S-Tab>", ":BufferLineCyclePrev<CR>")
--map("n", "<Tab>", ":BufferLineCycleNext<CR>")

-- Buffer resizing.
--map("n", "<S-h>", ":call ResizeLeft(3)<CR><Esc>")
--map("n", "<S-l>", ":call ResizeRight(3)<CR><Esc>")
--map("n", "<S-k>", ":call ResizeUp(1)<CR><Esc>")
--map("n", "<S-j>", ":call ResizeDown(1)<CR><Esc>")

-- Split navigations.
--map("n", "<A-j>", "<C-w><C-j>")
--map("n", "<A-k>", "<C-w><C-k>")
--map("n", "<A-l>", "<C-w><C-l>")
--map("n", "<A-h>", "<C-w><C-h>")

-- Save and load session/Dashboard.
--map("n", "<Leader>db", ":Dashboard<CR>")
--map("n", "<C-s>l", ":SessionLoad<CR>")
--map("n", "<C-s>s", ":SessionSave<CR>")

-- ToggleTerm
--function _G.set_terminal_keymaps()
--map("t", "<esc>", "<C-\\><C-n>")
--map("t", "<A-h>", "<c-\\><c-n><c-w>h")
--map("t", "<A-j>", "<c-\\><c-n><c-w>j")
--map("t", "<A-k>", "<c-\\><c-n><c-w>k")
--map("t", "<A-l>", "<c-\\><c-n><c-w>l")

--map("t", "<S-h>", "<c-\\><C-n>:call ResizeLeft(3)<CR>")
--map("t", "<S-j>", "<c-\\><C-n>:call ResizeDown(1)<CR>")
--map("t", "<S-k>", "<c-\\><C-n>:call ResizeUp(1)<CR>")
--map("t", "<S-l>", "<c-\\><C-n>:call ResizeRight(3)<CR>")
--end
--vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

-- comment
--vim.g.kommentary_create_default_mappings = false
--vim.api.nvim_set_keymap("n", "<leader>ct", "<Plug>kommentary_line_default", {})
--vim.api.nvim_set_keymap("v", "<leader>ct", "<Plug>kommentary_visual_default", {})

-- starlite mappings
--map("n", "*", "<cmd>lua require'starlite'.star()<CR>", default_options)
--map("n", "g*", "<cmd>lua require'starlite'.g_star()<CR>", default_options)
--map("n", "#", "<cmd>lua require'starlite'.hash()<CR>", default_options)
--map("n", "g#", "<cmd>lua require'starlite'.g_hash()<CR>", default_options)

-- TODO: Doesn't work
-- FIXED
map("n", "<C-,>", ":FzfLua files<CR>")
map("n", "<C-P>", ":FzfLua<CR>")

--map("n", "", "")

--map("n", "", "")
--map("n", "", "")

--map("n", "", "")
--map("n", "", "")

-----------------------------------------------
-- Mappings: VISUAL Mode
-----------------------------------------------

-- better indenting
map("v", "<", "<gv", default_options)
map("v", ">", ">gv", default_options)

map("v", "p", '"_dP', default_options) -- paste over currently selected text without yanking it
--map("v", "p", '"_dP')                                                    -- Don't copy the replaced text after pasting.

-- Move selected line / block of text in visual mode
map("v", "K", ":move '<-2<CR>gv-gv", default_options)
map("v", "J", ":move '>+1<CR>gv-gv", default_options)

-----------------------------------------------
-- Mappings: INSERT Mode
-----------------------------------------------

function EscapePair()
	local closers = { ")", "]", "}", ">", "'", '"', "`", "," }
	local line = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local after = line:sub(col + 1, -1)
	local closer_col = #after + 1
	local closer_i = nil
	for i, closer in ipairs(closers) do
		local cur_index, _ = after:find(closer)
		if cur_index and (cur_index < closer_col) then
			closer_col = cur_index
			closer_i = i
		end
	end
	if closer_i then
		vim.api.nvim_win_set_cursor(0, { row, col + closer_col })
	else
		vim.api.nvim_win_set_cursor(0, { row, col + 1 })
	end
end

map("i", "<C-L>", "<cmd>lua EscapePair()<CR>", default_options)

-------------------------------
-- Keys w Modifiers
-------------------------------

map("i", "<C-U>", "<Esc>viwUi", default_options)


local M = {}

M.mappings = {
  misc = {
    cheatsheet = '<leader>ch',
    close_buffer = '<leader>x',
    clear_all_buffers = '<leader>da',
    scratch_buffer = '<leader>B',
    delete_other_buffers = '<Leader>on',
    toggle_last_file = '<Leader><Leader>',
    line_number_toggle = '<leader>n', -- toggle line number
    relative_line_number_toggle = '<leader>rn',
    -- go_to_matching = '<C-Tab>',
    new_buffer = '<S-t>',
    new_tab = '<C-t>b',
    save_file = '<C-s>', -- save file using :w
    no_highlight = '<Esc>',
    refocus_fold = '<localleader>z',
    open_all_folds = 'zO',
    recent_40_messages = 'g>',
    blank_line_above = '[<space>',
    blank_line_below = ']<space>',
    line_move_up = '<A-k>',
    line_move_down = '<A-j>',
  },
  insert_nav = {
    end_of_line = '<C-e>',
    beginning_of_line = '<C-a>',
    delete_by_word = '<C-w>',
    delete_by_line = '<C-u>',
    delete = '<C-d>',
    curly_brackets = '[c',
    save = '<C-s>',
  },
  command_nav = {
    backward = '<C-h>',
    end_of_line = '<C-e>',
    forward = '<C-l>',
    beginning_of_line = '<C-a>',
    delete = '<C-d>',
    expand_directory = '<C-t>',
  },
  visual_mode_mappings = {
    macros_on_selected_area = '@',
    search_on_selected_area = '//',
    line_move_up = '<A-k>',
    line_move_down = '<A-j>',
    replace_selection = '<leader>r',
    replace_selection_wc = '<leader>R',
  },
  window_nav = {
    moveLeft = '<C-h>',
    moveRight = '<C-l>',
    moveUp = '<C-k>',
    moveDown = '<C-j>',
  },
  terminal = {
    toggle_terminal = '<A-i>',
  },
  plugins = {
    bufferline = {
      next_buffer = '<leader><TAB>',
      prev_buffer = '<S-Tab>',
      move_buffer_next = ']b',
      move_buffer_prev = '[b',
      pick_buffer = 'gb',
      pick_close = 'gB',
    },
    comment = {
      toggle = '<leader>/',
    },
    dial = {
      increase = '<C-a>',
      decrease = '<C-x>',
    },
    toggle_character = {
      toggle_comma = '<localleader>,',
      toggle_semicolon = '<localleader>;',
    },
    session = {
      save_session = '<leader>ss',
      restore_session = '<leader>sl',
    },
    lspconfig = {
      declaration = 'gD',
      definition = 'gd',
      hover = 'K',
      implementation = 'gi',
      signature_help = 'gk',
      add_workspace_folder = '<leader>wa',
      remove_workspace_folder = '<leader>wr',
      list_workspace_folders = '<leader>wl',
      type_definition = '<leader>D',
      rename = '<leader>ra',
      code_action = '<leader>ca',
      references = 'gr',
      float_diagnostics = 'ge',
      goto_prev = '[d',
      goto_next = ']d',
      set_loclist = '<leader>q',
      formatting = '<leader>fm',
    },
    nvimtree = {
      toggle = '<C-n>',
      focus = '<leader>e',
    },
    telescope = {
      project_files = '<C-p>',
      builtins = '<leader>fa',
      current_buffer_fuzzy_find = '<leader>fb',
      dotfiles = '<leader>fd',
      dash_app_search = '<leader>fD',
      find_files = '<leader>ff',
      git_commits = '<leader>fgc',
      git_branches = '<leader>fgb',
      pull_requests = '<leader>fgp',
      man_pages = '<leader>fm',
      history = '<leader>fh',
      nvim_config = '<leader>fc',
      buffers = '<leader>fo',
      installed_plugins = '<leader>fp',
      orgfiles = '<leader>fO',
      norgfiles = '<leader>fN',
      module_reloader = '<leader>fR',
      resume_last_picker = '<leader>fr',
      grep_string = '<leader>fs',
      tmux_sessions = '<leader>fts',
      tmux_windows = '<leader>ftw',
      -- help_tags = '<leader>f?',
      lsp_workspace_diagnostics = '<leader>cd',
      lsp_document_symbols = '<leader>cs',
      lsp_dynamic_workspace_symbols = '<leader>cw',
    },
    harpoon = {
      add = '<localleader>a',
      toggle = '<localleader>f',
      next = '<localleader>n',
      prev = '<localleader>b',
    },
  },
}

return M

