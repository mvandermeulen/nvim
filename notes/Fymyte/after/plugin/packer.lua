local has_packer, packer = pcall(require, 'packer')
if not has_packer then
  return
end

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost packer.lua source <afile> | PackerCompile
  augroup end
]])

local function check_system_deps(deps, name)
  for _, dep in pairs(deps) do
    if vim.fn.executable(dep) ~= 1 then
      local msg = ('%q is not installed. (optionnal deps for ' .. name .. ')'):format(dep)
      vim.notify(msg, 'warn', { title = 'Packer' })
    end
  end
end


return packer.startup({
  function(use)
    -- Actual package manager
    use { 'wbthomason/packer.nvim' }

    -- More syntax
    use {
      'mboughaba/i3config.vim',
      as = 'vim-i3',
      ft = { 'i3config' },
    }
    use {
      'fladson/vim-kitty',
      ft = { 'kitty', 'kitty-session' },
    }
    -- use {
    --   'Fymyte/mesonic',
    --   as = 'vim-messon',
    -- }
    use { 'ap/vim-css-color' }
    use {
      'Fymyte/rasi.vim',
      ft = { 'rasi' },
      run = ':TSInstall rasi',
      requires = { 'nvim-treesitter/nvim-treesitter' },
    }
    use {
      'Fymyte/mbsync.vim',
      ft = { 'mbsync' },
    }
    use {
      'amadeus/vim-css',
      ft = { 'css' },
    }
    use {
      'nvim-neorg/neorg',
      requires = {
        'nvim-lua/plenary.nvim',
        'nvim-neorg/neorg-telescope',
      },
    }

    -- Utils
    use {
      'numToStr/Comment.nvim',
      config = function()
        require('Comment').setup()
      end
    }
    use { 'numToStr/FTerm.nvim' }
    use { 'ellisonleao/glow.nvim' }
    use { 'ojroques/vim-oscyank' }
    use { 'rcarriga/nvim-notify' }
    use { 'wellle/targets.vim' }
    use {
      'tpope/vim-surround',
      requires = 'tpope/vim-repeat', -- allow repetition using `.`
    }
    use { 'tpope/vim-fugitive' }
    use {
      'lewis6991/gitsigns.nvim',
      require = 'nvim-lua/plenary.nvim',
    }
    -- Telescope
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use { 'nvim-telescope/telescope-file-browser.nvim' }
    use { 'nvim-telescope/telescope-project.nvim' }
    use { 'gbrlsnchs/telescope-lsp-handlers.nvim' }
    use {
      'rudism/telescope-dict.nvim',
      run = check_system_deps({ 'dictd' }, 'telescope-dict'),
    }
    use {
      'nvim-telescope/telescope.nvim',
      requires = {
        { 'nvim-lua/plenary.nvim' },
      },
      run = check_system_deps({ 'fd', 'rg' }, 'telescope'),
    }
    use { 'windwp/nvim-autopairs' }
    -- Use neovim in the browser!!!
    use {
      'glacambre/firenvim',
      run = function() vim.fn['firenvim#install'](0) end
    }
    -- Autocompletion
    use {
      'hrsh7th/nvim-cmp',
      requires = {
        'hrsh7th/vim-vsnip',
        'hrsh7th/cmp-vsnip',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/cmp-nvim-lua',
        'f3fora/cmp-spell',
        { 'petertriho/cmp-git', requires = 'nvim-lua/plenary.nvim' },
      },
      branch = 'dev'
    }
    -- use {
    --   'sidebar-nvim/sidebar.nvim',
    --   branch = 'dev',
    -- }
    -- Mailbox
    use {
      'soywod/himalaya',
      rtp = 'vim',
      run = check_system_deps({ 'himalaya' }, 'himalaya')
    }
    use { 'vigoux/LanguageTool.nvim' }

    -- LSP
    use {
      'williamboman/nvim-lsp-installer',
      requires = { 'neovim/nvim-lspconfig' },
    }
    use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      requires = { 'nvim-treesitter/nvim-treesitter-textobjects' }
    }
    use {
      'nvim-treesitter/playground',
      run = ':TSInstall query',
      after = 'nvim-treesitter',
    }
    use {
      'simrat39/rust-tools.nvim',
      requires = { 'neovim/nvim-lspconfig' },
    }

    -- UI
    use {
      'onsails/lspkind-nvim',
      requires = { 'neovim/nvim-lspconfig' }
    }
    -- use { 'kaicataldo/material.vim' }
    use {
      'rebelot/kanagawa.nvim',
      as = 'kanagawa',
    }
    use {
      'nvim-lualine/lualine.nvim',
      after = 'kanagawa',
    }
    -- use { 'mhinz/vim-startify' }
    -- use { 'dstein64/vim-startuptime' }

  end,
  config = {
    display = {
      open_fn = function()
        return require('packer.util').float({ border = 'rounded' })
      end,
    },
    log = { level = vim.g.log_level },
  },
})

