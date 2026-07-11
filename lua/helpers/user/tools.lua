--[[
-- Helpers: Functions
--
-- Author: Mark van der Meulen
-- Updated: 2025-02-10
--]]


local _name = 'user.tools'
local _log = require('plenary.log').new({ plugin = _name, level = 'debug', use_console = true })

local function mlog(msg, level)
  local level = level or 'debug'
  if level == 'error' then
    _log.error(msg)
    vim.notify(msg, vim.log.levels.ERROR, { title = _name })
    print(msg)
  elseif level == 'notify' then
    vim.notify(msg, vim.log.levels.INFO, { title = _name })
    _log.info(msg)
  elseif level == 'info' then
    _log.info(msg)
  else
    _log.debug(msg)
  end
end



local M = {}

local uv = vim.uv or vim.loop
local utils = require("helpers.utils.utils")
local CONFIRM_THRESHOLD = 5

-- Default configuration
M.config = {
  socket_path = utils.get_home() .. '/.local/state/snuggle.socket',-- default socket path
}


M.root_patterns = { ".git", "/lua", '.is_root_directory' }






