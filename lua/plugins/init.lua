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

local ui_plugins = require('plugins.ui')
local ai_plugins = require('plugins.ai')
local lang_plugins = require('plugins.lang')
local file_plugins = require('plugins.files')
local utility_plugins = require('plugins.utils')


require("lazy").setup({ utility_plugins, lang_plugins, file_plugins, ui_plugins })
