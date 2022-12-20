local vi_mode_utils = require("feline.providers.vi_mode")

local force_inactive = {
  filetypes = {
    "^NvimTree$",
    "^packer$",
    "^startify$",
    "^fugitive$",
    "^fugitiveblame$",
    "^qf$",
    "^help$",
  },
  buftypes = {
    "^terminal$",
  },
  bufnames = {},
}

local M = {
  statusline = {
    components = {
      active = {},
      inactive = {},
    },
    force_inactive = force_inactive,
  },
  winbar = {
    components = {
      active = {},
      inactive = {},
    },
    force_inactive = force_inactive,
  },
}

-- Statusline

M.statusline.components.active[1] = {
  {
    provider = "▊ ",
    hl = {
      fg = "skyblue",
    },
  },
  {
    provider = "vi_mode",
    hl = function()
      return {
        name = vi_mode_utils.get_mode_highlight_name(),
        fg = vi_mode_utils.get_mode_color(),
        style = "bold",
      }
    end,
  },
  {
    provider = {
      name = "file_info",
      opts = {
        type = "relative",
      },
    },
    hl = {
      fg = "white",
      bg = "oceanblue",
      style = "bold",
    },
    left_sep = {
      "slant_left_2",
      { str = " ", hl = { bg = "oceanblue", fg = "NONE" } },
    },
    right_sep = {
      { str = " ", hl = { bg = "oceanblue", fg = "NONE" } },
      "slant_right_2",
      " ",
    },
  },
  {
    provider = "file_size",
    left_sep = {
      " ",
    },
    right_sep = {
      " ",
      {
        str = "slant_left_2_thin",
        hl = {
          fg = "fg",
          bg = "bg",
        },
      },
    },
  },
  {
    provider = "position",
    left_sep = " ",
    right_sep = {
      " ",
      {
        str = "slant_right_2_thin",
        hl = {
          fg = "fg",
          bg = "bg",
        },
      },
    },
  },
  {
    provider = "diagnostic_errors",
    hl = { fg = "red" },
  },
  {
    provider = "diagnostic_warnings",
    hl = { fg = "yellow" },
  },
  {
    provider = "diagnostic_hints",
    hl = { fg = "cyan" },
  },
  {
    provider = "diagnostic_info",
    hl = { fg = "skyblue" },
  },
}

M.statusline.components.active[2] = {
  {
    provider = "lsp_client_names",
    hl = {
      fg = "white",
      bg = "black",
      style = "bold",
    },
    right_sep = {
      str = "  ",
      hl = {
        fg = "NONE",
        bg = "black",
      },
    },
  },
  {
    provider = "git_branch",
    hl = {
      fg = "white",
      bg = "black",
      style = "bold",
    },
    right_sep = {
      str = " ",
      hl = {
        fg = "NONE",
        bg = "black",
      },
    },
  },
  {
    provider = "git_diff_added",
    hl = {
      fg = "green",
      bg = "black",
    },
  },
  {
    provider = "git_diff_changed",
    hl = {
      fg = "orange",
      bg = "black",
    },
  },
  {
    provider = "git_diff_removed",
    hl = {
      fg = "red",
      bg = "black",
    },
    right_sep = {
      str = " ",
      hl = {
        fg = "NONE",
        bg = "black",
      },
    },
  },
  {
    provider = "line_percentage",
    hl = {
      style = "bold",
    },
    left_sep = "  ",
    right_sep = " ",
  },
  {
    provider = "scroll_bar",
    hl = {
      fg = "skyblue",
      style = "bold",
    },
  },
}

M.statusline.components.inactive[1] = {
  {
    provider = "file_type",
    hl = {
      fg = "white",
      bg = "oceanblue",
      style = "bold",
    },
    left_sep = {
      str = " ",
      hl = {
        fg = "NONE",
        bg = "oceanblue",
      },
    },
    right_sep = {
      {
        str = " ",
        hl = {
          fg = "NONE",
          bg = "oceanblue",
        },
      },
      "slant_right",
    },
  },
  -- Empty component to fix the highlight till the end of the statusline
  {},
}

-- Winbar

M.winbar.components.active[1] = {
  {
    provider = {
      name = "file_info",
      opts = {
        type = "unique-short",
      },
    },
    hl = {
      fg = "skyblue",
      bg = "NONE",
      style = "bold",
    },
  },
}

M.winbar.components.inactive[1] = {
  {
    provider = {
      name = "file_info",
      opts = {
        type = "unique-short",
      },
    },
    hl = {
      fg = "white",
      bg = "NONE",
      style = "bold",
    },
  },
}

return M
