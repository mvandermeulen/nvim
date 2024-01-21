local execute = vim.api.nvim_command
local fn = vim.fn

vim.fn.setenv('MACOSX_DEPLOYMENT_TARGET', '10.15')

local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

-- returns the require for use in `config` parameter of packer's use
-- expects the name of the config file
local function gc(name)
  return string.format('require("plugins.%s")', name)
end

-- bootstrap packer if not installed
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    'git',
    'clone',
    'https://github.com/wbthomason/packer.nvim',
    install_path,
  }
  execute 'packadd packer.nvim'
  --print "Installing packer close and reopen Neovim..."
end

-- initialize and configure packer
local status_ok, packer = pcall(require, 'packer') -- Use a protected call so we don't error out on first use

if not status_ok then
  return
end

packer.init {
  display = {
    open_fn = function()
      return require('packer.util').float { border = 'rounded' }
    end,
  },
  compile_path = vim.fn.stdpath 'config' .. '/plugin/packer_compiled.lua',
  enable = true, -- enable profiling via :PackerCompile profile=true
  threshold = 0, -- the amount in ms that a plugins load time must be over for it to be included in the profile
  ensure_dependencies = true,
  luarocks = {
    python_cmd = '/opt/homebrew/bin/python3',
  },
  log = { level = 'warn' },
  max_jobs = 10,
}

local use = packer.use
packer.reset()

-- Function to make using plugins easier. Expects opts to be a dictionary if provided.
local function puse(repo, cfg, opts)
  if cfg then
    if opts then
      use { repo, requires = opts, config = gc(cfg) }
    else
      use { repo, config = gc(cfg) }
    end
  else
    if opts then
      use { repo, requires = opts }
    else
      use { repo }
    end
  end
end

-- Function to make using with plenary easier. Expects opts to be a dictionary if provided.
local function pluse(repo, cfg, opts)
  local depends = { { 'nvim-lua/plenary.nvim' } }
  if opts then
    while #opts > 0 do
      local item = table.remove(opts)
      table.insert(depends, item)
    end
  end
  if cfg then
    use { repo, requires = depends, config = gc(cfg) }
  else
    use { repo, requires = depends }
  end
end

return packer.startup(function()
  -----------------------------------------------
  -- Required
  -----------------------------------------------
  use { 'wbthomason/packer.nvim', opt = true }
  use 'lewis6991/impatient.nvim'
  use {
    'norcalli/nvim-terminal.lua',
    config = function()
      require('terminal').setup()
    end,
  } -- for displaying terminal colors in the pane_contents previewer with telescope-tmux
  use { 'tami5/sqlite.lua' }

  -----------------------------------------------
  -- FZF
  -----------------------------------------------
  pluse('ibhagwan/fzf-lua', 'fzf-lua', { { 'kyazdani42/nvim-web-devicons' } }) -- Start page

  -----------------------------------------------
  -- Telescope
  -----------------------------------------------
  local telescope_depends = {
    { 'nvim-lua/popup.nvim' },
    { 'nvim-lua/plenary.nvim' },
    { 'crispgm/telescope-heading.nvim' },
    { 'nvim-telescope/telescope-symbols.nvim' },
    { 'nvim-telescope/telescope-file-browser.nvim' },
    { 'nvim-telescope/telescope-project.nvim' },
    { 'nvim-telescope/telescope-github.nvim' },
    { 'nvim-telescope/telescope-packer.nvim' },
    { 'nvim-telescope/telescope-node-modules.nvim' },
    { 'nvim-telescope/telescope-live-grep-raw.nvim' },
    { 'KaiSpencer/telescope-tmuxp.nvim' },
    { 'tom-anders/telescope-vim-bookmarks.nvim' },
    { 'TC72/telescope-tele-tabby.nvim' },
    { 'camgraff/telescope-tmux.nvim' },
    { 'nvim-telescope/telescope-frecency.nvim' },
    { 'cljoly/telescope-repo.nvim' },
    { 'nvim-telescope/telescope-z.nvim' },
    { 'LinArcX/telescope-changes.nvim' },
    { 'LinArcX/telescope-ports.nvim' },
    { 'neanias/telescope-lines.nvim' },
    { 'nyarthan/telescope-code-actions.nvim' },
    -- { 'da-moon/telescope-toggleterm.nvim' },
  }
  use { 'nvim-telescope/telescope.nvim', requires = telescope_depends, config = gc 'telescope' }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  puse('sudormrfbin/cheatsheet.nvim', 'cheatsheet')
  --use({ "", config = gc("") })

  -----------------------------------------------
  -- Treesitter
  -----------------------------------------------
  local treesitter_depends = {
    { 'nvim-treesitter/nvim-treesitter-textobjects' },
    { 'p00f/nvim-ts-rainbow' },
    { 'eckon/treesitter-current-functions' },
  }
  use {
    'nvim-treesitter/nvim-treesitter',
    requires = treesitter_depends,
    config = gc 'treesitter',
    run = ':TSUpdate',
  }
  use { 'romgrk/nvim-treesitter-context', config = gc 'treesitter-context' }
  use { 'JoosepAlviste/nvim-ts-context-commentstring' }

  -----------------------------------------------
  -- Completion
  -----------------------------------------------
  use { 'windwp/nvim-autopairs', config = gc 'autopairs' } -- Pair completion ie. parentheses
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-buffer' }, -- buffer completions
      { 'hrsh7th/cmp-path' }, -- path completions
      { 'hrsh7th/cmp-cmdline' }, -- cmdline completions
      { 'hrsh7th/cmp-calc' },
      { 'hrsh7th/cmp-nvim-lua' },
      --{ "lukas-reineke/cmp-rg" },
    },
    config = gc 'cmp',
  }
  --------------------
  -- AI
  --------------------
  use {
    'jackMort/ChatGPT.nvim',
    requires = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim'
    },
    config = gc 'chatgpt',
  }
  use { 'jpmcb/nvim-llama', config = gc 'nvim-llama' }

  --------------------
  -- Snippets
  --------------------
  use { 'rafamadriz/friendly-snippets' }
  use { 'L3MON4D3/LuaSnip', requires = 'saadparwaiz1/cmp_luasnip', config = gc 'luasnip' }

  -----------------------------------------------
  -- LSP Configuration
  -----------------------------------------------
  use { 'SmiteshP/nvim-navic', requires = 'neovim/nvim-lspconfig' }
  use {
    'williamboman/mason.nvim',
    requires = {
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason-lspconfig.nvim'},
      {'jose-elias-alvarez/null-ls.nvim'},
      {'jay-babu/mason-null-ls.nvim'},
      {'WhoIsSethDaniel/mason-tool-installer.nvim'},
    },
    config = gc 'mason',
  }
  use { 'ray-x/lsp_signature.nvim', requires = { 'neovim/nvim-lspconfig' }, config = gc 'lsp-signature' }
  use { 'onsails/lspkind-nvim', requires = { 'famiu/bufdelete.nvim' } }
  pluse('jose-elias-alvarez/null-ls.nvim', 'null-ls') -- for formatters and linters
  use { 'rmagatti/goto-preview', config = gc 'goto-preview' }
  use { 'simrat39/symbols-outline.nvim', cmd = { 'SymbolsOutline' }, config = gc 'symbols' }
  --------------------
  -- Language Specific
  --------------------
  use { 'cuducos/yaml.nvim', ft = { 'yaml' } }
  puse('ray-x/go.nvim', 'go')
  use { 'ray-x/web-tools.nvim', config = gc 'webtools' }

  -----------------------------------------------
  -- File Management
  -----------------------------------------------
  use { 'kyazdani42/nvim-tree.lua', config = gc 'nvim-tree' }
  use { 'jghauser/mkdir.nvim' } -- Makes directories on save if required. Not Lua
  puse('nathom/filetype.nvim', 'filetype') -- Lua filtype.vim is much faster
  pluse('jiaoshijie/undotree', 'undotree')

  --------------------
  -- Git
  --------------------
  local diff_plugin_cmds = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' }
  use { 'sindrets/diffview.nvim', cmd = diff_plugin_cmds, config = gc 'diffview' } -- Diff plugin (requirement for Neogit)
  pluse('tanvirtin/vgit.nvim', 'vgit')
  use { 'TimUntersberger/neogit', requires = { 'nvim-lua/plenary.nvim' }, cmd = 'Neogit', config = gc 'neogit' }
  pluse('lewis6991/gitsigns.nvim', 'gitsigns')

  --------------------
  -- Managing Projects
  --------------------
  pluse('ThePrimeagen/harpoon', 'harpoon')
  use { 'ahmedkhalf/project.nvim', config = gc 'project' }
  use { 'natecraddock/sessions.nvim', config = gc 'sessions' }
  use { 'natecraddock/workspaces.nvim', config = gc 'workspaces' }
  use { 'folke/persistence.nvim', event = 'BufReadPre', module = 'persistence', config = gc 'persistence' }

  -----------------------------------------------
  -- Windows & Buffers
  -----------------------------------------------
  use { 'https://gitlab.com/yorickpeterse/nvim-window.git', config = gc 'nvim-window' }
  use { 'numToStr/Navigator.nvim', config = gc 'navigator' } -- Smoothly navigate between neovim splits and tmux panes
  use {
    'luukvbaal/stabilize.nvim',
    config = function()
      require('stabilize').setup()
    end,
  } -- Better handling of window open/close events

  --------------------
  -- Buffer Management
  --------------------
  use {
    'akinsho/bufferline.nvim',
    tag = 'v2.*',
    requires = 'kyazdani42/nvim-web-devicons',
    event = 'BufReadPre',
    config = gc 'bufferline',
  }
  use 'famiu/bufdelete.nvim'

  -----------------------------------------------
  -- Navigation
  -----------------------------------------------
  use { 'ggandor/lightspeed.nvim', event = 'BufReadPre' }
  --------------------
  -- Bookmarks
  --------------------
  puse('chentoast/marks.nvim', 'marks')
  --------------------
  -- Mappings
  --------------------
  use { 'folke/which-key.nvim', config = gc 'which' }


  -----------------------------------------------
  -- Terminal & Commands/Tasks
  -----------------------------------------------
  use { 'akinsho/nvim-toggleterm.lua', config = gc 'toggleterm' }
  use { 'numToStr/FTerm.nvim', config = gc 'fterm' }
  use { 'waylonwalker/Telegraph.nvim' }
  use {
    'tknightz/telescope-termfinder.nvim',
    config = function()
      require('telescope').load_extension("termfinder")
    end,
  } -- for displaying terminal colors in the pane_contents previewer with telescope-tmux
	use { 'jedrzejboczar/toggletasks.nvim', requires = { 'nvim-lua/plenary.nvim', 'akinsho/toggleterm.nvim', 'nvim-telescope/telescope.nvim' }, config = gc('toggletasks') }

  -----------------------------------------------
  -- Clipboard
  -----------------------------------------------
  use { 'tversteeg/registers.nvim' } -- Show register content in popup
  local neoclip_depends = { { 'tami5/sqlite.lua', module = 'sqlite' }, { 'nvim-telescope/telescope.nvim' } }
  use { 'AckslD/nvim-neoclip.lua', requires = neoclip_depends, config = gc 'neoclip' } -- Clipboard manager for neovim with persistent history between sessions powered by sqlite.lua


  -----------------------------------------------
  -- UI Plugins
  -----------------------------------------------
  puse('rcarriga/nvim-notify', 'notify')
  use { 'MunifTanjim/nui.nvim' }
  use {
    'nvim-lualine/lualine.nvim',
    config = gc 'lualine',
    event = 'VimEnter',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
  } -- Status Line
  use { 'norcalli/nvim-colorizer.lua', event = 'BufReadPre', config = gc 'colorizer' } -- A high-performance color highlighter
  use { 'folke/zen-mode.nvim', cmd = 'ZenMode', config = gc 'zen-mode' } -- opens the current buffer in a new full-screen floating window, disables plugins, etc
  use { 'folke/twilight.nvim', config = gc 'twilight' } -- dims inactive portions of the code you're editing using TreeSitter
  use { 'lukas-reineke/indent-blankline.nvim', event = 'BufReadPre', config = gc 'indent-blankline' } -- line intentation markers
  use { 'LudoPinelli/comment-box.nvim', config = gc 'comment-box' } -- Create boxes and lines in comments
  pluse('goolord/alpha-nvim', 'alpha-nvim', { { 'kyazdani42/nvim-web-devicons' } }) -- Start page
  use { 'kevinhwang91/nvim-bqf', requires = { { 'junegunn/fzf', module = 'nvim-bqf' } } } -- Quickfix
  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    cmd = { 'TroubleToggle', 'Trouble' },
    config = gc 'trouble',
  } -- Show troubleshooting window with relevant lists
  use { 'gennaro-tedesco/nvim-jqx' } -- Work with JSON in the quickfix window
  --------------------
  -- Highlighting
  --------------------
  use { 'RRethy/vim-illuminate', event = 'CursorHold' }
  use { 'ironhouzi/starlite-nvim' }
  use {
    'folke/todo-comments.nvim',
    requires = 'nvim-lua/plenary.nvim',
    cmd = { 'TodoTrouble', 'TodoTelescope' },
    event = 'BufReadPost',
    config = gc 'todo',
  } -- Searching/highlighting of comments such as TODO, HACK, BUG
  use { 'rhysd/conflict-marker.vim' } -- Highlight, jump and resolve conflict markers quickly. ie. Diff conflicts
  --------------------
  -- Colorschemes
  --------------------
  if _G.my.ui.theme ~= nil then
    if _G.my.ui.theme == "rose-pine" then
      use({ 'rose-pine/neovim', as = 'rose-pine', tag = 'v1.*', config = gc 'rpine' })
    end
  else
    if _G.my.plugins.themes ~= nil then
      for _, item in pairs(_G.my.plugins.themes.standard_install) do
        use { item }
      end
      for _, item in pairs(_G.my.plugins.themes.extended_install) do
        use { item }
      end
    else
      use { 'rktjmp/lush.nvim' }
      use { 'EdenEast/nightfox.nvim', config = gc 'nightfox' }
      use { 'folke/tokyonight.nvim' }
      use { 'rebelot/kanagawa.nvim' }
      use { 'marko-cerovac/material.nvim' }
      use { 'eddyekofo94/gruvbox-flat.nvim' }
      use { 'shaunsingh/nord.nvim' }
      use { 'navarasu/onedark.nvim' }
      use { 'olimorris/onedarkpro.nvim' }
      use { 'savq/melange' }
      use { 'rmehri01/onenord.nvim' }
      use { 'Yagua/nebulous.nvim' }
      use { 'andersevenrud/nordic.nvim' }
      use { 'kvrohit/substrata.nvim' }
      use { 'Domeee/mosel.nvim' }
      use { 'teloe/drip.nvim' }
      use { 'sainnhe/gruvbox-material' }
      use { 'Mofiqul/dracula.nvim' }
      use { 'shaeinst/roshnivim-cs' }
      use { 'rafamadriz/neon' }
      use { 'clpi/cyu.lua' }
      use { 'glepnir/zephyr-nvim' }
      use { 'sam4llis/nvim-tundra' }
      use { 'lmburns/kimbox' }
      use { 'lvim-tech/lvim-colorscheme' }
      use { 'mcchrish/zenbones.nvim' }
      use { 'Mofiqul/vscode.nvim' }
      use { 'decaycs/decay.nvim', as = 'decay' }
      use { 'yashguptaz/calvera-dark.nvim' }
      use { 'ishan9299/nvim-solarized-lua' }
      use { 'NTBBloodbath/doom-one.nvim' }
      use { 'shaunsingh/solarized.nvim' }
      use { 'Mofiqul/adwaita.nvim' }
      use { 'metalelf0/jellybeans-nvim' }
      use { 'Murtaza-Udaipurwala/gruvqueen' }
      use { 'daschw/leaf.nvim' }
      use { 'daltonmenezes/aura-theme', rtp = 'packages/neovim' }
      use { 'AlexvZyl/nordic.nvim', as = 'alexvzyl-nordic' }
    end
  end



  -----------------------------------------------
  -- Integrations
  -----------------------------------------------
  pluse('NTBBloodbath/rest.nvim', 'http-rest')

  -----------------------------------------------
  -- General Plugins
  -----------------------------------------------
  use { 'echasnovski/mini.nvim', branch = 'stable', config = gc 'mini' } -- Swiss army knife generic plugin.
  use { 'nacro90/numb.nvim', config = gc 'numb' } -- Peek line contents
  use { 'numToStr/Comment.nvim', config = gc 'comment' } -- Commenting
  --[[ use { 'jiaoshijie/undotree', config = gc 'undotree' } -- Peek line contents ]]

  --use({ "", config = gc("") })
  --use({ "", config = gc("") })
  --use({ "", config = gc("") })
  --use({ "", config = gc("") })

  --use({
  --"",
  --requires = { "" },
  --config = gc(""),
  --})

  --if PACKER_BOOTSTRAP then
  --require("packer").sync()
  --end
end)
