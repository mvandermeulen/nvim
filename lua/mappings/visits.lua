--[[
-- Mappings: Visits
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

return {
  { "<leader>va", function() require("mini.visits").add_label() end, desc = "Add label" },
  { "<leader>vr", function() require("mini.visits").remove_label() end, desc = "Remove label" },
  { "<leader>vs", function() require("mini.visits").select_label("", nil) end, desc = "Select label (cwd)", },
  { "<leader>vS", function() require("mini.visits").select_label("", "") end, desc = "Select label (all)", },
  { "<leader>vv", function() require("mini.visits").select_path(vim.uv.cwd()) end, desc = "Visited path (cwd)", },
  { "<leader>vV", function() require("mini.visits").select_path("") end, desc = "Visited path (all)", },
  { "<leader>vp", function() require("mini.visits").list_paths() end, desc = "List Paths", },
  { "<leader>vl", function() require("mini.visits").list_labels() end, desc = "List Labels", },
  { "]v", function() require("mini.visits").iterate_paths("forward") end, desc = "Next visited path", },
  { "[v", function() require("mini.visits").iterate_paths("backward") end, desc = "Previous visited path", },
  { "]V", function() require("mini.visits").iterate_paths("last") end, desc = "Last visited path", },
  { "[V", function() require("mini.visits").iterate_paths("first") end, desc = "First visited path", },
}
