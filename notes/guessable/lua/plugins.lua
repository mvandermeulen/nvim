return require("packer").startup(
  {
    function()
      -- packer
      use "wbthomason/packer.nvim"
      -- lsp
      use "neovim/nvim-lspconfig"
      use "onsails/lspkind-nvim"
      use "tami5/lspsaga.nvim"
      use "ray-x/lsp_signature.nvim"
      -- cmp
      use "hrsh7th/nvim-cmp"
      use "hrsh7th/cmp-nvim-lsp"
      use "hrsh7th/cmp-buffer"
      use "hrsh7th/cmp-path"
      use "hrsh7th/cmp-vsnip"
      use "hrsh7th/vim-vsnip"
      use "octaltree/cmp-look"

      -- file manager
      use {
        "kyazdani42/nvim-tree.lua",
        requires = "kyazdani42/nvim-web-devicons"
      }
      -- telescope
      use {
        "nvim-telescope/telescope.nvim",
        requires = {
          "nvim-lua/plenary.nvim",
          "nvim-lua/popup.nvim"
        }
      }
      -- treesitter
      use {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate"
      }
      use "p00f/nvim-ts-rainbow"
      use "guessable/nvim-onedark"

      -- git
      use "lewis6991/gitsigns.nvim"

      -- start
      use "glepnir/dashboard-nvim"

      -- line
      use "nvim-lualine/lualine.nvim"
      use "romgrk/barbar.nvim"
      use "lukas-reineke/indent-blankline.nvim"

      -- markdown
      use "iamcco/markdown-preview.nvim"

      -- code-runner
      use "is0n/jaq-nvim"

      -- easymotion
      use {
        "phaazon/hop.nvim",
        branch = "v1"
      }

      -- formatter
      use "mhartington/formatter.nvim"

      -- Clipboard manager
      use "AckslD/nvim-neoclip.lua"

      -- utility
      use "folke/trouble.nvim"
      use "folke/which-key.nvim"
      use "folke/zen-mode.nvim"
      use "numToStr/FTerm.nvim"
      use "windwp/nvim-autopairs"
      use "terrortylor/nvim-comment"
      use "karb94/neoscroll.nvim"
      use "kazhala/close-buffers.nvim"

      ------
      ------ vim plugin
      ------
      use "lervag/vimtex"
      use "mg979/vim-visual-multi"
      use "tpope/vim-surround"
      use "dhruvasagar/vim-table-mode"
      use "voldikss/vim-translator"
      use "guessable/vim-utility"
      --
    end,
    config = {
      auto_clean = false,
      display = {
        open_fn = function()
          return require("packer.util").float({border = "rounded"})
        end
      }
    }
  }
)
