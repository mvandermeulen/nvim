--[[
-- Plugins: Language
-- Author: Mark van der Meulen
-- Updated: 2024-09-21
--]]

local function gc(name)
  return string.format('require("plugins.%s")', name)
end

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

local treesitter_depends = {
  { 'nvim-treesitter/nvim-treesitter-textobjects' },
  { 'p00f/nvim-ts-rainbow' },
  { 'eckon/treesitter-current-functions' },
}

local M = {
  {-- nvim-treesitter
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    dependencies = treesitter_depends,
    config = function()
      require('plugins.treesitter')
    end,
    name = "treesitter",
    build = ':TSUpdate',
  },
  {-- nvim-treesitter-context
    'romgrk/nvim-treesitter-context',
    lazy = false,
    config = function()
      require('plugins.treesitter-context')
    end,
    name = "treesitter-context",
  },
  {-- Pair completion ie. parentheses
    'windwp/nvim-autopairs',
    lazy = false,
    config = function()
      require('plugins.autopairs')
    end,
    name = "autopairs",
  },
  {-- nvim-cmp
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
  {-- LuaSnip
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require('plugins.luasnip')
    end,
  },
  { 'neovim/nvim-lspconfig', lazy = false },
  {-- SmiteshP/nvim-navic
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
  {-- williamboman/mason.nvim
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
  {-- ray-x/lsp_signature.nvim
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
}

return M
