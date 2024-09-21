--[[
-- Plugins: File Management
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
local diff_plugin_cmds = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' }

---------------------------
-- Plugins
---------------------------

local M = {
  pluse('ibhagwan/fzf-lua', 'fzf-lua', { { 'kyazdani42/nvim-web-devicons' } }),
  { 'nvim-telescope/telescope.nvim', lazy = false, dependencies = telescope_depends, config = gc 'telescope' },
  { 'nvim-telescope/telescope-fzf-native.nvim', lazy = false, build = 'make' },
  {-- File Management
    'kyazdani42/nvim-tree.lua',
    lazy = false,
    config = function()
      require('plugins.nvim-tree')
    end,
  },
  { 'jghauser/mkdir.nvim', lazy = false }, -- Makes directories on save if required. Not Lua
  { 'sindrets/diffview.nvim', lazy = false, cmd = diff_plugin_cmds, config = gc 'diffview' }, -- Diff plugin (requirement for Neogit)
  pluse('tanvirtin/vgit.nvim', 'vgit'),
  { 'TimUntersberger/neogit', dependencies = { 'nvim-lua/plenary.nvim' }, cmd = 'Neogit', config = gc 'neogit' },
  {-- lewis6991/gitsigns.nvim
    'lewis6991/gitsigns.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('plugins.gitsigns')
    end,
  },
  {-- ThePrimeagen/harpoon
    'ThePrimeagen/harpoon',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('plugins.harpoon')
    end,
  },
  {-- ahmedkhalf/project.nvim
    'ahmedkhalf/project.nvim',
    lazy = false,
    config = function()
      require('plugins.project')
    end,
  },
  {-- folke/persistence.nvim
    'folke/persistence.nvim',
    lazy = false,
    event = 'BufReadPre',
    config = function()
      require('plugins.persistence')
    end,
  },
  {-- sessions.nvim
    'natecraddock/sessions.nvim',
    lazy = false,
    config = function()
      require('plugins.sessions')
    end,
  },
  {-- natecraddock/workspaces.nvim
    'natecraddock/workspaces.nvim',
    lazy = false,
    config = function()
      require('plugins.workspaces')
    end,
  },
  {-- Shatur/neovim-session-manager
    'Shatur/neovim-session-manager',
    lazy = false,
    config = function()
      require('plugins.session-manager')
    end,
  },
  -- {-- rmagatti/auto-session
  --   'rmagatti/auto-session',
  --   lazy = false,
  --   config = function()
  --     require('plugins.auto-session')
  --   end,
  -- },
}

return M
