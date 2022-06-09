local present, toggletasks = pcall(require, 'toggletasks')

if not present then
  return
end

toggletasks.setup {
    debug = false,
    silent = false,  -- don't show "info" messages
    short_paths = true,  -- display relative paths when possible
    -- Paths (without extension) to task configuration files (relative to scanned directory)
    -- All supported extensions will be tested, e.g. '.toggletasks.json', '.toggletasks.yaml'
    search_paths = {
        'toggletasks',
        '.toggletasks',
        '.nvim/toggletasks',
    },
    scan = {
        global_cwd = true,  -- vim.fn.getcwd(-1, -1)
        tab_cwd = true,     -- vim.fn.getcwd(-1, tab)
        win_cwd = true,     -- vim.fn.getcwd(win)
        lsp_root = true,    -- root_dir for first LSP available for the buffer
        dirs = { '/Users/vandem/.config/tasks' },          -- explicit list of directories to search
    },
    defaults = {
        close_on_exit = false,
        hidden = true,
    },
    telescope = {
        spawn = {
            open_single = true,  -- auto-open terminal window when spawning a single task
            show_running = false, -- include already running tasks in picker candidates
            -- Replaces default select_* actions to spawn task (and change toggleterm
            -- direction for select horiz/vert/tab)
            mappings = {
                select_float = '<C-f>',
                spawn_smart = '<C-a>',  -- all if no entries selected, else use multi-select
                spawn_all = '<M-a>',    -- all visible entries
                spawn_selected = nil,   -- entries selected via multi-select (default <tab>)
            },
        },
        -- Replaces default select_* actions to open task terminal (and change toggleterm
        -- direction for select horiz/vert/tab)
        select = {
            mappings = {
                select_float = '<C-f>',
                open_smart = '<C-a>',
                open_all = '<M-a>',
                open_selected = nil,
                kill_smart = '<C-q>',
                kill_all = '<C-k>',
                kill_selected = nil,
                respawn_smart = '<C-s>',
                respawn_all = '<C-r>',
                respawn_selected = nil,
            },
        },
    },
}


require('telescope').load_extension('toggletasks')
