return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  -- Optional dependencies
  -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
  dependencies = { 'nvim-tree/nvim-web-devicons' }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
  config = function()
    require('oil').setup {
      -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
      -- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
      default_file_explorer = true,
      -- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
      delete_to_trash = true,
      -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        -- Sort file names with numbers in a more intuitive order for humans.
        -- Can be "fast", true, or false. "fast" will turn it off for large directories.
        natural_order = true,
        -- This function defines what will never be shown, even when `show_hidden` is set
        is_always_hidden = function(name, _)
          return name == '..' or name == '.git'
        end,
      },
      float = {
        padding = 2,
        max_width = 90,
        max_height = 0,
      },
      win_options = {
        wrap = true,
        winblend = 0,
      },
      keymaps = {
        ['<C-c>'] = false,
        ['q'] = 'actions.close',
        -- ['<CR>'] = 'actions.select',
        ['<S-l>'] = 'actions.select',
        ['<S-h>'] = { 'actions.parent', mode = 'n' },
      },
    }
    -- https://github.com/stevearc/oil.nvim/issues/384#issuecomment-2210882925
    vim.api.nvim_create_user_command('OilToggle', function()
      vim.cmd((vim.bo.filetype == 'oil') and 'bd' or 'Oil')
    end, { nargs = 0 })
  end,
}
