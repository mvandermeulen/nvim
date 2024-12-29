--[[
-- Line Notes Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-21
--]]

local status_ok, line_notes = pcall(require, 'line_notes')
if not status_ok then
  return
end

line_notes.setup({
    -- Customize keymaps
    keymaps = {
        add_note = "an",    -- Add a new note
        list_notes = "ln",  -- Open telescope picker with all notes
        delete_note = "dn", -- Delete note on current line
        show_note = "sn"    -- Show/edit note on current line
    },
    -- Customize note appearance
    signs = {
        note_icon = "🗒️",         -- Icon shown in the sign column
        highlight = "Comment",     -- Highlight group for the icon
        number_highlight = ""      -- Highlight group for line numbers (empty for no highlight)
    }
})
