local M = {}
require("plugins.configs.compile")
require("plugins.configs.format")
local leader_key = {}

leader_key = {
	setup = {
		plugins = {
			marks = true, -- shows a list of your marks on ' and `
			registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
			-- the presets plugin, adds help for a bunch of default keybindings in Neovim
			-- No actual key bindings are created
			presets = {
				operators = false, -- adds help for operators like d, y, ...
				motions = false, -- adds help for motions
				text_objects = false, -- help for text objects triggered after entering an operator
				windows = true, -- default bindings on <c-w>
				nav = true, -- misc bindings to work with windows
				z = true, -- bindings for folds, spelling and others prefixed with z
				g = true, -- bindings for prefixed with g
			},
			spelling = { enabled = true, suggestions = 20 }, -- use which-key for spelling hints
		},
		icons = {
			breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
			separator = "➜", -- symbol used between a key and it's label
			group = "+", -- symbol prepended to a group
		},
		window = {
			border = "single", -- none, single, double, shadow
			position = "bottom", -- bottom, top
			margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
			padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
		},
		layout = {
			height = { min = 4, max = 25 }, -- min and max height of the columns
			width = { min = 20, max = 50 }, -- min and max width of the columns
			spacing = 3, -- spacing between columns
		},
		hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
		show_help = true, -- show help message on the command line when the popup is visible
	},

	opts = {
		mode = "n", -- NORMAL mode
		prefix = "<leader>",
		buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
		silent = true, -- use `silent` when creating keymaps
		noremap = true, -- use `noremap` when creating keymaps
		nowait = true, -- use `nowait` when creating keymaps
	},
	-- NOTE: Prefer using : over <cmd> as the latter avoids going back in normal-mode.
	-- see https://neovim.io/doc/user/map.html#:map-cmd

	mappings = {
		-- e = { "<cmd>NvimTreeToggle<CR>", "NvimTree" },
		-- f = { "<cmd>Telescope find_files<CR>", "Find File" },
		["<CR>"] = { "<cmd>nohlsearch<CR>", "No Highlight" },

		-- window move stuff
		w = { "<C-w>w", "Window previous" },
		j = { "<C-w>h", "Window left" },
		l = { "<C-w>l", "Window right" },
		i = { "<C-w>k", "Window up" },
		k = { "<C-w>j", "Window down" },

		-- spell and wrap stuff
		-- s = {
			-- name = "spell and wrap",
			-- s = { ":set spell!<CR>", "Spell check" },
			-- w = { ":set wrap!<CR>", "Set wrap" },
			-- l = { ":set splitright<CR>:vsplit<CR>", "Split left" },
			-- k = { ":set splitbelow<CR>:split<CR>", "Split down" },
			-- i = { ":set nosplitright<CR>:vsplit<CR>:set splitright<CR>", "Split up" },
			-- j = { ":set nosplitbelow<CR>:split<CR>:set splitbelow<CR>", "Split right" },
		-- },

		-- nvimtree
		e = { ":NvimTreeFocus <CR>", "NvimTree Focus" },

		-- functions and values
		v = { "<cmd>Vista!!<CR>", "Vista" },
		-- Compile file
		r = { "<cmd>call CompileRunGcc()<CR>", "Compile file" },
		-- transparency
		-- t = { "<cmd>call TransparentToggle<CR>", "Compile file" },

		-- fold
		o = { "za", "Fold" },
		-- markdown
		m = {
			name = "Markdown",
			g = { "<cmd>GenTocGFM<CR>", "GenToc" },
			-- m = { "<cmd>TableModeToggle<CR>", "TableMode" },
		},
		-- b = {
		-- 	name = "Buffers",
		-- 	g = { "<cmd>BufferPick<cr>", "Jump" },
		-- 	-- f = { "<cmd>Telescope buffers<cr>", "Find" },
		-- 	b = { "<cmd>b#<cr>", "Previous" },
		-- 	w = { "<cmd>BufferWipeout<cr>", "Wipeout" },
		-- 	-- e = {
		-- 	-- 	"<cmd>BufferCloseAllButCurrent<cr>",
		-- 	-- 	"Close all but current",
		-- 	-- },
		-- 	j = { "<cmd>BufferCloseBuffersLeft<cr>", "Close all to the left" },
		-- 	l = {
		-- 		"<cmd>BufferCloseBuffersRight<cr>",
		-- 		"Close all to the right",
		-- 	},
		-- 	c = {
		-- 		"<cmd>BufferCloseAllButCurrent<cr>",
		-- 		"Close all but Current",
		-- 	},
		-- 	p = {
		-- 		"<cmd>BufferCloseAllButPinned<cr>",
		-- 		"Close all but Pinned",
		-- 	},
		-- 	d = {
		-- 		"<cmd>BufferOrderByDirectory<cr>",
		-- 		"Sort by directory",
		-- 	},
		-- 	L = {
		-- 		"<cmd>BufferOrderByLanguage<cr>",
		-- 		"Sort by language",
		-- 	},
		-- },
		p = {
			name = "Packer",
			c = { "<cmd>PackerCompile<cr>", "Compile" },
			i = { "<cmd>PackerInstall<cr>", "Install" },
			s = { "<cmd>PackerSync<cr>", "Sync" },
			S = { "<cmd>PackerStatus<cr>", "Status" },
			u = { "<cmd>PackerUpdate<cr>", "Update" },
		},

		g = {
			name = "Git",
			k = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
			i = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
			l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
			p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
			r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
			R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
			s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
			u = {
				"<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
				"Undo Stage Hunk",
			},
			o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
			b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
			c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
			C = {
				"<cmd>Telescope git_bcommits<cr>",
				"Checkout commit(for current file)",
			},
			d = {
				"<cmd>Gitsigns diffthis HEAD<cr>",
				"Git Diff",
			},
		},

		L = {
			name = "LSP",
			l = { "<cmd>LspStop<cr>", "Close LSP" },
			L = { "<cmd>LspStart<cr>", "Open LSP" },
			a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
			d = {
				"<cmd>Telescope diagnostics bufnr=0<cr>",
				"Document Diagnostics",
			},
			w = {
				"<cmd>Telescope lsp_workspace_diagnostics<cr>",
				"Workspace Diagnostics",
			},
			-- f = { "<cmd>lua vim.lsp.buf.formatting()<cr>", "Format" },
			f = { "<cmd>call Format()<CR>", "Format" },
			-- f = { "<cmd>lua vim.lsp.buf.range_formatting()<cr>", "Format" },
			h = { "<cmd>LspInfo<cr>", "Info" },
			k = {
				"<cmd>lua vim.lsp.diagnostic.goto_next()<cr>",
				"Next Diagnostic",
			},
			i = {
				"<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>",
				"Prev Diagnostic",
			},
			q = { "<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>", "Quickfix" },
			r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
			s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
			S = {
				"<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
				"Workspace Symbols",
			},
		},
		f = {
			name = "Find",
			f = { "<cmd>lua require 'plugins.configs.telescope_ex.finders'.ff()<cr>", "Find File" },
			o = { "<cmd>lua require 'plugins.configs.telescope_ex.finders'.fo()<cr>", "Find Old File" },
			s = { "<cmd>lua require 'plugins.configs.telescope_ex.finders'.fs()<cr>", "Spell" },
			n = { "<cmd>lua require 'plugins.configs.telescope_ex.finders'.fn()<cr>", "Find Word in current buffer" },
			-- j = { "<cmd>lua require 'plugins.configs.telescope_ex.finders'.fj()<cr>", "Find Word under the cursor" },

			-- f = { "<cmd>Telescope find_files previewer=false<cr>", "Find File" },
			-- o = { "<cmd>Telescope oldfiles previewer=false<cr>", "Find Old File" },
			-- s = { "<cmd>Telescope spell_suggest<cr>", "Spell" },
			-- n = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Find Word in current buffer" },
			j = { "<cmd>Telescope grep_string<cr>", "Find Word under the cursor" },
			b = { "<cmd>Telescope buffers<cr>", "Buffers" },
			C = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
			a = { "<cmd>Telescope find_files hidden=true previewer=false<cr>", "Find Hidden File" },
			w = { "<cmd>Telescope live_grep<cr>", "Find Word" },
			M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
			h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
			r = { "<cmd>Telescope registers<cr>", "Registers" },
			k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
			c = { "<cmd>Telescope commands<cr>", "Commands" },
			p = { "<cmd>Telescope projects previewer=false<cr>", "Projects" },
			y = { "<cmd>Telescope neoclip<cr>", "Find Clipboard" },
			-- m = { "<cmd>Telescope media_files<cr>", "Media" },
		},
		T = {
			name = "Treesitter",
			i = { ":TSConfigInfo<cr>", "Info" },
			h = { ":TSHighlightCapturesUnderCursor<cr>", "Highlight" },
			p = { ":TSPlaygroundToggle<cr>", "Playground" },
		},
	},
}

M.setup = function()
	local which_key = require("which-key")

	which_key.setup(leader_key.setup)

	local opts = leader_key.opts

	local mappings = leader_key.mappings

	which_key.register(mappings, opts)
end

return M
