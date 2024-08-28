--[[
-- LSP Server: solang
--
-- Author: Mark van der Meulen
-- Updated: August 09, 2023
--]]


local settings = {
  cmd = { "solang", "--language-server", "--target", "ewasm", "--importpath", "node_modules/" },
}

local opts = {
  settings = {
    solang = settings,
  },
}

return opts
