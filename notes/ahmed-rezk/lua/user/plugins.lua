local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install your plugins here
return packer.startup(function(use)
  -- My plugins here
  use "wbthomason/packer.nvim"
  use "nvim-lua/popup.nvim"
  use "nvim-lua/plenary.nvim"
  use "windwp/nvim-autopairs"
  use "numToStr/Comment.nvim"
  use "kyazdani42/nvim-web-devicons"
  use "kyazdani42/nvim-tree.lua"
  use "akinsho/bufferline.nvim"
  use "moll/vim-bbye"
  use {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("user._lualine").setup()
    end,
  }
  use "akinsho/toggleterm.nvim"
  use "ahmedkhalf/project.nvim"
  use "lewis6991/impatient.nvim"
  use "lukas-reineke/indent-blankline.nvim"
  use "goolord/alpha-nvim"
  use "antoinemadec/FixCursorHold.nvim"
  use "folke/which-key.nvim"
  use {
    "p00f/nvim-ts-rainbow",
  }

  -- sessions manager
  use {
    "rmagatti/auto-session",
    config = function()
      require("user._sessions").setup()
    end,
  }
  use {
    "rmagatti/session-lens",
    requires = { "rmagatti/auto-session", "nvim-telescope/telescope.nvim" },
    config = function()
      require("session-lens").setup {--[[your custom config--]]
      }
    end,
  }
  -- Colorschemes
  use "lunarvim/colorschemes" -- A bunch of colorschemes you can try out
  -- use "lunarvim/darkplus.nvim"
  --[[ use({
		"EdenEast/nightfox.nvim",
		config = function()
			require("themes.nightfox").setup()
		end,
	}) ]]

  use {
    "folke/tokyonight.nvim",
    config = function()
      require("tokyonight.colors").setup {}
      -- vim.cmd [[colorscheme tokyonight]]
    end,
  }
  use {
    "olimorris/onedarkpro.nvim",
    config = function()
      require("themes.onedarkPro").setup()
    end,
  }
  use {
    "navarasu/onedark.nvim",
    config = function()
      -- require("themes.onedark").setup()
    end,
  }

  --[[ use({
		"rebelot/kanagawa.nvim",
		config = function()
			require("kanagawa").setup({
				undercurl = true, -- enable undercurls
				commentStyle = "italic",
				functionStyle = "NONE",
				keywordStyle = "italic",
				statementStyle = "bold",
				typeStyle = "NONE",
				variablebuiltinStyle = "italic",
				specialReturn = true, -- special highlight for the return keyword
				specialException = true, -- special highlight for exception handling keywords
				transparent = false, -- do not set background color
				colors = {},
				overrides = {},
			})
		end,
	}) ]]

  -- Hop is an EasyMotion-like plugin allowing you to jump anywhere in a document with as few keystrokes as possible.
  use {
    "phaazon/hop.nvim",
    as = "hop",
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require("hop").setup()
      vim.api.nvim_set_keymap("n", "s", ":HopChar2<cr>", { silent = true })
      vim.api.nvim_set_keymap("n", "S", ":HopWord<cr>", { silent = true })
    end,
  }

  -- cmp plugins
  use "hrsh7th/nvim-cmp"
  use "hrsh7th/cmp-buffer"
  use "hrsh7th/cmp-path"
  use "hrsh7th/cmp-cmdline"
  use "saadparwaiz1/cmp_luasnip"
  use "hrsh7th/cmp-nvim-lsp"
  use { "tzachar/cmp-tabnine", run = "./install.sh", requires = "hrsh7th/nvim-cmp" }

  -- snippets
  use "L3MON4D3/LuaSnip"
  use "rafamadriz/friendly-snippets"

  -- LSP
  use "neovim/nvim-lspconfig"
  use "williamboman/nvim-lsp-installer"
  use "tamago324/nlsp-settings.nvim"
  use "jose-elias-alvarez/null-ls.nvim"
  use {
    "christianchiarulli/nvim-gps",
    branch = "text_hl",
    config = function()
      require("user._gps").setup()
    end,
  }

  -- Telescope
  use "nvim-telescope/telescope.nvim"

  -- Treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
  }
  use {
    "nvim-treesitter/playground",
  }
  use "JoosepAlviste/nvim-ts-context-commentstring"

  -- Git
  use "lewis6991/gitsigns.nvim"
  use {
    "sindrets/diffview.nvim",
    config = function()
      require("user._git").diffviewSetup()
    end,
  }

  use {
    "TimUntersberger/neogit",
    requires = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    config = function()
      require("user._git").neogitSetup()
    end,
  }

  -- Debug Adapter Protocol
  use "mfussenegger/nvim-dap"
  use "rcarriga/nvim-dap-ui"
  use { "nvim-telescope/telescope-dap.nvim" }
  use { "Pocco81/DAPInstall.nvim", branch = "dev" }
  use {
    "Pocco81/DAPInstall.nvim",
    module = "dap-install",
  }
  use "theHamsta/nvim-dap-virtual-text"

  -- Spell checking
  use "kamykn/spelunker.vim"
  use "kamykn/popup-menu.nvim"

  use {
    "chentoast/marks.nvim",
    config = function()
      require("user._marker").setup()
    end,
  }

  use {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("user._colorizer").setup()
    end,
  }

  use {
    "tami5/lspsaga.nvim",
    -- "tami5/lspsaga.nvim",
    config = function()
      require("user._lspsaga").setup()
    end,
  }

  use {
    "ray-x/lsp_signature.nvim",
    --[[ config = function()
			require("user._signature").setup()
		end, ]]
  }

  use {
    "rmagatti/goto-preview",
    config = function()
      require("user.goto").setup()
    end,
  }

  --[[ use({
		"ray-x/navigator.lua",
		requires = { "ray-x/guihua.lua", run = "cd lua/fzy && make" },
		config = function()
			require("user._navigator").setup()
		end,
	}) ]]

  use { "iamcco/markdown-preview.nvim", run = "cd app && npm install" }
  use "davidgranstrom/nvim-markdown-preview"
  use { "ellisonleao/glow.nvim", branch = "main" }

  use {
    "ldelossa/litee.nvim",
    config = function()
      require("user._litee").setup()
    end,
  }
  use "ldelossa/litee-filetree.nvim"
  use "ldelossa/litee-symboltree.nvim"
  use "ldelossa/litee-calltree.nvim"
  use "ldelossa/litee-bookmarks.nvim"
  use "ldelossa/gh.nvim"

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
