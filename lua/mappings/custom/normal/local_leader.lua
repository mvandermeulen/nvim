--[[
-- Mappings: Normal - Local Leader
--
-- Author: Mark van der Meulen
-- Updated: 2025-07-15
--]]

---------- Helper Functions ----------
local keys = require('helpers.utils.keys')
local function map(key, action, desc)
  keys:nllmap(key, action, desc)
  -- if type(action) == 'function' then
  -- end
end


---------- Toggle Paste ----------
----- <localleader>p
----- Mappings: o, p
map("pp", "<CMD>:set paste<CR>", '[Paste] ON')
map("po", "<CMD>:set nopaste<CR>", '[Paste] OFF')

---------- Tab Mappings ----------
----- <localleader>[1-9]
map("1", function() require("helpers.user.tools").tabnm(1) end, 'Tab 1')
map("2", function() require("helpers.user.tools").tabnm(2) end, 'Tab 2')
map("3", function() require("helpers.user.tools").tabnm(3) end, 'Tab 3')
map("4", function() require("helpers.user.tools").tabnm(4) end, 'Tab 4')
map("5", function() require("helpers.user.tools").tabnm(5) end, 'Tab 5')
map("6", function() require("helpers.user.tools").tabnm(6) end, 'Tab 6')
map("7", function() require("helpers.user.tools").tabnm(7) end, 'Tab 7')
map("8", function() require("helpers.user.tools").tabnm(8) end, 'Tab 8')
map("9", function() require("helpers.user.tools").tabnm(9) end, 'Tab 9')
----- <localleader>t
----- Mappings: 1-9, r
map("t1", function() require("helpers.user.tools").tabnm(10) end, 'Goto Tab 10')
map("t2", function() require("helpers.user.tools").tabnm(11) end, 'Goto Tab 11')
map("t3", function() require("helpers.user.tools").tabnm(12) end, 'Goto Tab 12')
map("t4", function() require("helpers.user.tools").tabnm(13) end, 'Goto Tab 13')
map("t5", function() require("helpers.user.tools").tabnm(14) end, 'Goto Tab 14')
map("t6", function() require("helpers.user.tools").tabnm(15) end, 'Goto Tab 15')
map("t7", function() require("helpers.user.tools").tabnm(16) end, 'Goto Tab 16')
map("t8", function() require("helpers.user.tools").tabnm(17) end, 'Goto Tab 17')
map("t9", function() require("helpers.user.tools").tabnm(18) end, 'Goto Tab 18')
map("tr", "<cmd>BufferLineTabRename<CR>", 'Rename Tab')


---------- Custom FZF ----------
----- <localleader>f
----- Mappings: a, e, f, g, l, m, p, P, r
map("fa", function() require("helpers.plugins.fzf").my_files_alt() end, 'Alt Files')
map("fe", function() require("helpers.plugins.fzf").edit_nvim() end, 'Edit Nvim')
map("ff", function() require("helpers.plugins.fzf").rg_files() end, 'Files')
map("fg", function() require("helpers.plugins.fzf").fzf_grep() end, 'FZF Grep')
map("fl", function() require("helpers.plugins.fzf").live_grep() end, 'Live Grep')
map("fm", function() require("helpers.plugins.fzf").my_files() end, 'My Files')
map("fp", function() require("helpers.plugins.fzf").select_project_find_file() end, 'Project: Files')
map("fP", function() require("helpers.plugins.fzf").select_project_fzf_grep() end, 'Project: Grep')
map("fr", function() require("helpers.plugins.fzf").lsp_references() end, 'LSP References')
map("fx", function() require("helpers.plugins.fzf").my_file_ext(true, nil) end, 'Current Filetype')

