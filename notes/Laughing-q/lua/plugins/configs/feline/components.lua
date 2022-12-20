local M = {}
-- if show short statusline on small screens
local shortline = true
local lsp = require("feline.providers.lsp")
local status_color = "#223249" -- for kanagawa
-- local status_color = "#3d59a1"  -- for tokyonight

M.git = {
	git_branch = {
		provider = "git_branch",
		icon = " 🐯 ",
		hl = {
			-- fg = "gray",
			bg = status_color,
		},
		right_sep = { "block", "slant_right" },
	},

	git_diff_added = {
		provider = "git_diff_added",
		icon = "  ",
		hl = {
			fg = "#45b97c",
		},
	},

	git_diff_changed = {
		provider = "git_diff_changed",
		icon = "  ",
		hl = {
			fg = "#dea32c",
		},
	},
	git_diff_removed = {
		provider = "git_diff_removed",
		icon = "  ",
		hl = {
			fg = "#f15b6c",
		},
	},
}

M.lsp = {
	progress = {
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
	},

	diagnostic_errors = {
		provider = "diagnostic_errors",
		enabled = function()
			return lsp.diagnostics_exist
		end,
		icon = "  ",
		hl = {
			fg = "red",
		},
	},

	diagnostic_warnings = {
		provider = "diagnostic_warnings",
		enabled = function()
			return lsp.diagnostics_exist
		end,
		icon = "  ",
		hl = {
			fg = "#dea32c",
		},
	},

	diagnostic_hints = {
		provider = "diagnostic_hints",
		enabled = function()
			return lsp.diagnostics_exist
		end,
		icon = "  ",
		hl = {
			fg = "#009ad6",
		},
	},

	diagnostic_info = {
		provider = "diagnostic_info",
		enabled = function()
			return lsp.diagnostics_exist
		end,
		icon = "  ",
		hl = {
			fg = "#009ad6",
		},
	},

	client1 = {
		-- provider = 'lsp_client_names',
		provider = function()
			local clients = {}

			for _, client in pairs(vim.lsp.buf_get_clients(0)) do
				clients[#clients + 1] = client.name
			end

			return table.concat(clients, ","), "🦁"
		end,
		enabled = shortline or function(winid)
			return vim.api.nvim_win_get_width(winid) > 70
		end,
		left_sep = "  ",
		-- right_sep = {
		--   str = 'vertical_bar_thin',
		--   hl = {
		--     fg = 'gray',
		--   }
		-- },
		hl = {
			fg = "gray",
		},
	},

	client2 = {
		provider = function()
			if next(vim.lsp.buf_get_clients()) ~= nil then
				return "🦁 LSP "
			else
				return ""
			end
		end,
		enabled = shortline or function(winid)
			return vim.api.nvim_win_get_width(winid) > 70
		end,
		left_sep = " ",
		-- right_sep = {
		--   str = 'vertical_bar_thin',
		--   hl = {
		--     fg = 'gray',
		--   }
		-- },
		hl = {
			fg = "gray",
		},
	},

	client3 = {
		provider = function(msg)
			msg = msg or "LS Inactive"
			local buf_clients = vim.lsp.buf_get_clients()
			local buf_ft = vim.bo.filetype
			local buf_client_names = {}
			if next(buf_clients) == nil then
				if type(msg) == "boolean" or #msg == 0 then
					return "LS Inactive"
				end
				return msg
			end

			-- add client
			for _, client in pairs(buf_clients) do
				if client.name ~= "null-ls" then
					table.insert(buf_client_names, client.name)
				end
			end

			-- add formatter
			local formatters = require("plugins.configs.feline.utils")
			local supported_formatters = formatters.get_formatters(buf_ft)
			local supported_linters = formatters.get_linters(buf_ft)
			vim.list_extend(buf_client_names, supported_formatters)
			vim.list_extend(buf_client_names, supported_linters)

			return table.concat(buf_client_names, ","), "🦁"
		end,
		left_sep = "  ",
		-- right_sep = {
		--   str = 'vertical_bar_thin',
		--   hl = {
		--     fg = 'gray',
		--   }
		-- },
		hl = {
			fg = "gray",
		},
	},
}

M.info = {
	icon1 = {
		provider = " 🐻 ",
		enabled = shortline or function(winid)
			return vim.api.nvim_win_get_width(winid) > 90
		end,
		hl = {
			-- fg = "gray",
			bg = status_color,
		},
		left_sep = "slant_left",
	},

	file_encoding = {
		provider = "file_encoding",
		-- hl = {
		--    fg = "gray",
		-- },
		hl = {
			-- fg = "gray",
			bg = status_color,
		},
		right_sep = "block",
	},
	icon2 = {
		provider = " 🐨",
		enabled = shortline or function(winid)
			return vim.api.nvim_win_get_width(winid) > 90
		end,
		hl = {
			-- fg = "gray",
			bg = status_color,
		},
		left_sep = "slant_left",
	},

	position = {
		provider = "position",
		hl = {
			-- fg = "gray",
			bg = status_color,
		},
	},

	icon3 = {
		provider = "🐼",
		enabled = shortline or function(winid)
			return vim.api.nvim_win_get_width(winid) > 90
		end,
		hl = {
			-- fg = "gray",
			bg = status_color,
		},
	},

	scrollBar = {
		-- static = {
    sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
		-- },
		provider = function(self)
			local curr_line = vim.api.nvim_win_get_cursor(0)[1]
			local lines = vim.api.nvim_buf_line_count(0)
			local i = math.floor(curr_line / lines * (#self.sbar - 1)) + 1
			return string.rep(self.sbar[i], 2)
		end,
		hl = {
			fg = "gray",
			bg = status_color,
		},
	},

	position_percent = {
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
			-- fg = "gray",
			bg = status_color,
		},
	},
}

M.python = {
	provider = function()
		local utils = require("plugins.configs.feline.utils")
		if vim.bo.filetype == "python" then
			local venv = os.getenv("CONDA_DEFAULT_ENV")
			if venv then
				return string.format(" 🍀(%s)", utils.env_cleanup(venv))
			end
			venv = os.getenv("VIRTUAL_ENV")
			if venv then
				return string.format(" 🍀(%s)", utils.env_cleanup(venv))
			end
			return ""
		end
		return ""
	end,

	hl = {
		fg = "green",
	},
}

M.treesitter = {
	provider = function()
		local b = vim.api.nvim_get_current_buf()
		if vim.treesitter.highlighter.active[b] ~= nil then
			return "  "
		end
		return ""
	end,
	hl = {
		fg = "green",
	},
}

return M
