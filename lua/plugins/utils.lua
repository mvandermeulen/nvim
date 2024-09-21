--[[
-- Plugins: Utils
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



local M = {
  {-- nvim-terminal.lua
    'norcalli/nvim-terminal.lua',
    lazy = false,
    priority = 1000,
    concurrency = 2,
    config = function()
      require('terminal').setup()
    end,
  },
  {-- sqlite.lua
    'tami5/sqlite.lua',
    name = 'sqlite',
    lazy = false,
    priority = 1000,
  },
  {-- mini.nvim
    'echasnovski/mini.nvim',
    version = '*',
    config = function()
      require('plugins.mini')
    end,
  },
  puse('sudormrfbin/cheatsheet.nvim', 'cheatsheet'),
  {-- nvim-scissors
    "chrisgrieser/nvim-scissors",
    dependencies = { "nvim-telescope/telescope.nvim", "L3MON4D3/LuaSnip" }, 
    config = function()
      require('plugins.scissors')
    end,
    opts = {
      snippetDir = os.getenv("HOME") .. "/.config/nvim/snippets/vsc",
    },
  },
  {-- Registers
    'tversteeg/registers.nvim',
    lazy = false,
    config = function()
      require('plugins.registers')
    end,
    name = "registers",
  },
  {-- neoclip
    'AckslD/nvim-neoclip.lua',
    lazy = false,
    dependencies = { { 'tami5/sqlite.lua' }, { 'nvim-telescope/telescope.nvim' } },
    config = function()
      require('plugins.neoclip')
    end,
    name = "neoclip",
  },
  {-- Yankbank
    "ptdewey/yankbank-nvim",
    dependencies = "kkharji/sqlite.lua",
    config = function()
        require('yankbank').setup({
            persist_type = "sqlite",
        })
    end,
  },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  { 'LudoPinelli/comment-box.nvim', lazy = false, config = gc 'comment-box' }, -- Create boxes and lines in comments
  { 'famiu/bufdelete.nvim', lazy = false },
  {-- Navigation
    'ggandor/lightspeed.nvim',
    lazy = false,
    event = 'BufReadPre',
  },
  {-- Bookmarks
    'chentoast/marks.nvim',
    lazy = false,
    config = function()
      require('plugins.marks')
    end,
  },
  {-- Mappings
    'folke/which-key.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('plugins.which')
    end,
  },
  {-- Terminal & Commands/Tasks
    'akinsho/nvim-toggleterm.lua',
    version = "*",
    lazy = false,
    config = function()
      require('plugins.toggleterm')
    end,
  },
  { 'waylonwalker/Telegraph.nvim', lazy = false },
  {-- telescope-termfinder.nvim: for displaying terminal colors in the pane_contents previewer with telescope-tmux
    'tknightz/telescope-termfinder.nvim',
    lazy = false,
    config = function()
      require('telescope').load_extension("termfinder")
    end,
  },
  { 'jedrzejboczar/toggletasks.nvim', lazy = false, dependencies = { 'nvim-lua/plenary.nvim', 'akinsho/toggleterm.nvim', 'nvim-telescope/telescope.nvim' }, config = gc('toggletasks') },
  { 'numToStr/Comment.nvim', config = gc 'comment' },
}

return M
