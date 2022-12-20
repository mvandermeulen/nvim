local M = {}

local nightfox = require "nightfox"

-- This function set the configuration of nightfox. If a value is not passed in the setup function
-- it will be taken from the default configuration above
function M.setup()
  nightfox.setup {
    transparent = false,
    options = {
      styles = {
        comments = "italic", -- change style of comments to be italic
        keywords = "bold", -- change style of keywords to be bold
        functions = "italic,bold", -- styles can be a comma separated list
        types = "NONE",
      },
      inverse = {
        match_paren = true, -- inverse the highlighting of match_parens
      },
      pallets = {
        red = "#FF000", -- Override the red color for MAX POWER
        bg_alt = "#000000",
      },
      groups = {
        TSPunctDelimiter = { fg = "${red}" }, -- Override a highlight group with the color red
        LspCodeLens = { bg = "#000000", style = "italic" },
      },
    },
  }
  vim.cmd "colorscheme nordfox"
end

return M
