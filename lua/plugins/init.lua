-- local execute = vim.api.nvim_command
-- local fn = vim.fn

-- vim.fn.setenv('MACOSX_DEPLOYMENT_TARGET', '10.15')

-- local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

-- returns the require for use in `config` parameter of packer's use
-- expects the name of the config file
local function gc(name)
  return string.format('require("plugins.%s")', name)
end


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Function to make using plugins easier. Expects opts to be a dictionary if provided.
local function puse(repo, cfg, opts)
  if cfg then
    if opts then
      return {
        repo,
        dependencies = opts,
        lazy = false,
        config = function()
          require(string.format('plugins.%s', cfg))
        end,
      }
    else
      return {
        repo,
        lazy = false,
        config = function()
          require(string.format('plugins.%s', cfg))
        end,
      }
    end
  else
    if opts then
      return {
        repo,
        dependencies = opts,
        lazy = false,
      }
    else
      return {
        repo,
        lazy = false,
      }
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
    return {
      repo,
      dependencies = depends,
      lazy = false,
      config = function()
        require(string.format('plugins.%s', cfg))
      end,
    }
  else
    return {
      repo,
      dependencies = depends,
      lazy = false,
    }
  end
end


---------------------------
-- Dependencies
---------------------------
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
  { 'nvim-telescope/telescope-ui-select.nvim' },
}
local treesitter_depends = {
  { 'nvim-treesitter/nvim-treesitter-textobjects' },
  { 'p00f/nvim-ts-rainbow' },
  { 'eckon/treesitter-current-functions' },
}
local diff_plugin_cmds = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' }


require("lazy").setup({
  {
    'norcalli/nvim-terminal.lua',
    lazy = false,
    priority = 1000,
    concurrency = 2,
    config = function()
      require('terminal').setup()
    end,
  },
  {
    'tami5/sqlite.lua',
    name = 'sqlite',
    lazy = false,
    priority = 1000,
  },
  {
    'echasnovski/mini.nvim',
    version = '*',
    config = function()
      require('plugins.mini')
    end,
  },
  pluse('ibhagwan/fzf-lua', 'fzf-lua', { { 'kyazdani42/nvim-web-devicons' } }), -- Start page
  { 'nvim-telescope/telescope.nvim', lazy = false, dependencies = telescope_depends, config = gc 'telescope' },
  { 'nvim-telescope/telescope-fzf-native.nvim', lazy = false, build = 'make' },
  puse('sudormrfbin/cheatsheet.nvim', 'cheatsheet'),
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    dependencies = treesitter_depends,
    config = function()
      require('plugins.treesitter')
    end,
    name = "treesitter",
    build = ':TSUpdate',
  },
  {
    'romgrk/nvim-treesitter-context',
    lazy = false,
    config = function()
      require('plugins.treesitter-context')
    end,
    name = "treesitter-context",
  },
  {
    'windwp/nvim-autopairs',-- Pair completion ie. parentheses
    lazy = false,
    config = function()
      require('plugins.autopairs')
    end,
    name = "autopairs",
  },
  {
    'hrsh7th/nvim-cmp',
    lazy = false,
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-buffer' }, -- buffer completions
      { 'hrsh7th/cmp-path' }, -- path completions
      { 'hrsh7th/cmp-cmdline' }, -- cmdline completions
      { 'hrsh7th/cmp-calc' },
      { 'hrsh7th/cmp-nvim-lua' },
      { 'onsails/lspkind-nvim' },
      { 'famiu/bufdelete.nvim' },
    },
    config = function()
      require('plugins.cmp')
    end,
    name = "cmp",
  },
  {
    "yetone/avante.nvim",
    lazy = false,
    -- event = "VeryLazy",
    build = "make", -- This is Optional, only if you want to use tiktoken_core to calculate tokens count
    config = function()
      require('plugins.avante')
    end,
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below is optional, make sure to setup it properly if you have lazy=true
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  {
    "magicalne/nvim.ai",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require('plugins.ai')
    end
  },
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require('plugins.luasnip')
    end,
  },
  {
    "chrisgrieser/nvim-scissors",
    dependencies = { "nvim-telescope/telescope.nvim", "L3MON4D3/LuaSnip" }, 
    config = function()
      require('plugins.scissors')
    end,
    opts = {
      snippetDir = os.getenv("HOME") .. "/.config/nvim/snippets/vsc",
    },
  },
  { 'neovim/nvim-lspconfig', lazy = false },
  {
    'SmiteshP/nvim-navic',
    lazy = false,
    dependencies = {
      {'neovim/nvim-lspconfig'},
    },
  },
  { 'nvimtools/none-ls.nvim', lazy = false },
  { 'jay-babu/mason-null-ls.nvim', lazy = false },
  { 'WhoIsSethDaniel/mason-tool-installer.nvim', lazy = false },
  { 'mhartington/formatter.nvim', lazy = false },
  {
    'williamboman/mason.nvim',
    lazy = false,
    dependencies = {
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason-lspconfig.nvim'},
      {'jay-babu/mason-null-ls.nvim'},
      {'nvimtools/none-ls.nvim'},
      {'WhoIsSethDaniel/mason-tool-installer.nvim'},
    },
    config = function()
      require('plugins.mason')
    end,
    name = "mason",
  },
  {
    'ray-x/lsp_signature.nvim',
    lazy = false,
    dependencies = {
      {'neovim/nvim-lspconfig'},
    },
    config = function()
      require('plugins.lsp-signature')
    end,
    name = "lsp-signature",
  },
  { 'rmagatti/goto-preview', lazy = false, config = gc 'goto-preview' },
  { 'simrat39/symbols-outline.nvim', lazy = false, cmd = { 'SymbolsOutline' }, config = gc 'symbols' },
  { 'cuducos/yaml.nvim', ft = { 'yaml' } }, -- Language Specific
  { 'ray-x/guihua.lua' },
  {
    'kyazdani42/nvim-tree.lua',
    lazy = false,
    config = function()
      require('plugins.nvim-tree')
    end,
  }, -- File Management
  { 'jghauser/mkdir.nvim', lazy = false }, -- Makes directories on save if required. Not Lua
  { 'sindrets/diffview.nvim', lazy = false, cmd = diff_plugin_cmds, config = gc 'diffview' }, -- Diff plugin (requirement for Neogit)
  pluse('tanvirtin/vgit.nvim', 'vgit'),
  { 'TimUntersberger/neogit', dependencies = { 'nvim-lua/plenary.nvim' }, cmd = 'Neogit', config = gc 'neogit' },
  {
    'lewis6991/gitsigns.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('plugins.gitsigns')
    end,
  },
  {
    'ThePrimeagen/harpoon',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('plugins.harpoon')
    end,
  },
  {
    'ahmedkhalf/project.nvim',
    lazy = false,
    config = function()
      require('plugins.project')
    end,
  },
  -- {
  --   'natecraddock/sessions.nvim',
  --   lazy = false,
  --   config = function()
  --     require('plugins.sessions')
  --   end,
  -- },
  -- {
  --   'natecraddock/workspaces.nvim',
  --   lazy = false,
  --   config = function()
  --     require('plugins.workspaces')
  --   end,
  -- },
  {
    'folke/persistence.nvim',
    lazy = false,
    event = 'BufReadPre',
    config = function()
      require('plugins.persistence')
    end,
  },
  -- {
  --   'Shatur/neovim-session-manager',
  --   lazy = false,
  --   config = function()
  --     require('plugins.session-manager')
  --   end,
  -- },
  -- {
  --   'rmagatti/auto-session',
  --   lazy = false,
  --   config = function()
  --     require('plugins.auto-session')
  --   end,
  -- },
  {
    'https://gitlab.com/yorickpeterse/nvim-window.git',
    lazy = false,
    config = function()
      require('plugins.nvim-window')
    end,
  }, -- Windows & Buffers
  {
    'numToStr/Navigator.nvim',
    lazy = false,
    config = function()
      require('plugins.navigator')
    end,
  }, -- Smoothly navigate between neovim splits and tmux panes
  {
    'luukvbaal/stabilize.nvim',
    lazy = false,
    config = function()
      require('stabilize').setup()
    end,
  }, -- Better handling of window open/close events
  {
    'akinsho/bufferline.nvim',
    lazy = false,
    version = '*',
    dependencies = 'kyazdani42/nvim-web-devicons',
    event = 'BufReadPre',
    config = function()
      require('plugins.bufferline')
    end,
  },
  { 'famiu/bufdelete.nvim', lazy = false },
  {
    'ggandor/lightspeed.nvim',
    lazy = false,
    event = 'BufReadPre',
  }, -- Navigation
  {
    'chentoast/marks.nvim',
    lazy = false,
    config = function()
      require('plugins.marks')
    end,
  },-- Bookmarks
  {
    'folke/which-key.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('plugins.which')
    end,
  }, -- Mappings
  {
    'akinsho/nvim-toggleterm.lua',
    version = "*",
    lazy = false,
    config = function()
      require('plugins.toggleterm')
    end,
  }, -- Terminal & Commands/Tasks
  { 'waylonwalker/Telegraph.nvim', lazy = false },
  {
    'tknightz/telescope-termfinder.nvim',
    lazy = false,
    config = function()
      require('telescope').load_extension("termfinder")
    end,
  }, -- for displaying terminal colors in the pane_contents previewer with telescope-tmux
	{ 'jedrzejboczar/toggletasks.nvim', lazy = false, dependencies = { 'nvim-lua/plenary.nvim', 'akinsho/toggleterm.nvim', 'nvim-telescope/telescope.nvim' }, config = gc('toggletasks') },
  {
    'tversteeg/registers.nvim',
    lazy = false,
    config = function()
      require('plugins.registers')
    end,
    name = "registers",
  },
  {
    'AckslD/nvim-neoclip.lua',
    lazy = false,
    dependencies = { { 'tami5/sqlite.lua' }, { 'nvim-telescope/telescope.nvim' } },
    config = function()
      require('plugins.neoclip')
    end,
    name = "neoclip",
  },
  {
    "ptdewey/yankbank-nvim",
    dependencies = "kkharji/sqlite.lua",
    config = function()
        require('yankbank').setup({
            persist_type = "sqlite",
        })
    end,
  },
  puse('rcarriga/nvim-notify', 'notify'),
  { 'MunifTanjim/nui.nvim', lazy = false },
  {
    'nvim-lualine/lualine.nvim',
    lazy = false,
    config = gc 'lualine',
    event = 'VimEnter',
    dependencies = { 'kyazdani42/nvim-web-devicons', lazy = true },
  }, -- Status Line
  { 'norcalli/nvim-colorizer.lua', lazy = false, event = 'BufReadPre', config = gc 'colorizer' }, -- A high-performance color highlighter
  { 'folke/zen-mode.nvim', cmd = 'ZenMode', config = gc 'zen-mode' }, -- opens the current buffer in a new full-screen floating window, disables plugins, etc
  { 'folke/twilight.nvim', config = gc 'twilight' }, -- dims inactive portions of the code you're editing using TreeSitter
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  { 'LudoPinelli/comment-box.nvim', lazy = false, config = gc 'comment-box' }, -- Create boxes and lines in comments
  {
    'goolord/alpha-nvim',
    lazy = false,
    config = function ()
        -- require'alpha'.setup(require'alpha.themes.dashboard'.config)
        require'alpha'.setup(require'alpha.themes.startify'.config)
    end
  },
  { 'kevinhwang91/nvim-bqf', lazy = false, dependencies = { { 'junegunn/fzf' } } }, -- Quickfix
  {
    'folke/trouble.nvim',
    lazy = false,
    dependencies = 'kyazdani42/nvim-web-devicons',
    cmd = { 'TroubleToggle', 'Trouble' },
    config = gc 'trouble',
  }, -- Show troubleshooting window with relevant lists
  { 'gennaro-tedesco/nvim-jqx', lazy = false }, -- Work with JSON in the quickfix window
  { 'RRethy/vim-illuminate', lazy = false, event = 'CursorHold' }, -- Highlighting
  { 'ironhouzi/starlite-nvim', lazy = false },
  {
    'folke/todo-comments.nvim',
    lazy = false,
    dependencies = 'nvim-lua/plenary.nvim',
    cmd = { 'TodoTrouble', 'TodoTelescope' },
    event = 'BufReadPost',
    config = gc 'todo',
  }, -- Searching/highlighting of comments such as TODO, HACK, BUG
  { 'rhysd/conflict-marker.vim', lazy = false }, -- Highlight, jump and resolve conflict markers quickly. ie. Diff conflicts
  { 'rose-pine/neovim', name = 'rose-pine', version = 'v1.*', config = gc 'rpine' },
  _G.my.plugins.themes.standard_install,
  _G.my.plugins.themes.extended_install,
  { 'rktjmp/lush.nvim' },
  { 'folke/tokyonight.nvim' },
  { 'rebelot/kanagawa.nvim' },
  { 'marko-cerovac/material.nvim' },
  { 'eddyekofo94/gruvbox-flat.nvim' },
  { 'shaunsingh/nord.nvim' },
  { 'navarasu/onedark.nvim' },
  { 'olimorris/onedarkpro.nvim' },
  { 'savq/melange' },
  { 'rmehri01/onenord.nvim' },
  { 'Yagua/nebulous.nvim' },
  { 'andersevenrud/nordic.nvim' },
  { 'kvrohit/substrata.nvim' },
  { 'Domeee/mosel.nvim' },
  { 'teloe/drip.nvim' },
  { 'sainnhe/gruvbox-material' },
  { 'Mofiqul/dracula.nvim' },
  { 'shaeinst/roshnivim-cs' },
  { 'rafamadriz/neon' },
  { 'clpi/cyu.lua' },
  { 'glepnir/zephyr-nvim' },
  { 'sam4llis/nvim-tundra' },
  { 'lmburns/kimbox' },
  { 'lvim-tech/lvim-colorscheme' },
  { 'mcchrish/zenbones.nvim' },
  { 'Mofiqul/vscode.nvim' },
  { 'decaycs/decay.nvim', name = 'decay' },
  { 'yashguptaz/calvera-dark.nvim' },
  { 'ishan9299/nvim-solarized-lua' },
  { 'NTBBloodbath/doom-one.nvim' },
  { 'shaunsingh/solarized.nvim' },
  { 'Mofiqul/adwaita.nvim' },
  { 'metalelf0/jellybeans-nvim' },
  { 'Murtaza-Udaipurwala/gruvqueen' },
  { 'daschw/leaf.nvim' },
  { 'AlexvZyl/nordic.nvim', name = 'alexvzyl-nordic' },
  { 'numToStr/Comment.nvim', config = gc 'comment' },
  })
