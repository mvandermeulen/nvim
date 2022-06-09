--[[
-- Tmux Integration
--
-- Author: Mark van der Meulen
-- Updated: 01-06-2022
--]]

require('tmux').setup {
  copy_sync = {
    enable = false, -- enables copy sync and overwrites all register actions to sync registers *, +, unnamed, and 0 till 9 from tmux in advance
    redirect_to_clipboard = false, -- TMUX >= 3.2: yanks (and deletes) will get redirected to system clipboard by tmux
    register_offset = 0, -- offset controls where register sync starts e.g. offset 2 lets registers 0 and 1 untouched
    sync_clipboard = false, -- sync clipboard overwrites vim.g.clipboard to handle * and + registers. If you sync your system clipboard without tmux, disable this option!
    sync_deletes = false, -- syncs deletes with tmux clipboard as well, it is adviced to do so. Nvim does not allow syncing registers 0 and 1 without overwriting the unnamed register. Thus, ddp would not be possible.
    sync_unnamed = false, -- syncs the unnamed register with the first buffer entry from tmux.
  },
  navigation = {
    cycle_navigation = true, -- cycles to opposite pane while navigating into the border
    enable_default_keybindings = false, -- enables default keybindings (C-hjkl) for normal mode
    persist_zoom = true, -- prevents unzoom tmux when navigating beyond vim border
  },
  resize = {
    enable_default_keybindings = false, -- enables default keybindings (A-hjkl) for normal mode
    resize_step_x = 1, -- sets resize steps for x axis
    resize_step_y = 1, -- sets resize steps for y axis
  },
}

