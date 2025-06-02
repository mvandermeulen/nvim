--[[
-- UI Configuration
--
-- Author: Mark van der Meulen
-- Updated: 24-04-2022
--]]
vim.opt.tabpagemax = 25                             -- Only show up to 25 tabs
vim.opt.showtabline = 2                             -- always show tabs
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50" -- block in normal and beam cursor in insert mode
vim.opt.cursorline = true                           -- Highlight current line
vim.opt.ruler = true                                -- Enabling ruler and statusline.
vim.opt.showcmd = true                              -- Show partial commands in status line and
vim.opt.laststatus = 3                              -- When the last window will have a status line (2 always: 3 global statusline)
vim.opt.cmdheight = 1                               -- Space for displaying messages/commands
vim.opt.cmdwinheight = 2                            -- 
vim.opt.showmode = false                            -- We don't need to see things like -- INSERT -- anymore. using airline atm
vim.opt.lazyredraw = true                           -- do not redraw screen while running macros
vim.opt.synmaxcol = 240                             -- Max column for syntax highlight
vim.opt.textwidth = 120
vim.opt.joinspaces = false                          -- No double spaces with join
vim.opt.linebreak = true                            -- Stop words being broken on wrap
vim.opt.wrap = false                                -- Disable line wrap
vim.opt.backspace = {"indent", "eol", "start"}      -- Without this option some times backspace did not work correctly.
vim.opt.scrolloff = 3                               -- Minimal number of screen lines to keep above and below the cursor
vim.opt.sidescrolloff = 5                           -- The minimal number of columns to scroll horizontally
vim.opt.pumheight = 25                              -- pop up menu height
vim.opt.conceallevel = 0                            -- so that `` is visible in markdown files

-- Line Numbers
vim.opt.number = true                               -- Show line numbers
vim.opt.relativenumber = true                       -- Relative line numbers
vim.opt.numberwidth = 4                             -- Make the gutter wider by default

-- Folding
vim.o.foldcolumn = '1' -- '0' is not bad
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
--vim.opt.foldmethod = 'indent'
vim.opt.foldmethod = "expr"
--vim.opt.foldmethod = 'marker'                     -- Enable folding (default 'foldmarker')
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldminlines = 2
vim.opt.foldnestmax = 10
vim.opt.foldenable = true                          -- disable folding; enable with zi
vim.opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

-- Window Splits
vim.opt.splitbelow = true                           -- force all horizontal splits to go below current window
vim.opt.splitright = true                           -- force all vertical splits to go to the right of current window

--vim.opt.colorcolumn = '80'      -- Line lenght marker at 80 columns
-- Setting colorcolumn. This is set because of
--vim.opt.colorcolumn = "+1"
-- this (https://github.com/lukas-reineke/indent-blankline.nvim/issues/59)
-- indent-blankline bug.
vim.opt.colorcolumn = "9999"
--vim.opt.colorcolumn = "99999"

-- Sign Column
--vim.opt.signcolumn = 'yes'
vim.opt.signcolumn = "yes:3"                       -- Set signcolumn width to 2

-- Invisible Characters
vim.opt.list = true                                 -- Show some invisible characters
--vim.opt.listchars = "eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣"
vim.opt.listchars = { tab = ">>>", trail = "·", precedes = "←", extends = "→",eol = "↲", nbsp = "␣" }

-- Completion
vim.opt.completeopt = {"menu", "menuone", "noselect", "noinsert"} -- A comma separated list of options for Insert mode completion

-- Wild Menu
--vim.opt.wildignore='*.swp,*.bak,*.pyc,*.class'
vim.opt.wildmenu = true                             -- Show list instead of just completing
--vim.opt.wildmode = {'list', 'longest'}              -- Command-line completion mode
vim.opt.wildmode = "full"
vim.opt.wildignorecase = true                       -- When set case is ignored when completing file names and directories
vim.opt.wildignore = [[
.git,.hg,.svn
*.aux,*.out,*.toc
*.o,*.obj,*.exe,*.dll,*.manifest,*.rbc,*.class
*.ai,*.bmp,*.gif,*.ico,*.jpg,*.jpeg,*.png,*.psd,*.webp
*.avi,*.divx,*.mp4,*.webm,*.mov,*.m2ts,*.mkv,*.vob,*.mpg,*.mpeg
*.mp3,*.oga,*.ogg,*.wav,*.flac
*.eot,*.otf,*.ttf,*.woff
*.doc,*.pdf,*.cbr,*.cbz
*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz,*.kgb
*.swp,.lock,.DS_Store,._*
*/tmp/*,*.so,*.swp,*.zip,**/node_modules/**,**/target/**,**.terraform/**"
]]

