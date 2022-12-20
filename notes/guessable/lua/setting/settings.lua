-- nvim options
vim.opt.background = "dark"
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autochdir = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.wrap = true
vim.opt.autoread = true
vim.opt.ruler = true
vim.opt.autoindent = true
vim.opt.hidden = true
vim.opt.smarttab = true
vim.opt.confirm = true
vim.opt.ignorecase = true
vim.opt.laststatus = 2
vim.opt.scrolloff = 7
vim.opt.mouse = "a"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- autocmd
vim.cmd [[autocmd FileType python,cpp,h,hpp, setlocal cc=80]]
vim.cmd [[autocmd BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\   exe "normal g`\"" |
\ endif]]
vim.cmd [[autocmd BufWritePre * :%s/\s\+$//e]]
vim.cmd [[autocmd BufWritePre * :%s/^$\n\+\%$//ge]]

-- snip
vim.g.vsnip_snippet_dir = "$HOME/.config/nvim/snippets"
vim.cmd [[imap <expr> <C-j> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<C-j>']]
vim.cmd [[imap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>']]

-- visual-multi
vim.cmd("let g:VM_maps = {}")
vim.cmd("let g:VM_maps['Find Under'] = '<C-d>'")
vim.cmd("let g:VM_maps['Find Subword Under'] = '<C-d>'")

-- vimtex
vim.g.vimtex_view_general_viewer = "zathura"
vim.g.vimtex_quickfix_mode = 0

--- vim-utility ---
-------------------
-- makefile for LaTeX
vim.g.makefile_path = "~/.local/share/nvim/site/pack/packer/start/vim-utility/Makefile"

-- undotree
vim.o.undodir = "/home/tau/.undodir"
vim.o.undofile = true
vim.g.undotree_WindowLayout = 3

-- highlightedyank
vim.g.highlightedyank_highlight_duration = 150

-- accelerated
vim.cmd("nmap j <Plug>(accelerated_jk_gj)")
vim.cmd("nmap k <Plug>(accelerated_jk_gk)")
