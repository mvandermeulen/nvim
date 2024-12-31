--[[
-- Helper: Clipboard
--
-- Author: Mark van der Meulen
-- Updated: 2025-01-01
--]]


local log = require('plenary.log').new({ plugin = 'clipboard', level = 'debug', use_console = true })
local function mylog(msg, level)
  local level = level or 'debug'
  log.debug(msg)
  -- if level == 'info' or level == 'warn' or level == 'error' then
  --   vim.notify(msg, vim.log.levels.INFO, { title = 'Mason' })
  -- end
end

local M = {}


function M.setup()
  -- Sync clipboard between OS and Neovim.
  --  Remove this option if you want your OS clipboard to remain independent.
  --  See `:help 'clipboard'`
  vim.opt.clipboard = 'unnamedplus'

  local system_name = vim.loop.os_uname().sysname
  local hostname = vim.env.HOST
  if hostname == 'devbox' or system_name == 'Linux' then
    -- Set neovim clipboard
    -- NOTE: your terminal emulator must support the OSC 52 control sequence for SSH
    -- See `:help 'clipboard-osc52'`
    if vim.env.SSH_TTY then
      -- Pasting with OSC52 is really slow. Use Neovim's paste instead.
      -- local function paste()
      --   return {
      --     vim.split(vim.fn.getreg '', '\n'),
      --     vim.fn.getregtype '',
      --   }
      -- end

      if vim.env.TMUX then
        mylog('Configuring tmux clipboard', 'info')
        vim.g.clipboard = {
            name = "tmuxclipboard",
            copy = {
                -- ["+"] = "tmux load-buffer -w -",
                -- ["*"] = "tmux load-buffer -w -",
                ["+"] = "pbcopy",
                ["*"] = "pbcopy",
            },
            paste = {
                ["+"] = "tmux save-buffer -",
                ["*"] = "tmux save-buffer -",
            },
        }
      end
      -- vim.g.clipboard = {
      --   name = 'OSC 52',
      --   copy = {
      --     ['+'] = require('vim.ui.clipboard.osc52').copy '+',
      --     ['*'] = require('vim.ui.clipboard.osc52').copy '*',
      --   },
      --   paste = {
      --     ['+'] = paste,
      --     ['*'] = paste,
      --   },
      -- }
    else
      mylog('Configuring xclip clipboard', 'info')
      vim.g.clipboard = {
        name = 'xclip',
        copy = {
          ['+'] = { 'xclip', '-quiet', '-i', '-selection', 'clipboard' },
          ['*'] = { 'xclip', '-quiet', '-i', '-selection', 'primary' },
        },
        paste = {
          ['+'] = { 'xclip', '-o', '-selection', 'clipboard' },
          ['*'] = { 'xclip', '-o', '-selection', 'primary' },
        },
        cache_enabled = 1, -- cache MUST be enabled, or else it hangs on dd/y/x and all other copy operations
      }
    end
  end
end



return M
