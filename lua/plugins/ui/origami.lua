--[[
-- Origami Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-21
--]]


local status_ok, origami = pcall(require, 'origami')
if not status_ok then
  return
end

origami.setup {
  keepFoldsAcrossSessions = true,
  pauseFoldsOnSearch = true,
  setupFoldKeymaps = true,
  -- `h` key opens on first column, not at first non-blank character or before
  hOnlyOpensOnFirstColumn = false,
}
