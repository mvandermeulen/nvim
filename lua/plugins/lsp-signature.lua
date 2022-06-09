--[[
-- Language Server Signature
--
-- Author: Mark van der Meulen
-- Updated: 02-05-2022
--]]

local present, signature_setup = pcall(require, "config.lsp.signature")

if not present then
  return
end

-- return signature_setup
