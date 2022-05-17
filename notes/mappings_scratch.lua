local keymap = function(mode, key, result)
  vim.api.nvim_set_keymap(mode, key, result, { noremap = true, silent = true })
end

--local tmapper

vim.g.mapleader = ' '

keymap('n', 'tt', ':t.<CR>') -- tt to copy line and paste under
keymap('n', '<Leader>vs', ':vsp<CR>') -- space + vs to open vertical split
keymap('n', '<Leader>vt', ':vsp | terminal<CR>') -- space + vt to open terminal on vertical split
keymap('n', '<Leader>sp', ':sp | terminal<CR>') -- space + sp to open terminal on split
keymap('t', '<Esc>', '<C-\\><C-n>') -- scape to exit edit mode on terminal
keymap('n', '<Leader>sr', ':source %<CR>') -- space + sr to source %
keymap('n', '<Leader>bd', ':Bdelete!<CR>')

-- Navigate buffers
keymap('n', '<S-l>', ':bnext<CR>')
keymap('n', '<S-h>', ':bprevious<CR>')

-- Move text up and down
keymap('n', '<A-j>', '<Esc>:m .+1<CR>')
keymap('n', '<A-k>', '<Esc>:m .-2<CR>')

-- TELESCOPE
keymap('n', '<Leader>ff', '<cmd>Telescope find_files<CR>') -- Find files using Telescope command-line sugar.
keymap('n', '<Leader>fg', '<cmd>Telescope live_grep<CR>') -- Live grep on filesystem
keymap('n', '<Leader>fb', '<cmd>Telescope buffers<CR>') -- More about this later
keymap('n', '<Leader>fh', '<cmd>Telescope help_tags<CR>') -- Help tags

-- TELESCOPE FILE EXPLORER
keymap('n', '<Leader>fd', '<cmd>Telescope file_browser<CR>') -- Open file explorer

-- LSP
keymap('n', '<Silent>gd', '<cmd>lua vim.lsp.buf.definition()<CR>') -- Go to definition
keymap('n', '<Silent>gD', '<cmd>lua vim.lsp.buf.declaration()<CR>') -- Go to declaration
keymap('n', '<Silent>gr', '<cmd>lua vim.lsp.buf.references()<CR>')
keymap('n', '<Silent>K', '<cmd>lua vim.lsp.buf.hover()<CR>')
keymap('n', '<Leader>fc', '<cmd>lua vim.lsp.buf.formatting()<CR>')

-- nvim -tree
keymap('n', '<C-n>', ':NvimTreeToggle<CR>')
keymap('n', '<Leader>r', ':NvimTreeRefresh<CR>')
keymap('n', '<Laeder>n', ':NvimTreeFindFile<CR>')

-- Split Movement
utils.map('n', '<C-h>', '<C-w>h')
utils.map('n', '<C-j>', '<C-w>j')
utils.map('n', '<C-k>', '<C-w>k')
utils.map('n', '<C-l>', '<C-w>l')

-- Easier Splits
utils.map('n', '<Leader>v', ':vsplit<CR>', opts)
utils.map('n', '<Leader>h', ':split<CR>', opts)

-- Custom
keymap('n', '<esc><esc>', '<cmd>nohlsearch<cr>', opts)
-- NOTE: the fact that tab and ctrl-i are the same is stupid
-- keymap("n", "<TAB>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
keymap('n', 'Q', '<cmd>Bdelete!<CR>', opts)
keymap('n', '<F1>', ':e ~/Notes/<cr>', opts)
keymap('n', '<F3>', ':e .<cr>', opts)
keymap('n', '<F4>', '<cmd>Telescope resume<cr>', opts)
keymap('n', '<F5>', '<cmd>Telescope commands<CR>', opts)
keymap(
  'n',
  '<F6>',
  [[:echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">" . " FG:" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"fg#")<CR>]],
  opts
)
keymap('n', '<F7>', '<cmd>TSHighlightCapturesUnderCursor<cr>', opts)
keymap('n', '<F8>', '<cmd>TSPlaygroundToggle<cr>', opts)
keymap('n', '<F11>', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
keymap('n', '<F12>', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
keymap('v', '//', [[y/\V<C-R>=escape(@",'/\')<CR><CR>]], opts)
keymap(
  'n',
  '<C-p>',
  "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>",
  opts
)
keymap('n', '<C-t>', '<cmd>lua vim.lsp.buf.document_symbol()<cr>', opts)
keymap('n', '<C-s>', '<cmd>vsplit<cr>', opts)
keymap('n', '<C-z>', '<cmd>ZenMode<cr>', opts)
keymap('n', '<c-n>', ':e ~/Notes/<cr>', opts)

keymap('n', '-', ":lua require'lir.float'.toggle()<cr>", opts)
-- keymap("n", "<C-\\>", "<cmd>vsplit<cr>", opts)
-- vim.cmd[[nnoremap c* /\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgn]]
-- vim.cmd[[nnoremap c# ?\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgN]]
-- keymap("n", "c*", [[/\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgn]], opts)
-- keymap("n", "c#", [[?\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgN]], opts)
-- keymap("n", "gx", [[:execute '!brave ' . shellescape(expand('<cfile>'), 1)<CR>]], opts)
keymap('n', 'gx', [[:silent execute '!$BROWSER ' . shellescape(expand('<cfile>'), 1)<CR>]], opts)
-- Change '<CR>' to whatever shortcut you like :)
vim.api.nvim_set_keymap('n', '<CR>', '<cmd>NeoZoomToggle<CR>', { noremap = true, silent = true, nowait = true })
vim.api.nvim_set_keymap('n', '=', '<cmd>JABSOpen<cr>', { noremap = true, silent = true, nowait = true })

local map_tele = function(mode, key, f, options, buffer)
  local rhs = function()
    if not pcall(require, 'telescope.nvim') then
      require('packer').loader 'plenary.nvim'
      require('packer').loader 'popup.nvim'
      require('packer').loader 'telescope-fzy-native.nvim'
      require('packer').loader 'telescope.nvim'
    end
    require('plugins.telescope')[f](options or {})
  end

  local map_options = {
    noremap = true,
    silent = true,
    buffer = buffer,
  }

  require('utils').remap(mode, key, rhs, map_options)
end

-- mappings
map_tele('n', '<leader><F1>', 'help_tags')
map_tele('n', '<leader>,', 'buffers')
map_tele('n', '<leader>zf', 'find_files')
map_tele('n', '<leader>zg', 'git_files')
map_tele('n', '<leader>zb', 'current_buffer_fuzzy_find')
map_tele('n', '<leader>zh', 'oldfiles', { cwd = '~' })
map_tele('n', '<leader>zH', 'oldfiles', { cwd = vim.loop.cwd(), cwd_only = true })
map_tele('n', '<leader>zx', 'commands')
map_tele('n', '<leader>z:', 'command_history')
map_tele('n', '<leader>z/', 'search_history')
map_tele('n', '<leader>zm', 'marks')
map_tele('n', '<leader>zM', 'man_pages')
map_tele('n', '<leader>zq', 'quickfix')
map_tele('n', '<leader>zQ', 'loclist')
map_tele('n', '<leader>z"', 'registers')
map_tele('n', '<leader>zo', 'vim_options')
-- map_tele('n', '<leader>zo', "colorscheme")
map_tele('n', '<leader>zO', 'highlights')
map_tele('n', '<leader>zk', 'keymaps')
map_tele('n', '<leader>zz', 'resume')
map_tele('n', '<leader>zt', 'current_buffer_tags')
map_tele('n', '<leader>zT', 'tags')
map_tele('n', '<leader>zR', 'live_grep')

map_tele('n', '<leader>zw', 'grep_cword')
map_tele('n', '<leader>zW', 'grep_cWORD')
map_tele('n', '<leader>zr', 'grep_prompt')
map_tele('n', '<leader>zv', 'grep_visual')
map_tele('v', '<leader>zv', 'grep_visual')

-- Telescope Meta
map_tele('n', '<leader>z?', 'builtin')

-- Git
map_tele('n', '<leader>zB', 'git_branches')
map_tele('n', '<leader>zs', 'git_status')
map_tele('n', '<leader>zc', 'git_bcommits')
map_tele('n', '<leader>zC', 'git_commits')

-- LSP
map_tele('n', '<leader>zlr', 'lsp_references')
map_tele('n', '<leader>zla', 'lsp_code_actions')
map_tele('n', '<leader>zlA', 'lsp_range_code_actions')
map_tele('n', '<leader>zld', 'lsp_definitions')
map_tele('n', '<leader>zlm', 'lsp_implementations')
map_tele('n', '<leader>zlg', 'diagnostics', { bufnr = 0 })
map_tele('n', '<leader>zlG', 'diagnostics')
map_tele('n', '<leader>zls', 'lsp_document_symbols')
map_tele('n', '<leader>zlS', 'lsp_workspace_symbols')

-- Nvim & Dots
map_tele('n', '<leader>zen', 'edit_neovim')
map_tele('n', '<leader>zed', 'edit_dotfiles')
map_tele('n', '<leader>zez', 'edit_zsh')
map_tele('n', '<leader>zep', 'installed_plugins')
