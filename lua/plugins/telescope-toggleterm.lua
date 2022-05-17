require("telescope-toggleterm").setup {
   telescope_mappings = {
      -- <ctrl-c> : kill the terminal buffer (default) .
      ["<C-c>"] = require("telescope-toggleterm").actions.exit_terminal,
   },
}

require("telescope").load_extension "toggleterm"
