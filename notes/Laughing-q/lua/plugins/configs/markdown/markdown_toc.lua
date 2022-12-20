local M = {}

M.setup = function()
	-- move to global
	vim.g.vmt_auto_update_on_save = 1
	vim.g.vmt_dont_insert_fence = 1
	vim.g.vmt_cycle_list_item_markers = 1
	vim.g.vmt_fence_text = "TOC"
	vim.g.vmt_fence_closing_text = "/TOC"
end
return M
