local M = {}

M.setup_lsp = function()
	local lsp_installer = require("nvim-lsp-installer")
  local on_attach = require("plugins.configs.lsp.lspconfig").on_attach
  local capabilities = require("plugins.configs.lsp.lspconfig").capabilities

	lsp_installer.on_server_ready(function(server)
		local opts = {
			on_attach = on_attach,
			capabilities = capabilities,
			flags = {
				debounce_text_changes = 150,
			},
		}
   if server.name == "sumneko_lua" then
	 	 local sumneko_opts = require("plugins.configs.lsp.settings.sumneko_lua")
	 	 opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
	 end

   if server.name == "bashls" then
	 	 local sumneko_opts = require("plugins.configs.lsp.settings.bashls")
	 	 opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
	 end

	 if server.name == "pyright" then
	 	 local pyright_opts = require("plugins.configs.lsp.settings.pyright")
	 	 opts = vim.tbl_deep_extend("force", pyright_opts, opts)
	 end

		server:setup(opts)
		vim.cmd([[ do User LspAttachBuffers ]])
	end)
end

return M
