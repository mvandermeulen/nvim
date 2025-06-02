--[[
-- Origami Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]


local status_ok, origami = pcall(require, 'origami')
if not status_ok then
  return
end

origami.setup({
  -- keepFoldsAcrossSessions = true,
  keepFoldsAcrossSessions = package.loaded["ufo"],
  useLspFoldsWithTreesitterFallback = not package.loaded["ufo"],
  pauseFoldsOnSearch = true,
  autoFold = {
    enabled = true,
    kinds = { "comment", "imports" },
  },
  -- `h` key opens on first column, not at first non-blank character or before
  foldKeymaps = {
    setup = false, -- modifies `h` and `l`
    hOnlyOpensOnFirstColumn = false,
  },
})
