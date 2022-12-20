-- Initialize the components table
local component = require("plugins.configs.feline.components")

local components = {
	active = {},
	inactive = {},
}

local left = {}
local middle = {}
local right = {}

-- Initialize left, mid and right
table.insert(components.active, {})
table.insert(components.active, {})
table.insert(components.active, {})

-- left
table.insert(left, component.git.git_branch)
table.insert(left, component.python)
table.insert(left, component.git.git_diff_added)
table.insert(left, component.git.git_diff_changed)
table.insert(left, component.git.git_diff_removed)

-- middle
table.insert(middle, component.lsp.progress)

-- right
table.insert(right, component.lsp.diagnostic_errors)
table.insert(right, component.lsp.diagnostic_warnings)
table.insert(right, component.lsp.diagnostic_hints)
table.insert(right, component.lsp.diagnostic_info)
table.insert(right, component.lsp.client3)
table.insert(right, component.treesitter)
table.insert(right, component.info.icon2)
table.insert(right, component.info.position)
-- table.insert(right, component.info.icon3)
-- table.insert(right, component.info.position_percent)
-- table.insert(right, component.info.scrollBar)

components.active[1] = left
components.active[2] = middle
components.active[3] = right

require("feline").setup({
	colors = {
		bg = "#1f2335",
	},
	components = components,
})
