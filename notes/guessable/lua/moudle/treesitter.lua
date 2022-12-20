-- treesitter
require "nvim-treesitter.configs".setup {
  ensure_installed = {"lua", "python", "cpp", "vim", "latex", "yaml"},
  highlight = {
    enable = true,
		use_languagetree = true,
    additional_vim_regex_highlighting = false,
  },
  rainbow = {
    enable = true,
    colors = {
      "#e5c07b",
      "#c678dd",
      "#61afef",
    }
  }
}
