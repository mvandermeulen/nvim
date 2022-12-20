-- Disable unused built-in plugins
local disabled_built_ins = {
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
	"gzip",
	"zip",
	"zipPlugin",
	"tar",
	"tarPlugin",
	"getscript",
	"getscriptPlugin",
	"vimball",
	"vimballPlugin",
	"2html_plugin",
	"logipat",
	"rrhelper",
	"spellfile_plugin",
	"matchit",
}

for _, plugin in pairs(disabled_built_ins) do
	vim.g["loaded_" .. plugin] = 1
end

-- Bootstrap packer.nvim
local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
end

-- Use a protected call so we don't error out on first use
local ok, packer = pcall(require, "packer")
if not ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

return packer.startup(function(use)
	-- Packer can manage itself
	use({
		"wbthomason/packer.nvim",
		event = "VimEnter",
	})

	--------------------------------------------------------------------------------

	-- Performance
	use("lewis6991/impatient.nvim")
	use("nathom/filetype.nvim")

	-- UI
	use("nvim-lua/popup.nvim")
	use("nvim-lua/plenary.nvim")
	use({
		"rcarriga/nvim-notify",
		config = function()
			vim.notify = require("notify")
		end,
	})
	use({
		"folke/todo-comments.nvim",
		event = "BufRead",
		config = function()
			require("todo-comments").setup({})
		end,
	})
	use({
		"kyazdani42/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").setup({})
		end,
	})
	use({
		"luochen1990/rainbow",
		event = "BufRead",
	})
	use({ "andymass/vim-matchup", requires = "nvim-treesitter/nvim-treesitter" })
	use({
		"windwp/nvim-autopairs",
		event = "BufRead",
		config = function()
			require("nvim-autopairs").setup({
				disable_filetype = { "TelescopePrompt", "vim" },
			})
		end,
	})
	use({
		"norcalli/nvim-colorizer.lua",
		event = "BufRead",
		config = function()
			require("colorizer").setup()
		end,
	})
	use({ "lukas-reineke/indent-blankline.nvim", branch = "master", event = "BufRead" })
	use("jeffkreeftmeijer/vim-numbertoggle")
	-- Peek lines just when you intend
	use({
		"nacro90/numb.nvim",
		event = "BufRead",
		config = function()
			require("numb").setup()
		end,
	})
	use("linty-org/key-menu.nvim")
	use({
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup()
		end,
	})
	use({
		"VonHeikemen/fine-cmdline.nvim",
		requires = { "MunifTanjim/nui.nvim" },
	})
	use("sindrets/winshift.nvim")
	use({
		"akinsho/toggleterm.nvim",
		branch = "main",
		config = function()
			require("toggleterm").setup({
				direction = "float",
			})
		end,
	})
	use({
		"petertriho/nvim-scrollbar",
		config = function()
			require("scrollbar").setup()
			-- require("scrollbar").setup({
			-- handle = {
			-- 	color = "#5A616A",
			-- },
			-- })
		end,
		disable = true,
	})
	use({ "kevinhwang91/nvim-hlslens" })
	use({
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		requires = "neovim/nvim-lspconfig",
		config = function()
			require("lsp_lines").register_lsp_virtual_lines()
		end,
	})
	use({
		"lukas-reineke/virt-column.nvim",
		config = function()
			-- https://github.com/lukas-reineke/virt-column.nvim/issues/2
			vim.cmd("highlight clear ColorColumn")
			require("virt-column").setup({
				char = "│",
			})
		end,
	})

	-- UI / Themes
	use({
		"projekt0n/github-nvim-theme",
		config = function()
			-- https://www.reddit.com/r/neovim/comments/ry9qxi/comment/hroyko0/?utm_source=share&utm_medium=web2x&context=3
			-- Disabled for now as it's causing the statusline and colorcolumn to look incorrect
			-- vim.cmd([[:hi DiagnosticVirtualTextError guifg=#db4b4b guibg=#2D202A]])
			-- vim.cmd([[:hi DiagnosticVirtualTextWarn guifg=#e0af68 guibg=#2E2A2D]])
			-- vim.cmd([[:hi DiagnosticVirtualTextInfo guifg=#0db9d7 guibg=#192B38]])
			-- vim.cmd([[:hi DiagnosticVirtualTextHint guifg=#1abc9c guibg=#1A2B3]])

			-- Default theme
			local theme = "dark_default"
			-- The "user.ui.theme" module may contain `return $THEME`
			theme = require("user.ui.theme")
			local ok, local_theme = pcall(require, "user.ui.theme")
			if ok then
				theme = local_theme
			end

			require("github-theme").setup({
				theme_style = theme,
				-- Overwrite the highlight groups
				overrides = function(_)
					return {
						DiagnosticVirtualTextError = { fg = "#db4b4b", bg = "#2D202A" },
						DiagnosticVirtualTextWarn = { fg = "#e0af68", bg = "#2E2A2D" },
						DiagnosticVirtualTextInfo = { fg = "#1abc9c", bg = "#1A2B3" },
						DiagnosticVirtualTextHint = { fg = "#1abc9c", bg = "#1A2B3" },
					}
				end,
			})
		end,
	})

	-- UI / Marks
	use("kshenoy/vim-signature")

	-- Buffers
	use({
		"stevearc/stickybuf.nvim",
		config = function()
			require("stickybuf").setup()
		end,
	})
	use({
		"luukvbaal/stabilize.nvim",
		config = function()
			require("stabilize").setup()
		end,
	})

	-- Windows
	use("troydm/zoomwintab.vim")

	-- Bufferline
	use({
		"akinsho/bufferline.nvim",
		branch = "main",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("bufferline").setup()
		end,
	})

	-- Statusline
	use({
		"feline-nvim/feline.nvim",
		requires = "lewis6991/gitsigns.nvim",
		config = function()
			local feline = require("feline")

			local config = require("user.plugins.feline-nvim")

			feline.setup(config.statusline)
			feline.winbar.setup(config.winbar)
		end,
		disable = false,
	})

	-- Undo
	use("mbbill/undotree")

	-- Search
	use({ "google/vim-searchindex", event = "BufRead" })
	-- Smart substitution
	use({ "tpope/vim-abolish", event = "BufRead" })
	-- sandwich.vim is a set of operator and textobject plugins to add/delete/replace surroundings of a sandwiched textobject, like (foo), "bar".
	use({ "machakann/vim-sandwich", event = "BufRead" })
	use({
		"phaazon/hop.nvim",
		branch = "master",
		event = "BufRead",
		config = function()
			require("hop").setup({})
		end,
	})

	-- Spotlight
	use({ "nvim-telescope/telescope.nvim", requires = "nvim-telescope/telescope-fzf-native.nvim" })
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
	use({ "jvgrootveld/telescope-zoxide" })
	use({ "nvim-telescope/telescope-file-browser.nvim", requires = "nvim-telescope/telescope.nvim" })

	-- VCS
	use({
		"TimUntersberger/neogit",
		event = "BufRead",
		requires = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
		},
		config = function()
			require("neogit").setup({
				integrations = {
					diffview = true,
				},
			})
		end,
	})
	use({ "sindrets/diffview.nvim", event = "BufRead" })
	-- Super fast git decorations implemented purely in lua/teal.
	use({
		"lewis6991/gitsigns.nvim",
		requires = "nvim-lua/plenary.nvim",
		tag = "release", -- To use the latest release
		event = "BufRead",
		config = function()
			require("gitsigns").setup()
		end,
	})
	use({ "APZelos/blamer.nvim", event = "BufRead" })
	use({ "tpope/vim-fugitive", event = "BufRead" })

	-- LSP
	use("neovim/nvim-lspconfig")
	use({
		"williamboman/nvim-lsp-installer",
		requires = { "neovim/nvim-lspconfig", "stevearc/aerial.nvim" },
		config = function()
			require("nvim-lsp-installer").setup({})
		end,
	})
	use({
		"jose-elias-alvarez/null-ls.nvim",
		requires = "nvim-lua/plenary.nvim",
		event = "VimEnter",
	})
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup()
		end,
	})
	use({
		"stevearc/aerial.nvim",
		requires = "stevearc/stickybuf.nvim",
		config = function()
			require("aerial").setup()
		end,
	})
	-- Standalone UI for nvim-lsp progress. Eye candy for the impatient.
	use({
		"j-hui/fidget.nvim",
		requires = "neovim/nvim-lspconfig",
		config = function()
			require("fidget").setup()
		end,
	})

	-- File system
	use("tpope/vim-eunuch")
	use("airblade/vim-rooter")
	use({
		"kyazdani42/nvim-tree.lua",
		requires = "kyazdani42/nvim-web-devicons",
	})

	-- Comments
	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})

	-- Tree-sitter
	use({
		"nvim-treesitter/nvim-treesitter",
		event = "BufRead",
		run = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = "all",
				ignore_install = { "phpdoc" },
				highlight = {
					enable = true, -- False will disable the whole extension
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<CR>",
						scope_incremental = "<CR>",
						node_incremental = "<TAB>",
						node_decremental = "<S-TAB>",
					},
				},
				textobjects = {
					swap = {
						enable = true,
						swap_next = {
							["<Leader>s"] = "@parameter.inner",
						},
						swap_previous = {
							["<Leader>S"] = "@parameter.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]m"] = "@function.outer",
							["]]"] = "@class.outer",
						},
						goto_next_end = {
							["]M"] = "@function.outer",
							["]["] = "@class.outer",
						},
						goto_previous_start = {
							["[m"] = "@function.outer",
							["[["] = "@class.outer",
						},
						goto_previous_end = {
							["[M"] = "@function.outer",
							["[]"] = "@class.outer",
						},
					},
					context_commentstring = {
						enable = true,
					},
				},
				playground = {
					enable = true,
					disable = {},
					updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
					persist_queries = false, -- Whether the query persists across vim sessions
					keybindings = {
						toggle_query_editor = "o",
						toggle_hl_groups = "i",
						toggle_injected_languages = "t",
						toggle_anonymous_nodes = "a",
						toggle_language_display = "I",
						focus_language = "f",
						unfocus_language = "F",
						update = "R",
						goto_node = "<cr>",
						show_help = "?",
					},
				},
				matchup = {
					enable = true,
					disable = {},
				},
			})
		end,
	})
	use({
		"nvim-treesitter/playground",
		requires = "nvim-treesitter/nvim-treesitter",
		event = "BufRead",
	})
	use({
		"nvim-treesitter/nvim-treesitter-textobjects",
		requires = "nvim-treesitter/nvim-treesitter",
		event = "BufRead",
	})
	use({
		"JoosepAlviste/nvim-ts-context-commentstring",
		requires = "nvim-treesitter/nvim-treesitter",
		event = "BufRead",
	})

	-- Sessions
	use("tpope/vim-obsession")

	-- Completion
	use({
		"ms-jpq/coq_nvim",
		branch = "coq",
		-- event = "InsertEnter",
	})
	use({
		"ms-jpq/coq.artifacts",
		branch = "artifacts",
		requires = "ms-jpq/coq_nvim",
	}) -- 9000+ Snippets

	-- Formatting
	use("sbdchd/neoformat")

	-- Testing
	use("vim-test/vim-test")
	use({
		"rcarriga/vim-ultest",
		requires = "vim-test/vim-test",
		run = ":UpdateRemotePlugins",
		config = function()
			vim.g.ultest_virtual_text = 1
		end,
	})

	-- Languages

	-- Languages / plist
	use("darfink/vim-plist")

	-- Languages / Elixir
	use("elixir-editors/vim-elixir")

	-- Languages / Clojure
	use({
		"eraserhd/parinfer-rust",
		run = "cargo build --release",
	})
	use("Olical/conjure")

	-- Languages / Rust
	use("simrat39/rust-tools.nvim")
	use("rust-lang/rust.vim")

	-- Languages / Markdown
	use("npxbr/glow.nvim")

	-- Languages / Lua
	use({
		"rafcamlet/nvim-luapad",
		config = function()
			require("luapad").setup({})
		end,
	})

	--------------------------------------------------------------------------------

	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
