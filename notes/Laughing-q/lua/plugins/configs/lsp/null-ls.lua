local ok, null_ls = pcall(require, "null-ls")

if not ok then
	return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local completion = null_ls.builtins.completion

local sources = {
	-- spell
	completion.spell,
	formatting.prettier,

	-- Lua
	formatting.stylua,
	-- b.diagnostics.luacheck.with { extra_args = { "--global vim" } },

	-- Shell
	formatting.shfmt,
	diagnostics.shellcheck.with({ diagnostics_format = "#{m} [#{c}]" }),

	-- python
	-- formatting.yapf.with({ args = {} }),
	-- formatting.black.with({
 --    cwd = function(params)
 --      return require("lspconfig")["pyright"].get_root_dir(params.bufname)
 --    end,}),
	formatting.black,

	-- latex
	diagnostics.chktex,

	-- null_ls.builtins.code_actions.gitsigns
}

local M = {}

-- M.setup = function(on_attach)
M.setup = function()
	null_ls.setup({
		sources = sources,
		-- debug = true,
	})
	-- require("null-ls").setup({ on_attach = on_attach })
end

return M
