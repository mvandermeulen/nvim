local M = {}
local null_ls = require "null-ls"

local function list_registered_providers_names(filetype)
  local s = require "null-ls.sources"
  local available_sources = s.get_available(filetype)
  local registered = {}
  for _, source in ipairs(available_sources) do
    for method in pairs(source.methods) do
      registered[method] = registered[method] or {}
      table.insert(registered[method], source.name)
    end
  end
  return registered
end

-- Get a list of supported formatters & linters
function M.list_supported(filetype, method)
  local s = require "null-ls.sources"
  local supported_formatters = s.get_supported(filetype, method)
  table.sort(supported_formatters)
  return supported_formatters
end

-- Get active formatter
function M.active_formatter(filetype)
  local method = null_ls.methods.FORMATTING
  local registered_providers = list_registered_providers_names(filetype)
  return registered_providers[method] or {}
end

-- Get active linter
function M.active_linter(filetype)
  local method = null_ls.methods.DIAGNOSTICS
  local registered_providers = list_registered_providers_names(filetype)
  return registered_providers[method] or {}
end

return M
