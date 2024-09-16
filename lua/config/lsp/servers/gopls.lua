--[[
-- LSP Server: gopls
--
-- Author: Mark van der Meulen
-- Updated: August 09, 2023
--]]


-- local opts = {}

local settings = { analyses = { unusedparams = true }, staticcheck = true }

local opts = {
  settings = {
    gopls = settings,
  },
}

return opts
