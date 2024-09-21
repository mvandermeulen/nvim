--[[
-- Plugins: AI
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
  {-- yetone/avante.nvim
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
  {-- magicalne/nvim.ai
    "magicalne/nvim.ai",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require('plugins.nvimai')
    end
  },
}

return M
