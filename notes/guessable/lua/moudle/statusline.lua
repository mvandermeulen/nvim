-- lualine
local colors = {
  blue = "#61afef",
  red = "#e86671",
  cyan = "#56b6c2",
  black = "#282c34",
  white = "#c6c6c6",
  purple = "#c678dd",
  orange = "#d19a66",
  grey = "#303050",
  green = "#98c379",
	yellow = "#e5c07b",
  darkblue = "#081633",
  darkSlateGray = "#2F4F4F"
}

local tri_theme = {
  normal = {
    a = {fg = colors.black, bg = colors.orange},
    b = {fg = colors.white, bg = colors.grey},
    c = {fg = colors.black, bg = colors.black},
    z = {fg = colors.white, bg = colors.black}
  },
  insert = {
    a = {fg = colors.black, bg = colors.orange},
    b = {fg = colors.white, bg = colors.grey},
    c = {fg = colors.black, bg = colors.black},
    z = {fg = colors.white, bg = colors.black}
  },
  visual = {
    a = {fg = colors.black, bg = colors.orange},
    b = {fg = colors.white, bg = colors.grey},
    c = {fg = colors.black, bg = colors.black},
    z = {fg = colors.white, bg = colors.black}
  },
  replace = {
    a = {fg = colors.black, bg = colors.orange},
    b = {fg = colors.white, bg = colors.grey},
    c = {fg = colors.black, bg = colors.black},
    z = {fg = colors.white, bg = colors.black}
  },
  command = {
    a = {fg = colors.black, bg = colors.orange},
    b = {fg = colors.white, bg = colors.grey},
    c = {fg = colors.black, bg = colors.black},
    z = {fg = colors.white, bg = colors.black}
  },
  terminal = {
    a = {fg = colors.black, bg = colors.orange},
    b = {fg = colors.white, bg = colors.grey},
    c = {fg = colors.black, bg = colors.black},
    z = {fg = colors.white, bg = colors.black}
  },
  inactive = {
    a = {fg = colors.black, bg = colors.darkSlateGray},
    z = {fg = colors.white, bg = colors.darkSlateGray}
  }
}

local function a_icon()
  return " "
end

local function x_icon()
  return "➗"
end

local function y_icon()
  return " "
end

local function z_icon()
  return " "
end

local function infinity()
  return " "
end

local function dir_name()
  local dir_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  return "  " .. dir_name .. " "
end

require("lualine").setup {
  options = {
    theme = tri_theme,
    component_separators = {left = "", right = ""},
    section_separators = {left = "", right = ""},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {
      {a_icon, padding = {left = 1, right = 0}, separator = {left = "", right = " "}}
    },
    lualine_b = {
      {dir_name, padding = 0, separator = {left = "", right = " "}, color = {fg = colors.cyan, gui = "bold"}}
    },
    lualine_c = {
      {"branch", icon = "", padding = 0, color = {fg = colors.purple}, separator = {left = "", right = " "}},
      {"diagnostics", sources = {"nvim_lsp"}, symbols = {error = " ", warn = " ", info = " "}}
    },
    lualine_x = {
      {"location", color = {fg = colors.darkSlateGray}}
    },
    lualine_y = {
      {infinity, padding = 0, separator = {left = "", right = ""}, color = {fg = colors.black, bg = colors.red}},
      {"mode", color = {fg = colors.red, bg = colors.black}}
    },
    lualine_z = {
      {z_icon, padding = 0, separator = {left = "", right = ""}, color = {fg = colors.black, bg = colors.green}},
      {"progress", padding = {left = 0, right = 1}, color = {fg = colors.green}}
    }
  },
  inactive_sections = {
    lualine_a = {
      {x_icon, padding = {left = 0, right = 0}, separator = {left = "", right = ""}, color = {fg = colors.darkblue}}
    },
    lualine_z = {
      {"filename", separator = {left = "", right = ""}, color = {fg = colors.darkblue}}
    }
  }
}
