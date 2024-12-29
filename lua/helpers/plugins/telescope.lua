--[[
-- Helpers: Telescope
--
-- Author: Mark van der Meulen
-- Updated: 2024-09-22
--]]


local M = {}

local api = require('remote-sshfs.api')
local builtin = require("telescope.builtin")
local connections = require("remote-sshfs.connections")

function M.find_files()
  if connections.is_connected then
    api.find_files()
  else
    -- builtin.find_files()
    builtin.find_files({ find_command = {'fd', '--hidden', '--type', 'file', '--follow'}})
  end
end

function M.live_grep()
  if connections.is_connected then
    api.live_grep()
  else
    builtin.live_grep()
  end
end

return M

