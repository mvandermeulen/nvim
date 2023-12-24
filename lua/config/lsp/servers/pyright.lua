--[[
-- LSP Server: python
--
-- Author: Mark van der Meulen
-- Updated: August 09, 2023
--]]


-- local opts = {}

local lsputils_status, lsputils = pcall(require, 'config.lsp.utils')
if not lsputils_status then
  return
end


local settings = {
  analysis = {
    typeCheckingMode = "off",
  },
}

local opts = {
  before_init = function(_, config)
    config.settings.python.pythonPath = lsputils.get_python_path(config.root_dir)
  end,
  settings = {
    python = settings,
  },
}

return opts
