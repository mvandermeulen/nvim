--[[
-- Telescope Configuration
--
-- Author: Mark van der Meulen
-- Updated: 2024-08-22
--]]

local status_ok, telescope = pcall(require, 'telescope')
if not status_ok then
  return
end

local actions = require("telescope.actions")
-- local previewers = require("telescope.previewers")
-- local state = require("telescope.state")
-- local action_set = require("telescope.actions.set")
local action_layout = require("telescope.actions.layout")
-- local actions_layout = require("telescope.actions.layout")
-- local action_state = require("telescope.actions.state")

-- local function flash(prompt_bufnr)
--     if lambda.config.movement.movement_type == "flash" then
--         require("flash").jump({
--             pattern = "^",
--             highlight = { label = { after = { 0, 0 } } },
--             search = {
--                 mode = "search",
--                 exclude = {
--                     function(win)
--                         return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
--                     end,
--                 },
--             },
--             action = function(match)
--                 local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
--                 picker:set_selection(match.pos[1] - 1)
--             end,
--         })
--     else
--         vim.notify(
--             "you have reverted back to leap , but you =did not code this up yet, please insert the codeed version of this search"
--         )
--     end
-- end
local function rectangular_border(opts)
    return vim.tbl_deep_extend("force", opts or {}, {
        borderchars = {
            prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
            results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
            preview = { "▔", "▕", "▁", "▏", "🭽", "🭾", "🭿", "🭼" },
        },
    })
end
function dropdown(opts)
    return require("telescope.themes").get_dropdown(rectangular_border(opts))
end

-- function ivy(opts)
--     return require("telescope.themes").get_ivy(vim.tbl_deep_extend("keep", opts or {}, {
--         borderchars = {
--             preview = { "▔", "▕", "▁", "▏", "🭽", "🭾", "🭿", "🭼" },
--         },
--     }))
-- end
-- local custom_actions = {}

-- function custom_actions.send_to_qflist(prompt_bufnr)
--     require("telescope.actions").send_to_qflist(prompt_bufnr)
--     require("user").qflist.open()
-- end

-- function custom_actions.smart_send_to_qflist(prompt_bufnr)
--     require("telescope.actions").smart_send_to_qflist(prompt_bufnr)
--     require("user").qflist.open()
-- end

-- function custom_actions.fzf_multi_select(prompt_bufnr)
--     local picker = action_state.get_current_picker(prompt_bufnr)
--     local num_selections = table.getn(picker:get_multi_selection())

--     if num_selections > 1 then
--         -- actions.file_edit throws - context of picker seems to change
--         -- actions.file_edit(prompt_bufnr)
--         actions.send_selected_to_qflist(prompt_bufnr)
--         actions.open_qflist()
--     else
--         actions.file_edit(prompt_bufnr)
--     end
-- end

-- Amazing Layout taken from https://github.com/max397574/NeovimConfig/blob/2267d7dfa8a30148516e2f5a6bb0e5ecc5de2c3c/lua/configs/telescope.lua
-- local set_prompt_to_entry_value = function(prompt_bufnr)
--     local entry = action_state.get_selected_entry()
--     if not entry or not type(entry) == "table" then
--         return
--     end
--     action_state.get_current_picker(prompt_bufnr):reset_prompt(entry.ordinal)
-- end

-- local Job = require("plenary.job")
-- local new_maker = function(filepath, bufnr, opts)
--     filepath = vim.fn.expand(filepath)
--     Job:new({
--         command = "file",
--         args = { "--mime-type", "-b", filepath },
--         on_exit = function(j)
--             local mime_class = vim.split(j:result()[1], "/")[1]
--             local mime_type = j:result()[1]
--             if
--                 mime_class == "text"
--                 or (mime_class == "application" and mime_type ~= "application/x-pie-executable")
--             then
--                 previewers.buffer_previewer_maker(filepath, bufnr, opts)
--             else
--                 -- maybe we want to write something to the buffer here
--                 vim.schedule(function()
--                     vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
--                 end)
--             end
--         end,
--     }):sync()
-- end

-- local M = {}
-- M.multi_selection_open_vsplit = function(prompt_bufnr)
--     M._multiopen(prompt_bufnr, "vsplit")
-- end
-- M.multi_selection_open_split = function(prompt_bufnr)
--     M._multiopen(prompt_bufnr, "split")
-- end
-- M.multi_selection_open_tab = function(prompt_bufnr)
--     M._multiopen(prompt_bufnr, "tabe")
-- end
-- M.multi_selection_open = function(prompt_bufnr)
--     M._multiopen(prompt_bufnr, "edit")
-- end


-----------------------------------------------
-- Telescope Setup
-----------------------------------------------
telescope.setup {
  extensions = {
    tele_tabby = {
        use_highlighter = true,
    },
    repo = {
      list = {
        search_dirs = {
          "~/projects",
          "~/resources",
          "~/Documents",
          "~/dots",
          "~/scripts",
          "~/vdm",
          "~/working",
          "~/w",
        },
      },
    },
    heading = {
      treesitter = true,
      picker_opts = {
        layout_config = { width = 0.8, preview_width = 0.5 },
        layout_strategy = 'horizontal',
      },
    },
    git_diffs = {
      enable_preview_diff = true,
    },
    live_grep_args = {
      auto_quoting = true, -- enable/disable auto-quoting
      -- define mappings, e.g.
      -- mappings = { -- extend mappings
      --   i = {
      --     ["<C-k>"] = lga_actions.quote_prompt(),
      --     ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
      --     -- freeze the current list and start a fuzzy search in the frozen list
      --   },
      -- },
      -- ... also accepts theme settings, for example:
      -- theme = "dropdown", -- use dropdown theme
      -- theme = { }, -- use own theme spec
      -- layout_config = { mirror=true }, -- mirror preview pane
    },
  },
  defaults = {
    file_ignore_patterns = {
        "%.jpg",
        "%.jpeg",
        "%.png",
        "%.otf",
        "%.ttf",
        "%.DS_Store",
        "lazy-lock.json",
        "lock.json",
        "^.git/",
        "^examples/",
        "^notes/",
        "^node_modules/",
        "^site-packages/",
        "^abbreviations/",
        "abbreviations/",
        "abbreviations",
    },
    vimgrep_arguments = {
      'rg',
      '--follow',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
    },
    mappings = {
      i = {
        -- Close on first esc instead of gonig to normal mode
        -- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/mappings.lua
        ['<esc>'] = actions.close,
        ['<C-j>'] = actions.move_selection_next,
        ['<PageUp>'] = actions.results_scrolling_up,
        ['<PageDown>'] = actions.results_scrolling_down,
        ['<C-k>'] = actions.move_selection_previous,
        ['<A-q>'] = actions.send_selected_to_qflist,
        ['<C-q>'] = actions.send_to_qflist,
        ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
        ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
        ['<cr>'] = actions.select_default,
        ['<c-v>'] = actions.select_vertical,
        ['<c-s>'] = actions.select_horizontal,
        ['<c-t>'] = actions.select_tab,
        ['<c-p>'] = action_layout.toggle_preview,
        ['<c-o>'] = action_layout.toggle_mirror,
        ['<c-h>'] = actions.which_key,
      },
    },
    path_display = { 'smart' },
    prompt_prefix = '> ',
    selection_caret = ' ',
    entry_prefix = '  ',
    multi_icon = '<>',
    initial_mode = 'insert',
    scroll_strategy = 'cycle',
    selection_strategy = 'reset',
    sorting_strategy = 'descending',
    layout_strategy = 'horizontal',
    layout_config = {
      width = 0.75,
      height = 0.75,
      -- preview_cutoff = 120,
      prompt_position = 'top',
      horizontal = {
        preview_width = function(_, cols, _)
          if cols > 200 then
            return math.floor(cols * 0.4)
          else
            return math.floor(cols * 0.6)
          end
        end,
      },
      vertical = { width = 0.9, height = 0.95, preview_height = 0.5 },
      flex = { horizontal = { preview_width = 0.9 } },
    },
    file_sorter = require('telescope.sorters').get_fzf_sorter,
    generic_sorter = require('telescope.sorters').get_fzf_sorter,
    winblend = 0,
    border = {},
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    color_devicons = true,
    use_less = true,
    set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
    extensions = {
      file_browser = {
        mappings = {
          ["i"] = {},
          ["n"] = {},
        },
      },
      ast_grep = {
        command = {
          "ast-grep",
          "--json=stream",
        }, -- must have --json and -p
        grep_open_files = false, -- search in opened files
        lang = nil, -- string value, specify language for ast-grep `nil` for default
      },
      frecency = {
        default_workspace = "CWD",
        show_unindexed = false, -- Show all files or only those that have been indexed
        ignore_patterns = { "*.git/*", "*/tmp/*", "*node_modules/*", "*vendor/*" },
        workspaces = {
          conf = vim.env.DOTFILES,
          project = vim.env.PROJECTS_DIR,
        },
      },
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      },
      egrepify = {
        prefixes = {
          ["!"] = {
            flag = "invert-match",
          },
        },
      },
    },
    history = {
      path = vim.fn.stdpath("data") .. "/telescope_history.sqlite3",
      -- path = '~/.local/share/nvim/databases/telescope_history.sqlite3',
      limit = 100,
    },
    pickers = {
        buffers = {
            sort_mru = true,
            sort_lastused = true,
            show_all_buffers = true,
            ignore_current_buffer = true,
            previewer = false,
            mappings = {
                i = { ["<c-x>"] = "delete_buffer" },
                n = { ["<c-x>"] = "delete_buffer" },
            },
        },
        oldfiles = dropdown(),
        live_grep = {
            file_ignore_patterns = { ".git/", "%.svg", "%.lock" },
            max_results = 2000,
        },
        current_buffer_fuzzy_find = {
            previewer = false,
            shorten_path = false,
        },
        colorscheme = {
            enable_preview = true,
        },
        find_files = {
            hidden = true,
        },
        keymaps = {
            layout_config = {
                height = 18,
                width = 0.5,
            },
        },
        git_branches = dropdown(),
        git_bcommits = {
            layout_config = {
                horizontal = {
                    preview_width = 0.55,
                },
            },
        },
        git_commits = {
            layout_config = {
                horizontal = {
                    preview_width = 0.55,
                },
            },
        },
        reloader = dropdown(),
    },
  },
}


-----------------------------------------------
-- Load Extensions
-----------------------------------------------
telescope.load_extension('projects')
telescope.load_extension('fzf')
telescope.load_extension('heading')
telescope.load_extension('file_browser')
telescope.load_extension('notify')
telescope.load_extension('vim_bookmarks')
telescope.load_extension('repo')
telescope.load_extension('z')
telescope.load_extension('changes')
telescope.load_extension('ports')
telescope.load_extension('lines')
telescope.load_extension("ui-select")
telescope.load_extension("undo")
telescope.load_extension("ghq")

local gstatus, _ = pcall(require, 'grapple')
if gstatus then
  require("telescope").load_extension("grapple")
end

local bstatus, _ = pcall(require, 'bookmarks')
if bstatus then
  require("telescope").load_extension("bookmarks")
end

local sshstatus, _ = pcall(require, 'remote-sshfs')
if sshstatus then
  require("telescope").load_extension("remote-sshfs")
end

local persisted, _ = pcall(require, 'persisted')
if persisted then
  require("telescope").load_extension("persisted")
end

