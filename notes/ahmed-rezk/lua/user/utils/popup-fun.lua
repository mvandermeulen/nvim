local popup = require("popup")
local M = {}

M.test = function()
	popup.create({ "option 1", "option 2" }, {
		line = "cursor+2",
		col = "cursor+2",
		border = { 1, 1, 1, 1 },
		enter = true,
		cursorline = true,
		callback = function(win_id, sel)
			print(sel)
		end,
	})
end

return M
