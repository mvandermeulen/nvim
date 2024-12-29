--[[
-- Portal Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-23
--]]


local status_ok, portal = pcall(require, 'portal')
if not status_ok then
  return
end


portal.setup({
  -- escape = {
  --   q = true,
  --   ["<ESC>"] = true,
  -- },
  window_options = {
    relative = "editor",
    border = "rounded",
    row = 100,
    col = math.floor(vim.o.columns / 4),
    width = math.floor(vim.o.columns / 2),
    height = 8,
  },
})
