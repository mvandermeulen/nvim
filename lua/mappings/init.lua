--[[
-- Key Mappings
--
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]


-----------------------------------------------
-- Helpers
-----------------------------------------------

expr_options = { noremap = true, expr = true, silent = true }

-- Function for make mapping easier.
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  -- vim.api.nvim_set_keymap(mode, lhs, rhs, options)
  vim.keymap.set(mode, lhs, rhs, options)
end

local function dfo(desc)
  if desc then
    return { noremap = true, silent = true, desc = desc }
  else
    return { noremap = true, silent = true }
  end
end

require("helpers.user.unimpaired")

-----------------------------------------------
-- Map Leader Key & Local Leader
-----------------------------------------------

map("n", "<Space>", "<NOP>", dfo()) -- map the leader key
vim.g.mapleader = " "

require("mappings.local")


-----------------------------------------------
-- Mappings: NORMAL mode
-----------------------------------------------

-------------------------------
-- Standard Keys
-------------------------------
map("n", ";", ":", dfo()) -- Remap semicolon for commands
map("n", ";;", ";", dfo()) -- Remap semicolon for commands
-- map("n", "0", "^", dfo()) -- use 0 to go to first char of line
map("n", "n", "nzz", dfo()) -- center search results
map("n", "N", "Nzz", dfo()) -- center search results
map("n", "k", "v:count == 0 ? 'gk' : 'k'", expr_options) -- Deal with visual line wraps
map("n", "j", "v:count == 0 ? 'gj' : 'j'", expr_options) -- Deal with visual line wraps
-- map("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>", dfo()) -- Cancel search highlighting with ESC
map("n", "m/", "<cmd>MarksListAll<CR>", dfo()) -- Marks from all opened buffers


-------------------------------
-- Arrow Keys
-------------------------------
map("n", "<Left>", ":vertical resize +1<CR>", dfo())
map("n", "<Right>", ":vertical resize -1<CR>", dfo())
map("n", "<Up>", ":resize -1<CR>", dfo())
map("n", "<Down>", ":resize +1<CR>", dfo())


-------------------------------
-- Function Keys
-------------------------------
map("n", "<F13>", ":NvimTreeToggle<cr>", dfo())
map("n", "<F14>", ":Twilight<CR>", dfo())
map("n", "<F16>", "<CMD>lua require('snacks').zen()<CR>", dfo())


-------------------------------
-- Leader Keys
-------------------------------

-- NOTE: These should be mapped in the which-key plugin configuration

-- Easier save/open/close
--keymap("n", "<Leader>w", ":w<CR>")                                      -- write with w
--keymap("n", "<Leader>q", ":q<CR>")                                      -- quit with q
--keymap("n", "<Leader>qq", ":q!<CR>")                                    -- space + qq to force quit
--map('n', '<leader>j', [[<cmd>m-2|j<cr>]])                                 -- Join line above at end of current
-- map("n", "<leader><leader>M", ":lua require'telegraph'.telegraph({how='tmux_popup', cmd='man '})<Left><Left><Left>", dfo(''))
-- Map <leader>mr in normal mode to the ranger_popup_in_tmux function
map("n", "<leader>mr", "<Cmd>lua require('helpers.user.shell').ranger_popup_in_tmux()<CR>", dfo('Ranger in Tmux'))
-- map("n", "<leader>mp", "<Cmd>lua require('helpers.precognition').toggle()<CR>", dfo('Toggle Precognition'))

map("n", "<leader>pj[", "<cmd>Portal jumplist backward<cr>", dfo('Portal Jumplist Backward'))
map("n", "<leader>pj]", "<cmd>Portal jumplist forward<cr>", dfo('Portal Jumplist Forward'))

-- map("n", "<leader>pj[", "<cmd>Portal jumplist backward<cr>", dfo('Portal Jumplist Backward'))
-- map("n", "<leader>pj]", "<cmd>Portal jumplist forward<cr>", dfo('Portal Jumplist Forward'))

map("n", "<leader><S-Tab>", ":BufferLineCyclePrev<CR>", dfo('Previous Buffer'))
map("n", "<leader><Tab>", ":BufferLineCycleNext<CR>", dfo('Next Buffer'))

-------------------------------
-- Keys w Modifiers
-------------------------------
-- map("n", "<TAB>", ":bnext<CR>", dfo(''))
-- map("n", "<S-TAB>", ":bprevious<CR>", dfo(''))


--------------------
-- Shift Modifier
--------------------
map("n", "<S-Right>", ":tabnext<CR>", dfo('Next Tab'))
map("n", "<S-Left>", ":tabprev<CR>", dfo('Previous Tab'))
map("n", "<S-Up>", ":BufferLineCyclePrev<CR>", dfo('Previous Buffer'))
map("n", "<S-Down>", ":BufferLineCycleNext<CR>", dfo('Next Buffer'))
map("n", "<S-L>", ":tabnext<CR>", dfo('Next Tab'))
map("n", "<S-H>", ":tabprev<CR>", dfo('Previous Tab'))
map("n", "<S-CR>w'", "<CMD>ReplaceInSingleQuotesWord<CR>", dfo('Wrap in Single Quotes'))
map("n", "<S-CR>W'", "<CMD>ReplaceInSingleQuotesNonWhitespaceWord<CR>", dfo('Wrap WORD in Single Quotes'))
map("n", "<S-CR>w\"", "<CMD>ReplaceInDoubleQuotesWord<CR>", dfo('Wrap in Double Quotes'))
map("n", "<S-CR>W\"", "<CMD>ReplaceInDoubleQuotesNonWhitespaceWord<CR>", dfo('Wrap WORD in Double Quotes'))
map("n", "<S-CR>w[", "<CMD>ReplaceInBracketsWord<CR>", dfo('Wrap in Brackets'))
map("n", "<S-CR>W[", "<CMD>ReplaceInBracketsNonWhitespaceWord<CR>", dfo('Wrap WORD in Brackets'))
map("n", "<S-CR>w(", "<CMD>ReplaceInParenthesesWord<CR>", dfo('Wrap word in Parentheses'))
map("n", "<S-CR>W(", "<CMD>ReplaceInParenthesesNonWhitespaceWord<CR>", dfo('Wrap WORD in Parentheses'))
map("n", "<S-CR>wm", "<CMD>MakeWordMarkdownLink<CR>", dfo('Markdown Link'))
map("n", "<S-CR>Wm", "<CMD>MakeNonWhitespaceWordMarkdownLink<CR>", dfo('Markdown Link from Non-Whitespace Word'))
-- <S-Space> is UNUSED
map("n", "<S-Space>", function() require('snacks').scratch() end, dfo('Scratchpad Toggle'))


--------------------
-- Meta Modifier
--------------------
map("n", "<M-j>", [[<cmd>m.+1<cr>==]], dfo())
map("n", "<M-k>", [[<cmd>m.-2<cr>==]], dfo())
map("i", "<M-j>", [[<esc><cmd>m.+1<cr>==]], dfo())
map("i", "<M-k>", [[<esc><cmd>m.-2<cr>==]], dfo())
map("n", "<M-S-Up>", ":resize -2<CR>", dfo())
map("n", "<M-S-Down>", ":resize +2<CR>", dfo())
map("n", "<M-S-Left>", ":vertical resize -2<CR>", dfo())
map("n", "<M-S-Right>", ":vertical resize +2<CR>", dfo())
-- <M-.> is Avante Ask
map({ "i", "x", "n", "s"}, "<M-.>", "<cmd>AvanteToggle<CR>", dfo('Avante: Toggle'))
-- <M-,> is UNUSED
-- map("n", "<M-CR>", "<CMD>:NvimTreeToggle<CR>", dfo())
map("n", "<M-,>", "<CMD>lua require('helpers.user.notes').record_was_doing()<CR>", dfo())
-- <M-CR> is Telescope Smart Open
vim.keymap.set("n", "<M-CR>", function ()
  require("telescope").extensions.smart_open.smart_open()
end, { noremap = true, silent = true, desc = 'Smart Open' })


--------------------
-- Ctrl Modifier
--------------------
-- map("n", "<C-e>", "2<C-e>")
-- map("n", "<C-y>", "2<C-y>")
-- map("n", "<C-U>", "<Esc>viwUi", dfo('')) -- Capitalize word on letter
map("n", "<C-s>", "<CMD>:update<cr><esc>", dfo('Save')) -- write with w
map("n", "<C-t>", "<CMD>lua require('telescope').extensions.tele_tabby.list()<CR>", dfo()) -- write with w
map("n", "<C-CR>", "<CMD>:NvimTreeToggle<CR>", dfo('Explorer'))
map("n", "<C-->", "<cmd>Cheatsheet<cr>", dfo('Cheatsheet'))
map("n", "<C-\\>", "<Plug>(comment_toggle_linewise_current)", dfo('Comment Line'))
map("n", "<C-Q>", "<cmd>:NvimTreeClose<cr><cmd>:qa<cr>", dfo('Quit All'))
map("n", "<C-Esc>", "<cmd>:YankBank<cr>", dfo('YankBank'))
-- <C-/> is used by FZF Document Symbols
-- map("n", "<C-/>", "", dfo())
-- FZF is using C-.
-- map("n", "<C-.>", "", dfo())
map({ "i", "x", "n", "s" }, "<C-;>", "<cmd>CopilotChatToggle<cr>", dfo('Copilot Chat: Toggle'))
-- <C-:> is UNUSED
-- map("n", "<C-:>", "", dfo())
-- <C-'> is used by FZF Workspace Symbols
-- map("n", "<C-'>", "", dfo()) -- write with w
-- <C-"> is Window Zoom
-- <C-[> is Copilot Chat Actions
-- <C-]> is FZF Buffers
-- map("n", "<C-_>",'<CMD>lua require("arrow.persist").toggle<CR>', dfo())
-- vim.api.nvim_set_keymap('n','<C-\\>',"<Plug>(comment_toggle_linewise_current)", dfo())
-- map("n", "<C-]>", "", dfo())



-- map("n", "<C-/>", "<Plug>(comment_toggle_linewise_current)", dfo(''))

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
--map("n", "*", "<cmd>lua require'starlite'.star()<CR>", dfo(''))
--map("n", "g*", "<cmd>lua require'starlite'.g_star()<CR>", dfo(''))
--map("n", "#", "<cmd>lua require'starlite'.hash()<CR>", dfo(''))
--map("n", "g#", "<cmd>lua require'starlite'.g_hash()<CR>", dfo(''))

-- TODO: Doesn't work
-- FIXED
-- map("n", "<C-,>", ":FzfLua files<CR>")
-- map("n", "<C-P>", ":FzfLua<CR>")

--map("n", "", "")

--map("n", "", "")
--map("n", "", "")

--map("n", "", "")
--map("n", "", "")

-----------------------------------------------
-- Mappings: VISUAL Mode
-----------------------------------------------

-- better indenting
map("v", "<", "<gv", dfo())
map("v", ">", ">gv", dfo())

map("v", "p", '"_dP', dfo()) -- paste over currently selected text without yanking it
--map("v", "p", '"_dP')                                                    -- Don't copy the replaced text after pasting.

-- Move selected line / block of text in visual mode
map("v", "K", ":move '<-2<CR>gv-gv", dfo())
map("v", "J", ":move '>+1<CR>gv-gv", dfo())


-- Map <leader>ex in visual mode to the function
vim.api.nvim_set_keymap(
  "x",
  "<leader>ex",
  [[:lua require('helpers.user.shell').execute_visual_selection()<CR>]],
  { noremap = true, silent = true }
)

-----------------------------------------------
-- Mappings: INSERT Mode
-----------------------------------------------

function EscapePair()
  local closers = { ")", "]", "}", ">", "'", '"', "`", "," }
  local line = vim.api.nvim_get_current_line()
  local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
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

-- map("i", "<C-L>", "<CMD>lua EscapePair()<CR>", dfo())
map("i", "<M-i>", "<CMD>lua require('helpers.utils.fs').insert_file_path()<CR>", dfo())

vim.api.nvim_set_keymap(
  "i",
  "<c-a>",
  "<C-o>:lua require('helpers.user.todos').insert_todo_and_comment()<CR>",
  { noremap = true, silent = true }
)

-- Create a keymap to call the add_project_from_line function
map(
  "i",
  "<C-x>",
  [[<Cmd>lua require('helpers.utils').add_project_from_line(vim.fn.getline('.'))<CR>]], -- Passes current line to the function
  dfo()
)

-- vim.api.nvim_set_keymap("i", "<C-CR>", 'copilot#Accept("<CR>")', { silent = true, expr = true })


-------------------------------
-- Keys w Modifiers
-------------------------------

map("i", "<C-U>", "<Esc>viwUi", dfo())


require("mappings.wk")
require("mappings.custom")
