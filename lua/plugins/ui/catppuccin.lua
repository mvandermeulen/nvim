--[[
-- Catppuccin Colorscheme
-- Updated: 06-06-2022
--]]
local name = 'catppuccin'
local status, catppuccin = pcall(require, name)
if not status then
  vim.notify(string.format('Failed to configure plugin: %s', name))
  return
end

catppuccin.setup {
  transparent_background = false,
  term_colors = true,
  styles = {
    comments = "italic",
    functions = "NONE",
    keywords = "NONE",
    strings = "NONE",
    variables = "NONE",
  },
  integrations = {
    treesitter = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = "italic",
        hints = "italic",
        warnings = "italic",
        information = "italic",
      },
      underlines = {
        errors = "underline",
        hints = "underline",
        warnings = "underline",
        information = "underline",
      },
    },
    lsp_trouble = false,
    cmp = true,
    lsp_saga = false,
    gitgutter = false,
    gitsigns = true,
    telescope = true,
    nvimtree = {
      enabled = true,
      show_root = false,
      transparent_panel = false,
    },
    neotree = {
      enabled = false,
      show_root = false,
      transparent_panel = false,
    },
    which_key = true,
    indent_blankline = {
      enabled = true,
      colored_indent_levels = true,
    },
    dashboard = false,
    neogit = true,
    vim_sneak = false,
    fern = false,
    barbar = false,
    bufferline = true,
    markdown = true,
    lightspeed = true,
    ts_rainbow = false,
    hop = false,
    notify = true,
    telekasten = false,
    symbols_outline = true,
  },
}

-- local c = require("catppuccin.utils.colors").get_colors()
-- local c = require("catppuccin.palettes").get_palette()
-- require("catppuccin.lib.highlighter").syntax({})

-- catppuccin.remap {
--   -- remove italics
--   ErrorMsg = { fg = c.red, style = "bold" },
--   TSProperty = { fg = c.yellow, style = "NONE" },
--   TSInclude = { fg = c.teal, style = "NONE" },
--   TSOperator = { fg = c.sky, style = "bold" },
--   TSKeywordOperator = { fg = c.sky, style = "bold" },
--   TSPunctSpecial = { fg = c.maroon, style = "bold" },
--   TSFloat = { fg = c.peach, style = "bold" },
--   TSNumber = { fg = c.peach, style = "bold" },
--   TSBoolean = { fg = c.peach, style = "bold" },
--   TSConditional = { fg = c.mauve, style = "bold" },
--   TSRepeat = { fg = c.mauve, style = "bold" },
--   TSException = { fg = c.peach, style = "NONE" },
--   TSConstBuiltin = { fg = c.lavender, style = "NONE" },
--   TSFuncBuiltin = { fg = c.peach, style = "NONE" },
--   TSTypeBuiltin = { fg = c.yellow, style = "NONE" },
--   TSVariableBuiltin = { fg = c.teal, style = "NONE" },
--   TSFunction = { fg = c.blue, style = "NONE" },
--   TSParameter = { fg = c.rosewater, style = "NONE" },
--   TSKeywordFunction = { fg = c.maroon, style = "NONE" },
--   TSKeyword = { fg = c.red, style = "NONE" },
--   TSMethod = { fg = c.blue, style = "NONE" },
--   TSNamespace = { fg = c.rosewater, style = "NONE" },
--   TSStringRegex = { fg = c.peach, style = "NONE" },
--   TSVariable = { fg = c.white, style = "NONE" },
--   TSTagAttribute = { fg = c.mauve, style = "NONE" },
--   TSURI = { fg = c.rosewater, style = "underline" },
--   TSLiteral = { fg = c.teal, style = "NONE" },
--   TSEmphasis = { fg = c.maroon, style = "NONE" },
--   TSStringEscape = { fg = c.pink, style = "NONE" },
--   bashTSFuncBuiltin = { fg = c.red, style = "NONE" },
--   bashTSParameter = { fg = c.yellow, style = "NONE" },
--   typescriptTSProperty = { fg = c.lavender, style = "NONE" },
--   cssTSProperty = { fg = c.yellow, style = "NONE" },

--   -- alpha
--   AlphaButton = { fg = c.blue },
--   AlphaButtonShortcut = { fg = c.peach },
--   AlphaCol1 = { fg = c.red },
--   AlphaCol2 = { fg = c.rosewater },
--   AlphaCol3 = { fg = c.yellow },
--   AlphaCol4 = { fg = c.green },
--   AlphaCol5 = { fg = c.sky },
--   AlphaQuote = { fg = c.lavender, style = "italic" },

--   -- scnvim
--   SCNvimEval = { fg = c.black0, bg = c.lavender },

--   -- luasnip
--   LuasnipChoice = { fg = c.peach, style = "italic" },
-- }



-- vim.cmd("colorscheme catppuccin")


