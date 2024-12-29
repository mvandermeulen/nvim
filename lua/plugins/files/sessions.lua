--[[
-- Sessions Plugin
--
-- Author: Mark van der Meulen
-- Updated: 09-05-2022
--]]

local sessions_path = vim.fn.expand(vim.fn.stdpath 'data' .. '/sessions')
if vim.fn.isdirectory(sessions_path) == 0 then
  vim.fn.mkdir(sessions_path, 'p')
end


require('sessions').setup {
  -- events = { 'VimLeavePre', 'WinEnter' },
  events = { 'VimLeavePre' },
  session_filepath = vim.fn.expand(vim.fn.stdpath 'data' .. '/sessions'),
  absolute = true,
}
