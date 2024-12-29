--[[
-- Mason LSP Plugin
--
-- Author: Mark van der Meulen
-- Updated: 12-02-2023
--]]

local present, mason_config = pcall(require, "config.lsp.mason")

if not present then
  return
end

