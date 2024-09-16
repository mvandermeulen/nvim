--[[
-- Language Server
--
-- Author: Mark van der Meulen
-- Updated: 02-05-2022
--]]

local present, lsp_configuration = pcall(require, "config.lsp")

if not present then
  return
end

-- return lsp_configuration
