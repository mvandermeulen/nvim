local treesitter_opts = {
	ensure_installed = { "python", "c", "cpp", "cmake", "make", "cuda", "dockerfile", "lua", "vim", "bash", "yaml", "bibtex", "latex", "markdown" }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	ignore_install = {},
	highlight = {
		enable = true, -- false will disable the whole extension
		additional_vim_regex_highlighting = true,
		use_languagetree = true,
		-- disable = { "latex" },
	},
}

local status_ok, treesitter_configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	return
end

treesitter_configs.setup(treesitter_opts)
