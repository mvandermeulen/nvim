--[[
-- Avante: Mappings
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-26
--]]

return {
  ask = "<leader>Aa",
  edit = "<leader>Ae",
  refresh = "<leader>Ar",
  diff = {
    ours = "co",
    theirs = "ct",
    both = "cb",
    next = "]x",
    prev = "[x",
  },
  jump = {
    next = "]]",
    prev = "[[",
  },
  submit = {
    normal = "<CR>",
    insert = "<C-s>",
  },
  toggle = {
    debug = "<leader>Ad",
    hint = "<leader>Ah",
  },
}
