local M = {}

-- python env
function M.env_cleanup(venv)
	if string.find(venv, "/") then
		local final_venv = venv
		for w in venv:gmatch("([^/]+)") do
			final_venv = w
		end
		venv = final_venv
	end
	return venv
end

-- null-ls and linter
local function list_registered_providers_names(filetype)
	local s = require("null-ls.sources")
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

function M.get_formatters(filetype)
	local ok, null_ls_methods = pcall(require, "null-ls.methods")
  if not ok then
    return {}
  end
	local formatter_method = null_ls_methods.internal["FORMATTING"]
	local registered_providers = list_registered_providers_names(filetype)
	return registered_providers[formatter_method] or {}
end

function M.get_linters(filetype)
	local ok, null_ls_methods = pcall(require, "null-ls.methods")
  if not ok then
    return {}
  end
	local linter_method = null_ls_methods.internal["DIAGNOSTICS"]
	local registered_providers = list_registered_providers_names(filetype)
	return registered_providers[linter_method] or {}
end

return M
