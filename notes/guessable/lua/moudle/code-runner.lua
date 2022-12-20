-- jaq
require("jaq-nvim").setup {
  cmds = {
    -- Default UI used (see `Usage` for options)
    default = "term", -- term ,toggleterm, float
    -- Uses external commands such as 'g++' and 'cargo'
    external = {
      python = "python3 %",
      cpp = "g++ % -o $fileBase && ./$fileBase",
      tex = "xelatex %",
      sh = "sh %"
    },
    -- Uses internal commands such as 'source' and 'luafile'
    internal = {
      lua = "luafile %",
      vim = "source %"
    }
  },
  ui = {
    startinsert = false,
    wincmd = false,
    float = {
      -- Floating window border (see ':h nvim_open_win')
      border = "double",
      -- Num from `0 - 1` for measurements
      height = 0.8,
      width = 0.8,
      x = 0.5,
      y = 0.5,
      -- Highlight group for floating window/border (see ':h winhl')
      border_hl = "FloatBorder",
      float_hl = "Normal",
      -- Floating Window Transparency (see ':h winblend')
      blend = 0
    },
    terminal = {
      -- Position of terminal
      position = "bot",
      -- Open the terminal without line numbers
      line_no = false,
      -- Size of terminal
      size = 10
    }
  }
}
vim.api.nvim_set_keymap("n", "<Leader>r", ":Jaq terminal<CR>", {noremap = true, silent = true})
