--[[
-- Terminal Configuration
--
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]

local map = vim.api.nvim_set_keymap
local buf_map = vim.api.nvim_buf_set_keymap

local status_ok, toggleterm = pcall(require, 'toggleterm')
if not status_ok then
  return
end


toggleterm.setup {
  -- size can be a number or function which is passed the current terminal
  size = function(term)
    if term.direction == 'horizontal' then
      return 15
    elseif term.direction == 'vertical' then
      return vim.o.columns * 0.4
    elseif term.direction == 'float' then
      return 20
    end
  end,
  open_mapping = [[<C-n>]],
  hide_numbers = true, -- hide the number column in toggleterm buffers
  shade_filetypes = {},
  shade_terminals = true,
  shading_factor = '1', -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
  start_in_insert = true,
  insert_mappings = true, -- whether or not the open mapping applies in insert mode
  persist_size = true,
  direction = 'float', -- 'vertical' | 'horizontal' | 'window' | 'float',
  close_on_exit = true, -- close the terminal window when the process exits
  shell = vim.o.shell, -- change the default shell
  -- This field is only relevant if direction is set to 'float'
  float_opts = {
    -- The border key is *almost* the same as 'nvim_win_open'
    -- see :h nvim_win_open for details on borders however
    -- the 'curved' border is a custom border type
    -- not natively supported but implemented in this plugin.
    border = 'curved', -- 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
    -- width = <value>,
    -- height = <value>,
    winblend = 0,
    highlights = {
      border = 'Normal',
      background = 'Normal',
    },
  },
}

map('n', '<leader>atn', '<cmd>lua _NODE_TOGGLE()<CR>', { noremap = true, silent = true, desc = 'Node' }) -- start node
map('n', '<leader>atp', '<cmd>lua _PYTHON_TOGGLE()<CR>', { noremap = true, silent = true, desc = 'Python' }) -- start python
map('n', '<leader>ath', '<cmd>lua _HTOP_TOGGLE()<CR>', { noremap = true, silent = true, desc = 'Htop' }) -- start htop
map('n', '<leader>atu', '<cmd>lua _NCDU_TOGGLE()<CR>', { noremap = true, silent = true, desc = 'NCDU' }) -- start ncdu
map('n', '<leader>atg', '<cmd>lua _GITUI_TOGGLE()<CR>i', { noremap = true, silent = true, desc = 'GitUI' }) -- start gitui
map('n', '<leader>atl', '<cmd>lua _LAZYGIT_TOGGLE()<CR>i', { noremap = true, silent = true, desc = 'Lazygit' }) -- start lazygit
-- map('t', '<ESC>', '<C-\\><C-n>', { noremap = true, silent = true }) -- back to normal mode in Terminal

-- :ToggleTermSendCurrentLine



-- Better navigation to and from terminal
function _G.set_terminal_keymaps()
  local opts = { noremap = true }
  -- vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-c>]], opts)
  -- vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[q]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd 'autocmd! TermOpen term://* lua set_terminal_keymaps()'

local Terminal = require('toggleterm.terminal').Terminal
local gitui = Terminal:new { cmd = 'gitui', direction = 'float', hidden = true }
local lazygit = Terminal:new { cmd = 'lazygit', direction = 'float', hidden = true }
local node = Terminal:new { cmd = 'node', hidden = true }
local ncdu = Terminal:new { cmd = 'ncdu', hidden = true }
local htop = Terminal:new { cmd = 'htop', hidden = true }
local python = Terminal:new { cmd = 'python3', hidden = true }

function _GITUI_TOGGLE()
  gitui:toggle()
end

function _LAZYGIT_TOGGLE()
  lazygit:toggle()
end

function _NODE_TOGGLE()
  node:toggle()
end

function _NCDU_TOGGLE()
  ncdu:toggle()
end

function _HTOP_TOGGLE()
  htop:toggle()
end

function _PYTHON_TOGGLE()
  python:toggle()
end
