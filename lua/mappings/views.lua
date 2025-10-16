--[[
-- Mappings: Views
-- Author: Mark van der Meulen
-- Updated: 2025-10-16
--]]

return {
  -- { '<leader>va', function()  end, desc = '' },
  { '<leader>ve', '<cmd>Neotree toggle<cr>', desc = ' Explorer' },
  -- { '<leader>vd', function()  end, desc = ' Diffview' },
  { '<leader>vc', '<cmd>Cheatsheet<cr>', desc = '󰦾 Cheatsheet' },
  { '<leader>vm', '<cmd>Mason<cr>', desc = '󰆦 Mason' },
  { '<leader>vs', '<cmd>FzfLua<cr>', desc = ' Search' },
  { '<leader>vS', function() require("spectre").toggle() end, desc = 'Spectre' },
  { '<leader>vT', '<cmd>Telescope<cr>', desc = ' Telescope' },
  { '<leader>vg',  '<CMD>lua _GITUI_TOGGLE()<CR>i', desc = ' GitUI' },
  -- { '<leader>vG', function()  end, desc = ' LazyGit' },
  { '<leader>vy',  '<ESC><CMD>YankBank<CR>', desc = ' YankBank' },
  { "<leader>vva", function() require("mini.visits").add_label() end, desc = "Add label" },
  { "<leader>vvr", function() require("mini.visits").remove_label() end, desc = "Remove label" },
  { "<leader>vvs", function() require("mini.visits").select_label("", nil) end, desc = "Select label (cwd)", },
  { "<leader>vvS", function() require("mini.visits").select_label("", "") end, desc = " Select label (all)", },
  { "<leader>vvv", function() require("mini.visits").select_path(vim.uv.cwd()) end, desc = " Visited path (cwd)", },
  { "<leader>vvV", function() require("mini.visits").select_path("") end, desc = " Visited path (all)", },
  { "<leader>vvp", function() require("mini.visits").list_paths() end, desc = " List Paths", },
  { "<leader>vvl", function() require("mini.visits").list_labels() end, desc = " List Labels", },
  { "]v", function() require("mini.visits").iterate_paths("forward") end, desc = " Next visited path", },
  { "[v", function() require("mini.visits").iterate_paths("backward") end, desc = " Previous visited path", },
  { "]V", function() require("mini.visits").iterate_paths("last") end, desc = " Last visited path", },
  { "[V", function() require("mini.visits").iterate_paths("first") end, desc = " First visited path", },
}
