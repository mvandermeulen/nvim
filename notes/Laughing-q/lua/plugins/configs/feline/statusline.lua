local lsp = require("feline.providers.lsp")

-- if show short statusline on small screens
local shortline = true

-- Initialize the components table
local components = {
	active = {},
	inactive = {},
}

-- Initialize left, mid and right
table.insert(components.active, {})
table.insert(components.active, {})
table.insert(components.active, {})

components.active[1][1] = {
	provider = "git_branch",
	icon = " 🎨 ",
	hl = {
		-- fg = "gray",
		bg = "#3d59a1",
	},
	right_sep = "slant_right",
}

components.active[1][2] = {
	provider = "git_diff_added",
	icon = "  ",
	hl = {
		fg = "#45b97c",
	},
}
-- diffModfified
components.active[1][3] = {
	provider = "git_diff_changed",
	icon = "  ",
	hl = {
		fg = "#dea32c",
	},
}
-- diffRemove
components.active[1][4] = {
	provider = "git_diff_removed",
	icon = "  ",
	hl = {
		fg = "#f15b6c",
	},
}

components.active[2][1] = {
	provider = function()
		local Lsp = vim.lsp.util.get_progress_messages()[1]
		if Lsp then
			local msg = Lsp.message or ""
			local percentage = Lsp.percentage or 0
			local title = Lsp.title or ""
			local spinners = {
				"",
				"",
				"",
			}

			local success_icon = {
				"",
				"",
				"",
			}

			local ms = vim.loop.hrtime() / 1000000
			local frame = math.floor(ms / 120) % #spinners

			if percentage >= 70 then
				return string.format(" %%<%s %s %s (%s%%%%) ", success_icon[frame + 1], title, msg, percentage)
			else
				return string.format(" %%<%s %s %s (%s%%%%) ", spinners[frame + 1], title, msg, percentage)
			end
		end
		return ""
	end,
	enabled = shortline or function(winid)
		return vim.api.nvim_win_get_width(winid) > 80
	end,
	hl = { fg = "green" },
}

components.active[3][1] = {
	provider = "diagnostic_errors",
	enabled = function()
		return lsp.diagnostics_exist("Error")
	end,
	icon = "  ",
	hl = {
		fg = "red",
	},
}

components.active[3][2] = {
	provider = "diagnostic_warnings",
	enabled = function()
		return lsp.diagnostics_exist("Warning")
	end,
	icon = "  ",
	hl = {
		fg = "#dea32c",
	},
}

components.active[3][3] = {
	provider = "diagnostic_hints",
	enabled = function()
		return lsp.diagnostics_exist("Hint")
	end,
	icon = "  ",
	hl = {
		fg = "#009ad6",
	},
}

components.active[3][4] = {
	provider = "diagnostic_info",
	enabled = function()
		return lsp.diagnostics_exist("Information")
	end,
	icon = "  ",
	hl = {
		fg = "#009ad6",
	},
}

components.active[3][5] = {
	provider = function()
		if next(vim.lsp.buf_get_clients()) ~= nil then
			return " LSP"
		else
			return ""
		end
	end,
	-- provider = 'lsp_client_names',
	enabled = shortline or function(winid)
		return vim.api.nvim_win_get_width(winid) > 70
	end,
	left_sep = " ",
	right_sep = " ",
	hl = {
		fg = "gray",
	},
}

components.active[3][6] = {
	provider = "",
	enabled = shortline or function(winid)
		return vim.api.nvim_win_get_width(winid) > 90
	end,
	hl = {
		fg = "#89ddff",
		-- bg = "#3d59a1"
	},
}

components.active[3][7] = {
	provider = "✏️  ",
	enabled = shortline or function(winid)
		return vim.api.nvim_win_get_width(winid) > 90
	end,
	hl = {
		fg = "black",
		bg = "#89ddff",
	},
}

components.active[3][8] = {
	provider = "file_encoding",
	hl = {
		fg = "#89ddff",
		bg = "#3d59a1",
	},
	left_sep = "block",
	-- left_sep = {'left_filled', 'block'},
}

components.active[3][9] = {
	provider = "position",
	hl = {
		fg = "#89ddff",
		bg = "#3d59a1",
	},
	left_sep = "block",
	right_sep = "block",
	-- right_sep = {
	--       {
	--         str = 'left',
	--         hl = {
	--           fg = '#89ddff',
	--           bg = '#3d59a1'
	--         }
	--       },
	--     }
}

components.active[3][10] = {
	provider = "",
	enabled = shortline or function(winid)
		return vim.api.nvim_win_get_width(winid) > 90
	end,
	hl = {
		fg = "#89ddff",
		bg = "#3d59a1",
	},
}

components.active[3][11] = {
	-- provider = "🎨 ",
	provider = "📝 ",
	enabled = shortline or function(winid)
		return vim.api.nvim_win_get_width(winid) > 90
	end,
	hl = {
		fg = "black",
		bg = "#89ddff",
	},
}

components.active[3][12] = {
	provider = function()
		local current_line = vim.fn.line(".")
		local total_line = vim.fn.line("$")

		if current_line == 1 then
			return " Top "
		elseif current_line == vim.fn.line("$") then
			return " Bot "
		end
		local result, _ = math.modf((current_line / total_line) * 100)
		return " " .. result .. "%% "
	end,

	enabled = shortline or function(winid)
		return vim.api.nvim_win_get_width(winid) > 90
	end,

	hl = {
		fg = "#89ddff",
		bg = "#3d59a1",
	},
}

-- components.active[3][12] = {
--    provider = 'line_percentage',
--    hl = {
--       fg = "#89ddff",
--       bg = "#3d59a1"
--    },
--    left_sep = 'block',
--    right_sep = 'block',
--    -- left_sep = {
--    --       {
--    --         str = 'left',
--    --         hl = {
--    --           fg = '#89ddff',
--    --           bg = '#3d59a1'
--    --         },
--    --       },
--    --       'block',
--    --     }
-- }

require("feline").setup({
	colors = {
		bg = "#1f2335",
	},
	components = components,
})

-- vertical_bar_thin	'│'
-- left	''
-- right	''
-- block	'█'
-- left_filled	''
-- right_filled	''
-- slant_left	''
-- slant_left_thin	''
-- slant_right	''
-- slant_right_thin	''
-- slant_left_2	''
-- slant_left_2_thin	''
-- slant_right_2	''
-- slant_right_2_thin	''
-- left_rounded	''
-- left_rounded_thin	''
-- right_rounded	''
-- right_rounded_thin	''
-- circle	'●'
