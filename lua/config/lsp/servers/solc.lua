--[[
-- LSP Server: solc
--
-- Author: Mark van der Meulen
-- Updated: August 09, 2023
--]]


local settings = {
  cmd = { "solc", "--lsp", "--include-path", "../node_modules" },
}

local opts = {
  settings = {
    solc = settings,
  },
}

return opts
