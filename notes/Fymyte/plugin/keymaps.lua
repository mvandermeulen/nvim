local map = function(mode, lhs, rhs, opts)
  opts = opts or { noremap = true, silent = true }
  vim.keymap.set(mode, lhs, rhs, opts)
end

-------------------
-- Keymaps
-------------------

-- Quick save
map('n', '<leader>w', '<cmd>write!<cr>')
-- Undo breakpoints
map('i', ',', ',<C-g>u')
map('i', '.', '.<C-g>u')
map('i', '!', '!<C-g>u')
map('i', '?', '?<C-g>u')
map('i', ':', ':<C-g>u')
-- Move between windows
-- utils.map( { '', '<C-h>', '<cmd>wincmd h<cr>' })
-- utils.map( { '', '<C-j>', '<cmd>wincmd j<cr>' }) -- Leave J-K for completion
-- utils.map( { '', '<C-k>', '<cmd>wincmd k<cr>' })
-- utils.map( { '', '<C-l>', '<cmd>wincmd l<cr>' })
-- Cycle throught buffers
map('', '<C-b>p', '<cmd>bprev<cr>')
map('', '<C-b><C-p>', '<cmd>bprev<cr>')
map('', '<C-b>n', '<cmd>bnext<cr>')
map('', '<C-b><C-n>', '<cmd>bnext<cr>')
-- Move lines
map('n', '<M-j>', [[<cmd>m.+1<cr>==]])
map('n', '<M-k>', [[<cmd>m.-2<cr>==]])
map('i', '<M-j>', [[<esc><cmd>m.+1<cr>==]])
map('i', '<M-k>', [[<esc><cmd>m.-2<cr>==]])
-- Those two needs to use `:` instead of `<cmd>` because otherwise
-- range is not inserted before the command
map('v', '<M-j>', [[:m '>+1<cr>gv=gv]])
map('v', '<M-k>', [[:m '<-2<cr>gv=gv]])
map('v', '<', '<gv')
map('v', '>', '>gv')
-- Join line above at the end of the current line
map('n', '<leader>j', [[<cmd>m-2|j<cr>]])
-- Motions
map('n', '0', '^') -- use 0 to go to first char of line
-- map('n', '=', '+')
-- Term
map('t', '<Esc>', '<C-\\><C-n>')
-- Misc
map('', '<leader><Space>', '<cmd>noh<cr>')

local function showFugitiveGit()
  if vim.fn.FugitiveHead() ~= '' then
    vim.cmd [[
    Git
    wincmd H
    vertical resize 31
    setlocal nonumber
    setlocal norelativenumber
    setlocal winfixwidth
    ]]
  end
end
map('n', '<leader>gs', showFugitiveGit)
