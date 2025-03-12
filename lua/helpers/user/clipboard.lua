--[[
-- Helper: Clipboard
--
-- Author: Mark van der Meulen
-- Updated: 2025-02-04
--]]


local log = require('plenary.log').new({ plugin = 'clipboard', level = 'debug', use_console = true })
local function mylog(msg, level)
  local level = level or 'debug'
  log.debug(msg)
end

local M = {}

-- local async = require "plenary.async"


local function socket_paste()
  local socket_path = os.getenv('HOME') .. '/.local/tmp/snuggle.socket'
  local pipe = vim.loop.new_pipe(false)
  vim.loop.pipe_connect(pipe, socket_path, function(err)
      assert(not err, err)
  end)
  pipe:write(vim.fn.getreg(''))
  pipe:close()
  -- local socket = vim.uv.new_pipe(false)
  -- local err = async.uv.pipe_connect(socket, vim.fn.resolve(socket_path))
  -- assert(not err, err)
  -- async.uv.write(socket, vim.fn.getreg(''))
end

function M.setup()
  --  Remove this option if you want your OS clipboard to remain independent.
  --  See `:help 'clipboard'`
  vim.opt.clipboard = 'unnamedplus'
  -- Pasting with OSC52 is really slow. Use Neovim's paste instead.
  local function paste()
    socket_paste()
    return {
      vim.split(vim.fn.getreg '', '\n'),
      vim.fn.getregtype '',
    }
  end

  local system_name = vim.loop.os_uname().sysname
  local hostname = vim.env.HOST
  if hostname == 'devbox' or system_name == 'Linux' then
    mylog('Configuring system clipboard', 'info')
    vim.g.clipboard = {
        name = "tmuxclipboard",
        copy = {
            ["+"] = "pbcopy",
            ["*"] = "pbcopy",
        },
        paste = {
            ["+"] = paste,
            ["*"] = paste,
        },
        cache_enabled = 1, -- cache MUST be enabled, or else it hangs on dd/y/x and all other copy operations
    }
    -- if vim.env.SSH_TTY then
    --   if vim.env.TMUX then
    --   end
    -- else
    --   mylog('Configuring xclip clipboard', 'info')
    --   vim.g.clipboard = {
    --     name = 'xclip',
    --     copy = {
    --       ['+'] = { 'xclip', '-quiet', '-i', '-selection', 'clipboard' },
    --       ['*'] = { 'xclip', '-quiet', '-i', '-selection', 'primary' },
    --     },
    --     paste = {
    --       ['+'] = { 'xclip', '-o', '-selection', 'clipboard' },
    --       ['*'] = { 'xclip', '-o', '-selection', 'primary' },
    --     },
    --     cache_enabled = 1, -- cache MUST be enabled, or else it hangs on dd/y/x and all other copy operations
    --   }
    -- end
  end
end



return M
