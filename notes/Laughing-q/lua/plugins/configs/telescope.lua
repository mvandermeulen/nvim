local present, telescope = pcall(require, "telescope")
if not present then
	return
end

local status_ok, actions = pcall(require, "telescope.actions")
if not status_ok then
	return
end
local action_layout = require("telescope.actions.layout")

telescope.setup({
	defaults = {
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
		},
		prompt_prefix = "   ",
		selection_caret = " ",
		entry_prefix = "  ",
		initial_mode = "insert",
		selection_strategy = "reset",
		-- sorting_strategy = "descending",
		sorting_strategy = "ascending",
		layout_strategy = "horizontal",
		layout_config = {
			horizontal = {
				prompt_position = "top",
        mirror = true,
				-- preview_width = 0.5,
				-- results_width = 0.8,
			},
			vertical = {
				prompt_position = "top",
				mirror = false,
			},
			-- center = {
			-- 	prompt_position = "bottom",
			-- 	mirror = false,
			-- },
			-- width = 0.87,
			-- height = 0.80,
			-- preview_cutoff = 120,
		},
		file_sorter = require("telescope.sorters").get_fuzzy_file,
		file_ignore_patterns = { "node_modules" },
		generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
		path_display = { "absolute" },
		winblend = 0,
		border = {},
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		color_devicons = true,
		use_less = true,
		set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
		file_previewer = require("telescope.previewers").vim_buffer_cat.new,
		grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
		qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
		-- Developer configurations: Not meant for general override
		buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
		mappings = {
			i = {
				["<C-k>"] = actions.move_selection_next,
				["<C-i>"] = actions.move_selection_previous,
				["<tab>"] = actions.move_selection_previous,
				["<C-c>"] = actions.close,
				["<C-n>"] = actions.cycle_history_next,
				["<C-p>"] = actions.cycle_history_prev,
				["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        ["<M-l>"] = action_layout.toggle_preview,
			},
			n = {
				["<C-n>"] = actions.move_selection_next,
				["<C-p>"] = actions.move_selection_previous,
				["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        ["<M-l>"] = action_layout.toggle_preview,

				["k"] = actions.move_selection_next,
				["i"] = actions.move_selection_previous,
				-- ["<c-t>"] = trouble.open_with_trouble,
				-- ["<C-i>"] = my_cool_custom_action,
			},
		},
	},
	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			-- the default case_mode is "smart_case"
		},
		media_files = {
			filetypes = { "png", "webp", "jpg", "jpeg" },
			find_cmd = "rg", -- find command (defaults to `fd`)
		},
	},
})

local extensions = { "fzf", "projects", "neoclip" }
-- local packer_repos = [["extensions", "telescope-fzf-native.nvim"]]

-- telescope media_files
-- if vim.fn.executable "ueberzug" == 1 then
--    table.insert(extensions, "media_files")
--    packer_repos = packer_repos .. ', "telescope-media-files.nvim"'
-- end

-- pcall(function()
for _, ext in ipairs(extensions) do
	telescope.load_extension(ext)
end
-- end)
