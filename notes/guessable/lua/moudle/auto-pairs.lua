-- auto-pairs
require("nvim-autopairs").setup(
  {
    disable_filetype = {"TelescopePrompt", "vim"}
  }
)
local Rule = require("nvim-autopairs.rule")
local npairs = require("nvim-autopairs")
npairs.add_rule(Rule("$", "$", "tex"))
