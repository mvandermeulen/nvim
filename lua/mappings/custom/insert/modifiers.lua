--[[
-- Mappings: Insert - Modifiers
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-25
--]]


---------- Helper Functions ----------
local keys = require('helpers.utils.keys')
local edit = require('helpers.user.editing')
local function map(key, action, desc)
  keys:inomap(key, action, desc)
end


--------------------
-- Ctrl Modifier
--------------------

map('<C-g>d', edit.insert_date, 'Insert date')
map('<C-g><C-d>', edit.insert_date, 'Insert date')
map('<C-g>t', edit.insert_time, 'Insert time')
map('<C-g><C-t>', edit.insert_time, 'Insert time')
map('<C-c>', '<Esc>', 'Exit Insert Mode')
map("<C-U>", "<Esc>viwUi", 'Uppercase Word')
map("<C-a>", function() edit.insert_todo_and_comment() end, 'Insert TODO Comment')
map("<C-x>", function() edit.add_project_from_line(vim.fn.getline('.')) end, 'Add Project from Line')
-- map("i", "<C-L>", "<CMD>lua EscapePair()<CR>", kmo())

--------------------
-- Meta Modifier
--------------------
map("<M-f>", function() edit.insert_file_path() end, 'Insert File Path')

-- map("", function()  end, '')
-- vim.api.nvim_set_keymap("i", "<C-CR>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
