--[[
-- Persistence aka Sessions
--
-- Author: Mark van der Meulen
-- Updated: 09-05-2022
--]]


local persistence_path = vim.fn.expand(vim.fn.stdpath 'data' .. '/persistence')
if vim.fn.isdirectory(persistence_path) == 0 then
  vim.fn.mkdir(persistence_path, 'p')
end

require('persistence').setup {
  dir = vim.fn.expand(vim.fn.stdpath 'data' .. '/persistence/'),
  need = 2,
}
