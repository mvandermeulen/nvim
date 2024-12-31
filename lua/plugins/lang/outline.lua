--[[
-- Outline Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-20
--]]


local status_ok, outline = pcall(require, 'outline')
if not status_ok then
  return
end

local icons = require('helpers.ui.icons')
vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle Outline" })

outline.setup({
  outline_window = {
    show_symbol_lineno = true,
    auto_jump = true,
    jump_highlight_duration = 150,
    width = 15,
  },
  outline_items = {
    show_symbol_details = false,
  },
  symbol_folding = {
    autofold_depth = 1,
    auto_unfold_hover = true,
  },
  preview_window = {
    border = "rounded",
  },
  guides = {
    enabled = true,
    markers = {
      bottom = "└",
      middle = "├",
      vertical = "",
      horizontal = "─",
    },
  },
  symbols = {
    icons = {
      Array = { icon = icons.kind.Array, hl = "@constant" },
      Boolean = { icon = icons.kind.Boolean, hl = "@boolean" },
      Class = { icon = icons.kind.Class, hl = "@type" },
      Constant = { icon = icons.kind.Constant, hl = "@constant" },
      Constructor = { icons.kind.Constructor, hl = "@constructor" },
      Enum = { icon = icons.kind.Enum, hl = "@type" },
      EnumMember = { icon = icons.kind.EnumMember, hl = "@field" },
      Event = { icon = icons.kind.Event, hl = "@type" },
      Field = { icon = icons.kind.Field, hl = "@field" },
      File = { icon = icons.kind.File, hl = "@text.uri" },
      Function = { icon = icons.kind.Function, hl = "@function" },
      Interface = { icon = icons.kind.Interface, hl = "@type" },
      Key = { icon = icons.kind.Key, hl = "@type" },
      Method = { icon = icons.kind.Function, hl = "@method" },
      Module = { icon = icons.kind.Module, hl = "@namespace" },
      Namespace = { icon = icons.kind.Namespace, hl = "@namespace" },
      Number = { icon = icons.kind.Number, hl = "@number" },
      Null = { icon = icons.kind.Null, hl = "@type" },
      Object = { icon = icons.kind.Object, hl = "@type" },
      Operator = { icon = icons.kind.Operator, hl = "@operator" },
      Property = { icon = icons.kind.Property, hl = "@method" },
      String = { icon = icons.kind.String, hl = "@string" },
      Struct = { icon = icons.kind.Struct, hl = "@type" },
      TypeParameter = { icon = icons.kind.TypeParameter, hl = "@parameter" },
      Variable = { icon = icons.kind.Variable, hl = "@constant" },
    },
  },
})
