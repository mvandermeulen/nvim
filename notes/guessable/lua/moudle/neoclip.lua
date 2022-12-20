-- clipboard manager
require("neoclip").setup(
  {
    history = 1000,
    enable_persistent_history = false,
    continuous_sync = false,
    db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3",
    filter = nil,
    preview = true,
    default_register = '"',
    default_register_macros = "q",
    enable_macro_history = true,
    content_spec_column = false,
    on_paste = {
      set_reg = false
    },
    on_replay = {
      set_reg = false
    },
    keys = {
      telescope = {
        i = {
          paste = "<Leader>pp"
        },
        n = {
          paste = "<leader>pp"
        }
      }
    }
  }
)
