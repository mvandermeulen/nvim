local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
	return
end

local actions = require("telescope.actions")

telescope.setup({
	pickers = {
		buffers = {
			show_all_buffers = true,
			sort_lastused = true,
			mappings = {
				i = {
					["<c-d>"] = actions.delete_buffer + actions.move_to_top,
				},
			},
		},
	},
	extensions = {
		file_browser = {
			path = "%:p:h",
		},
	},
})

telescope.load_extension("fzf")
telescope.load_extension("notify")
telescope.load_extension("zoxide")
telescope.load_extension("file_browser")

-- Multiple leader keys to for groups of like operations AKA minor modes
--
-- Links:
-- - Using Which Key:
--   - https://github.com/folke/which-key.nvim#%EF%B8%8F-mappings
-- - Inspiration:
--   - https://bluz71.github.io/2021/09/10/vim-tips-revisited.html#multiple-leader-keys--group-similar-actions-with-the-same-prefix
-- - Inspiration with example config:
--   - https://www.reddit.com/r/neovim/comments/sng5jy/comment/hw316x0/?utm_source=reddit&utm_medium=web2x&context=3
--   - https://gist.github.com/JSchrtke/cabd3e42a6920ef1f0835bd7ae286aad
-- - Helix:
--   - https://docs.helix-editor.com/keymap.html

local has_km, km = pcall(require, "key-menu")
if not has_km then
	return
end

km.set("n", "<Space>")

local space = function(keys, desc)
	vim.keymap.set("n", "<Space>" .. keys, function()
		km.open_window("<Space>" .. keys)
	end, { desc = desc })
end

-- Minor mode: TODO Window

-- Minor mode: TODO View

-- Minor mode: Actions
space("a", "Actions")

-- -- TODO Tree-Sitter

-- -- LSP
space("al", "LSP")
vim.keymap.set("n", "<Space>alr", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<Space>alf", "<CMD>lua vim.lsp.buf.format({ async = true })<CR>", { desc = "Format" })
vim.keymap.set("n", "<Space>ala", vim.lsp.buf.code_action, { desc = "Code actions" })
vim.keymap.set("n", "<Space>ald", vim.lsp.codelens.run, { desc = "Code lens / Run" })

-- Minor mode: Goto
space("g", "Goto")

vim.keymap.set("n", "<Space>ga", require("hop").hint_words, { desc = "Hop / Words" })

-- -- LSP
space("gl", "LSP")
vim.keymap.set("n", "<Space>gls", "<CMD>Telescope lsp_document_symbols<CR>", { desc = "Symbols / Document" })
vim.keymap.set("n", "<Space>glS", "<CMD>Telescope lsp_workspace_symbols<CR>", { desc = "Symbols / Workspace" })
vim.keymap.set("n", "<Space>glh", "<CMD>Telescope diagnostics bufnr=0<CR>", { desc = "Diagnostics / Document" })
vim.keymap.set("n", "<Space>glH", "<CMD>Telescope diagnostics<CR>", { desc = "Diagnostics / Workspace" })
vim.keymap.set("n", "<Space>gld", vim.lsp.buf.definition, { desc = "Definition" })
vim.keymap.set("n", "<Space>glD", vim.lsp.buf.declaration, { desc = "Declaration" })
vim.keymap.set("n", "<Space>gli", vim.lsp.buf.implementation, { desc = "Implementation" })
vim.keymap.set("n", "<Space>glt", vim.lsp.buf.type_definition, { desc = "Type definition" })
vim.keymap.set("n", "<Space>glr", vim.lsp.buf.references, { desc = "References" })

-- Minor mode: Show
space("h", "Show")

-- -- Tree
space("ht", "Tree")
vim.keymap.set("n", "<Space>htn", "<CMD>NvimTreeToggle<CR>", { desc = "Toggle" })
vim.keymap.set("n", "<Space>htv", "<CMD>NvimTreeFindFile<CR>", { desc = "Find file" })

-- -- LSP
space("hl", "LSP")
vim.keymap.set("n", "<Space>hlk", vim.lsp.buf.hover, { desc = "Hover" })
vim.keymap.set("n", "<Space>hls", vim.lsp.buf.signature_help, { desc = "Signature help" })
vim.keymap.set("n", "<Space>hle", vim.diagnostic.open_float, { desc = "Diagnostics" })
vim.keymap.set("n", "<Space>hlt", "<CMD>AerialToggle<CR>", { desc = "Outline" })

-- Minor mode: Open
space("o", "Open")
vim.keymap.set("n", "<Space>oa", require("user.a"), { desc = "Alternate file" })
vim.keymap.set("n", "<Space>ot", "<CMD>Telescope tags<CR>", { desc = "Tags" })
vim.keymap.set("n", "<Space>ob", "<CMD>Telescope buffers<CR>", { desc = "Buffers" })
vim.keymap.set("n", "<Space>om", "<CMD>Telescope marks<CR>", { desc = "Marks" })
vim.keymap.set("n", "<Space>of", "<CMD>Telescope file_browser<CR>", { desc = "File browser" })

-- Minor mode: Find
space("f", "Find")
vim.keymap.set("n", "<Space>ff", "<CMD>Telescope find_files<CR>", { desc = "Files" })
vim.keymap.set("n", "<Space>fg", "<CMD>Telescope live_grep<CR>", { desc = "Grep" })

-- Minor mode: TODO Folds

-- Minor mode: Previous
space("p", "Previous")
vim.keymap.set("n", "<Space>pe", vim.diagnostic.goto_prev, { desc = "Error", silent = true })
vim.keymap.set("n", "<Space>pq", "<CMD>cprevious<cr><cr>", { desc = "quickfix item" })
vim.keymap.set("n", "<Space>pc", require("gitsigns.actions").prev_hunk, { desc = "Change" })

-- Minor mode: Next
space("n", "Next")
vim.keymap.set("n", "<Space>ne", vim.diagnostic.goto_next, { desc = "Error", silent = true })
vim.keymap.set("n", "<Space>nq", "<CMD>cnext<cr><cr>", { desc = "quickfix item" })
vim.keymap.set("n", "<Space>nc", require("gitsigns.actions").next_hunk, { desc = "Change" })

-- Minor mode: Run
space("r", "Run")

-- -- Test
space("rt", "Test")
vim.keymap.set("n", "<Space>rty", "<CMD>UltestLast<CR>", { desc = "Last" })
vim.keymap.set("n", "<Space>rtu", "<CMD>UltestNearest<CR>", { desc = "Nearest" })
vim.keymap.set("n", "<Space>rti", "<CMD>Ultest<CR>", { desc = "All" })
vim.keymap.set("n", "<Space>rts", "<CMD>UltestSummary<CR>", { desc = "Summary" })

-- Minor mode: System
space("s", "System")

-- -- File
space("sf", "File")
-- https://vim.fandom.com/wiki/Copy_filename_to_clipboard
vim.keymap.set("n", "<Space>sfs", '<CMD>:let @*=expand("%")<CR>', { desc = "Name" })
vim.keymap.set("n", "<Space>sfl", '<CMD>:let @*=expand("%:p")<CR>', { desc = "Path" })
