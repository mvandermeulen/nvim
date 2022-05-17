--[[
-- Sessions Plugin
--
-- Author: Mark van der Meulen
-- Updated: 09-05-2022
--]]

require('sessions').setup {
  events = { 'VimLeavePre' },
  session_filepath = '.nvim/session',
}
