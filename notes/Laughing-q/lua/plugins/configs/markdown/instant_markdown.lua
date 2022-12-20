local M = {}

M.setup = function()
	vim.g.instant_markdown_slow = 0
	vim.g.instant_markdown_autostart = 0
	vim.g.instant_markdown_autoscroll = 1
end
return M
