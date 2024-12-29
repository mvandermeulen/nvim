--[[
-- Mappings: Insert - Modifiers
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-25
--]]


local insert_date = function()
	local date = os.date('%Y-%m-%d') --[[@ as string]]
	vim.api.nvim_feedkeys(date, 'n', false)
end

local insert_time = function()
	local time = os.date('%H:%M:%S') --[[@ as string]]
	vim.api.nvim_feedkeys(time, 'n', false)
end

vim.keymap.set('i', '<C-g>d', insert_date, { desc = 'Insert date' })
vim.keymap.set('i', '<C-g><C-d>', insert_date, { desc = 'Insert date' })
vim.keymap.set('i', '<C-g>t', insert_time, { desc = 'Insert time' })
vim.keymap.set('i', '<C-g><C-t>', insert_time, { desc = 'Insert time' })


-- map({ 'i', 's' }, '<C-l>', function()
-- 	local mode = vim.api.nvim_get_mode().mode
-- 	if mode == 'ix' then -- completion with <C-x>
-- 		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-l>', true, false, true), 'n', false)
-- 	else
-- 		vim.cmd.fclose({ bang = true })
-- 	end
-- end, { silent = true })




