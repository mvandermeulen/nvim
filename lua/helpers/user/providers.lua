--[[
-- Helpers: Providers
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-16
--]]

local M = {
  providers = {},
}

function M.register(name, provider)
  M.providers[name] = provider
end

return M
