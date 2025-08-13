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
local function paste()
  return {
    vim.split(vim.fn.getreg '', '\n'),
    vim.fn.getregtype '',
  }
  -- return {
  --   vim.split(vim.fn.getreg '', "\027%[27;5;106~"),
  --   vim.fn.getregtype '',
  -- }
end


-- vim.paste = (function(paste)
--   return function(lines, phase)
--     local acc = {}
--     for _, line in ipairs(lines) do
--       for _, l in ipairs(vim.split(line, "\027%[27;5;106~")) do
--         table.insert(acc, l)
--       end
--     end
--     return paste(acc, phase)
--   end
-- end)(vim.paste)




local function paste_with_osc52()
  -- This function is used to paste with OSC52, which is not recommended due to slowness.
  -- It is kept here for reference but not used in the clipboard setup.
  return {
    vim.split(vim.fn.getreg(''), '\n'),
    vim.fn.getregtype(''),
  }
end

local function copy_to_local_clipboard(lines, regtype)
  -- This function is used to copy to the local clipboard.
  -- It is kept here for reference but not used in the clipboard setup.
  vim.fn.setreg('', lines, regtype)
end

-- local function local_copy(lines, _) osc52.copy(table.concat(lines, "\n")) end
-- local function local_paste() return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") } end

-- vim.g.clipboard = {
--   name = "osc52",
--   copy = { ["+"] = local_copy, ["*"] = local_copy },
--   paste = { ["+"] = local_paste, ["*"] = local_paste },
-- }

function M.setup()
  --  Remove this option if you want your OS clipboard to remain independent.
  --  See `:help 'clipboard'`
  vim.opt.clipboard = 'unnamedplus'
  -- Pasting with OSC52 is really slow. Use Neovim's paste instead.

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
