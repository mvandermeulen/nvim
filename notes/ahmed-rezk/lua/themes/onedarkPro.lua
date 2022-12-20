local M = {}

function M.setup()
  local onedarkpro = require "onedarkpro"
  onedarkpro.setup {
    theme = function()
      if vim.o.background == "dark" then
        return "onedark"
      else
        return "onelight"
      end
    end,
    colors = {
      onelight = {
        bg = "#f5f5f5", -- green
      },
      --[[ onedark = {
        color_column = "#61afef",
        cursorline = "#61afef",
      }, ]]
    }, -- Override default colors by specifying colors for 'onelight' or 'onedark' themes
    hlgroups = {
      FloatBorder = {
        fg = "#61afef",
      },
      TelescopeBorder = {
        fg = "#61afef",
      },
      VertSplit = {
        fg = "${purple}",
        -- bg = "${red}",
      },
      TSProperty = {
        fg = (vim.o.background == "dark" and "${white}" or "${black}"),
      },
      TSTagAttribute = {
        fg = "${purple}",
      },
      -- LspDiagnosticsDefaultWarning = { fg = "${white}", bg = "${yellow}" },
      --[[ CmpDocumentation = {
        bg = "#61afef",
        fg = "#61afef",
      },
      CmpDocumentationBorder = {
        bg = "#61afef",
        fg = "#61afef",
      }, ]]
    },
    filetype_hlgroups = {}, -- Override default highlight groups for specific filetypes
    plugins = { -- Override which plugins highlight groups are loaded
      all = true,
      native_lsp = true,
      polygot = true,
      treesitter = true,
    },
    styles = {
      comments = "italic",
      keywords = "bold", -- change style of keywords to be bold
      functions = "italic,bold", -- styles can be a comma separated list
      strings = "none",
      variables = "none",
    },
    options = {
      bold = true, -- Use the themes opinionated bold styles?
      italic = true, -- Use the themes opinionated italic styles?
      underline = true, -- Use the themes opinionated underline styles?
      undercurl = true, -- Use the themes opinionated undercurl styles?
      cursorline = true, -- Use cursorline highlighting?
      transparency = false, -- Use a transparent background?
      terminal_colors = true, -- Use the theme's colors for Neovim's :terminal?
      window_unfocussed_color = true, -- When the window is out of focus, change the normal background?
    },
  }
  onedarkpro.load()
end

return M
