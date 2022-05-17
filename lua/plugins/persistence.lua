--[[
-- Persistence aka Sessions
--
-- Author: Mark van der Meulen
-- Updated: 09-05-2022
--]]

require('persistence').setup {
  dir = vim.fn.expand(vim.fn.stdpath 'data' .. '/persistence/'),
}
