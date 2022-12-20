local o = vim.o -- For the globals options

o.incsearch = true
o.hlsearch = true
o.showmatch = true
vim.cmd([[ set ignorecase ]])
vim.cmd([[ set smartcase ]])
vim.cmd([[ nnoremap <esc> :noh<return><esc> ]])
