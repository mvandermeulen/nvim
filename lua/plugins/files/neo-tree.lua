--[[
-- Neo-tree Plugin
-- Author: Mark van der Meulen
-- Updated: 2025-10-16
--]]


-- Link: https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      'saifulapm/neotree-file-nesting-config',
    },
    lazy = false,                    -- neo-tree will lazily load itself
    keys = {
      { '<leader>n', '<cmd>Neotree toggle<cr>', desc = 'Explorer' },
    },
    opts = {
      hide_root_node = true,
      retain_hidden_root_indent = true,
      close_if_last_window = true,
      follow_current_file = {
        enabled = true,
      },
      filesystem = {
        use_libuv_file_watcher = true,
        follow_current_file = {
          enabled = true,
        },
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
          show_hidden_count = false,
          never_show = { '^.git$', 'node_modules', '^.cache$', '__pycache__', '^.nvim$', '.is_root_directory', '.DS_Store' },
          -- hide_by_name = {
          --   ".git",
          -- },
          hide_by_name = { '^.git$', 'node_modules', '^.cache$', '__pycache__', '^.nvim$', '.is_root_directory', '.DS_Store' },
        },
        window = {
          mappings = {
            ["o"] = "system_open",
          },
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = '',
          expander_expanded = '',
        },
      },
      commands = {
        system_open = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          -- macOs: open file in default application in the background.
          vim.fn.jobstart({ "open", path }, { detach = true })
          -- Linux: open file in default application
          vim.fn.jobstart({ "xdg-open", path }, { detach = true })
        end,
      },
      window = {
        position = "left",
        width = math.floor(vim.fn.winwidth(0) * 0.18), -- Finding 15% of windows width.
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        mappings = {
          -- ["<space>"] = {
          --   "toggle_node",
          --   nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
          -- },
          ["<2-LeftMouse>"] = "open",
          ["<cr>"] = "open",
          ["<esc>"] = "cancel", -- close preview or floating neo-tree window
          ["P"] = {
            "toggle_preview",
            config = {
              use_float = true,
              use_snacks_image = true,
              use_image_nvim = true,
            },
          },
          -- Read `# Preview Mode` for more information
          ["l"] = "focus_preview",
          -- ["S"] = "open_split",
          ["<C-x>"] = "open_split",
          ["<C-v>"] = "open_vsplit",
          -- ["s"] = "open_vsplit",
          -- ["S"] = "split_with_window_picker",
          -- ["s"] = "vsplit_with_window_picker",
          ["<C-t>"] = "open_tabnew",
          -- ["<cr>"] = "open_drop",
          -- ["t"] = "open_tab_drop",
          ["w"] = "open_with_window_picker",
          --["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
          ["C"] = "close_node",
          -- ['C'] = 'close_all_subnodes',
          ["z"] = "close_all_nodes",
          --["Z"] = "expand_all_nodes",
          --["Z"] = "expand_all_subnodes",
          ["a"] = {
            "add",
            -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
            -- some commands may take optional config options, see `:h neo-tree-mappings` for details
            config = {
              show_path = "none", -- "none", "relative", "absolute"
            },
          },
          ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
          ["d"] = "delete",
          ["r"] = "rename",
          ["b"] = "rename_basename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["Y"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
          ["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
          ["q"] = "close_window",
          ["R"] = "refresh",
          ["?"] = "show_help",
          ["<"] = "prev_source",
          [">"] = "next_source",
          ["i"] = "show_file_details",
          -- ['D'] = "diff_files",
          -- ["i"] = {
          --   "show_file_details",
          --   -- format strings of the timestamps shown for date created and last modified (see `:h os.date()`)
          --   -- both options accept a string or a function that takes in the date in seconds and returns a string to display
          --   -- config = {
          --   --   created_format = "%Y-%m-%d %I:%M %p",
          --   --   modified_format = "relative", -- equivalent to the line below
          --   --   modified_format = function(seconds) return require('neo-tree.utils').relative_date(seconds) end
          --   -- }
          -- },
        },
      },
    },
    config = function(_, opts)
      -- Adding rules from plugin
      opts.nesting_rules = require('neotree-file-nesting-config').nesting_rules
      require('neo-tree').setup(opts)
    end,
    -- config = function()
    --   require('neo-tree').setup({
    --   })
    -- end,
  },
  -- diff_files = function(state)
  --   local node = state.tree:get_node()
  --   local log = require('neo-tree.log')
  --   state.clipboard = state.clipboard or {}
  --   if diff_Node and diff_Node ~= tostring(node.id) then
  --     local current_Diff = node.id
  --     require("neo-tree.utils").open_file(state, diff_Node, open)
  --     vim.cmd("vert diffs " .. current_Diff)
  --     log.info("Diffing " .. diff_Name .. " against " .. node.name)
  --     diff_Node = nil
  --     current_Diff = nil
  --     state.clipboard = {}
  --     require("neo-tree.ui.renderer").redraw(state)
  --   else
  --     local existing = state.clipboard[node.id]
  --     if existing and existing.action == "diff" then
  --       state.clipboard[node.id] = nil
  --       diff_Node = nil
  --       require("neo-tree.ui.renderer").redraw(state)
  --     else
  --       state.clipboard[node.id] = { action = "diff", node = node }
  --       diff_Name = state.clipboard[node.id].node.name
  --       diff_Node = tostring(state.clipboard[node.id].node.id)
  --       log.info("Diff source file " .. diff_Name)
  --       require("neo-tree.ui.renderer").redraw(state)
  --     end
  --   end
  -- end,
}


