--[[
-- Plugins: UI
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
  { 'ray-x/guihua.lua' },
  {-- Windows & Buffers
    'https://gitlab.com/yorickpeterse/nvim-window.git',
    lazy = false,
    config = function()
      require('plugins.nvim-window')
    end,
  },
  {-- Smoothly navigate between neovim splits and tmux panes
    'numToStr/Navigator.nvim',
    lazy = false,
    config = function()
      require('plugins.navigator')
    end,
  },
  {-- Better handling of window open/close events
    'luukvbaal/stabilize.nvim',
    lazy = false,
    config = function()
      require('stabilize').setup()
    end,
  },
  {-- akinsho/bufferline.nvim
    'akinsho/bufferline.nvim',
    lazy = false,
    version = '*',
    dependencies = 'kyazdani42/nvim-web-devicons',
    event = 'BufReadPre',
    config = function()
      require('plugins.bufferline')
    end,
  },
  puse('rcarriga/nvim-notify', 'notify'),
  { 'MunifTanjim/nui.nvim', lazy = false },
  {-- Status Line
    'nvim-lualine/lualine.nvim',
    lazy = false,
    config = gc 'lualine',
    event = 'VimEnter',
    dependencies = { 'kyazdani42/nvim-web-devicons', lazy = true },
  },
  { 'norcalli/nvim-colorizer.lua', lazy = false, event = 'BufReadPre', config = gc 'colorizer' }, -- A high-performance color highlighter
  { 'folke/zen-mode.nvim', cmd = 'ZenMode', config = gc 'zen-mode' }, -- opens the current buffer in a new full-screen floating window, disables plugins, etc
  { 'folke/twilight.nvim', config = gc 'twilight' }, -- dims inactive portions of the code you're editing using TreeSitter
  {-- Start page
    'goolord/alpha-nvim',
    lazy = false,
    config = function ()
        -- require'alpha'.setup(require'alpha.themes.dashboard'.config)
        require'alpha'.setup(require'alpha.themes.startify'.config)
    end
  },
  { 'kevinhwang91/nvim-bqf', lazy = false, dependencies = { { 'junegunn/fzf' } } }, -- Quickfix
  {-- Show troubleshooting window with relevant lists
    'folke/trouble.nvim',
    lazy = false,
    dependencies = 'kyazdani42/nvim-web-devicons',
    cmd = { 'TroubleToggle', 'Trouble' },
    config = gc 'trouble',
  },
  { 'gennaro-tedesco/nvim-jqx', lazy = false }, -- Work with JSON in the quickfix window
  { 'RRethy/vim-illuminate', lazy = false, event = 'CursorHold' }, -- Highlighting
  { 'ironhouzi/starlite-nvim', lazy = false },
  {-- Searching/highlighting of comments such as TODO, HACK, BUG
    'folke/todo-comments.nvim',
    lazy = false,
    dependencies = 'nvim-lua/plenary.nvim',
    cmd = { 'TodoTrouble', 'TodoTelescope' },
    event = 'BufReadPost',
    config = gc 'todo',
  },
  { 'rhysd/conflict-marker.vim', lazy = false }, -- Highlight, jump and resolve conflict markers quickly. ie. Diff conflicts
  { 'rose-pine/neovim', name = 'rose-pine', version = 'v1.*', config = gc 'rpine' },
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
  _G.my.plugins.themes.standard_install,
  _G.my.plugins.themes.extended_install,
}

return M
