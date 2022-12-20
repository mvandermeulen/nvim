local M = {}
local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
local colors = {
	red = utils.get_highlight("DiagnosticError").fg,
	green = utils.get_highlight("String").fg,
	blue = utils.get_highlight("Function").fg,
	gray = utils.get_highlight("NonText").fg,
	orange = utils.get_highlight("DiagnosticWarn").fg,
	purple = utils.get_highlight("Statement").fg,
	cyan = utils.get_highlight("Special").fg,
	diag = {
		warn = utils.get_highlight("DiagnosticWarn").fg,
		error = utils.get_highlight("DiagnosticError").fg,
		hint = utils.get_highlight("DiagnosticHint").fg,
		info = utils.get_highlight("DiagnosticInfo").fg,
	},
	-- git = {
	-- 	del = utils.get_highlight("diffDeleted").fg,
	-- 	add = utils.get_highlight("diffAdded").fg,
	-- 	change = utils.get_highlight("diffChanged").fg,
	-- },
}

M.Git = {
	condition = conditions.is_git_repo,

	init = function(self)
		self.status_dict = vim.b.gitsigns_status_dict
		self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
	end,

	hl = { fg = "white", bg = "#223249" },

	{ -- git branch name
		provider = function(self)
			return " 🐯" .. self.status_dict.head .. " "
		end,
		-- hl = { style = "bold" },
	},
	-- {
	-- 	condition = function(self)
	-- 		return self.has_changes
	-- 	end,
	-- 	provider = " ",
	-- },
	{
		provider = function(self)
			local count = self.status_dict.added or 0
			return count > 0 and ("  " .. count)
		end,
		hl = { fg = "#45b97c", bg = "#1f2335" },
	},
	{
		provider = function(self)
			local count = self.status_dict.changed or 0
			return count > 0 and ("  " .. count)
		end,
		hl = { fg = "#dea32c", bg = "#1f2335" },
	},
	{
		provider = function(self)
			local count = self.status_dict.removed or 0
			return count > 0 and ("  " .. count)
		end,
		hl = { fg = "#f15b6c", bg = "#1f2335" },
	},
}

M.Python = {
	provider = function()
		local python = require("plugins.configs.feline.utils")
		if vim.bo.filetype == "python" then
			local venv = os.getenv("CONDA_DEFAULT_ENV")
			if venv then
				return string.format(" 🍀(%s)", python.env_cleanup(venv))
			end
			venv = os.getenv("VIRTUAL_ENV")
			if venv then
				return string.format(" 🍀(%s)", python.env_cleanup(venv))
			end
			return ""
		end
		return ""
	end,

	hl = {
		fg = "green",
	},
}

M.Diagnostics = {
	condition = conditions.has_diagnostics,

	init = function(self)
		self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
		self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
		self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
		self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
	end,

	{
		provider = function(self)
			-- 0 is just another output, we can decide to print it or not!
			return self.errors > 0 and (" " .. self.errors .. " ")
		end,
		hl = { fg = colors.diag.error },
	},
	{
		provider = function(self)
			return self.warnings > 0 and (" " .. self.warnings .. " ")
		end,
		hl = { fg = colors.diag.warn },
	},
	{
		provider = function(self)
			return self.info > 0 and (" " .. self.info .. " ")
		end,
		hl = { fg = colors.diag.info },
	},
	{
		provider = function(self)
			return self.hints > 0 and (" " .. self.hints)
		end,
		hl = { fg = colors.diag.hint },
	},
}

M.LSP = {
	-- condition = function ()
	--   return next(vim.lsp.buf_get_clients()) ~= nil
	-- end,
	condition = conditions.lsp_attached,

	{
		provider = function()
			local names = {}
			for _, server in pairs(vim.lsp.buf_get_clients()) do
				table.insert(names, server.name)
			end
			return "🦁" .. table.concat(names, " ") .. ""
		end,
		hl = { fg = "gray" },
	},
}

M.Treesitter = {
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

M.Ruler = {
	-- %l = current line number
	-- %L = number of lines in the buffer
	-- %c = column number
	-- %P = percentage through file of displayed window
	provider = " 🎨%l:%c ",
	hl = { bg = "#223249" },
}

-- I take no credits for this! :lion:
M.ScrollBar = {
	static = {
		sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
	},
	provider = function(self)
		local curr_line = vim.api.nvim_win_get_cursor(0)[1]
		local lines = vim.api.nvim_buf_line_count(0)
		local i = math.floor(curr_line / lines * (#self.sbar - 1)) + 1
		return string.rep(self.sbar[i], 2)
	end,
	hl = { bg = "#223249" },
}
M.Align = { provider = "%=" }
M.Space = { provider = " " }

return M
