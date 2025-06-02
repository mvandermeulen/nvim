local M = {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    -- add any options here
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
}

local icons = require('helpers.ui.icons')
function M.config()
  require("noice").setup {
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      message = {
        enabled = true,
        view = "mini",
      },
      hover = {
        enabled = true,
        silent = true,
      },
      signature = {
        enabled = true,
        auto_open = {
          enabled = true,
          trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
          luasnip = false, -- Will open signature help when jumping to Luasnip insert nodes
          throttle = 50, -- Debounce lsp signature help request by 50ms
        },
        view = nil, -- when nil, use defaults from documentation
        -- opts = {}, -- merged with defaults from documentation
      },
    },
    views = {
      hover = {
        border = {
          style = "single",
          padding = { 0, 0 },
        },
        position = { row = 0, col = 0 },
      },
      mini = {
        timeout = 8000, -- Duration between show() and hide(), in milliseconds
        win_options = {
          winblend = 0,
        },
        winhighlight = {},
      },
      cmdline_popup = {
        position = {
          row = 5,
          col = "50%",
        },
        size = {
          width = 60,
          height = "auto",
        },
      },
    },
    cmdline = {
      view = "cmdline",
      format = {
        cmdline = { icon = " " .. icons.arrow.right_short_thick },
        search_down = { icon = " " .. icons.misc.lupa .. " " .. icons.arrow.double_down_short },
        search_up = { icon = " " .. icons.misc.lupa .. " " .. icons.arrow.double_up_short },
        filter = { icon = " " .. icons.misc.filter },
        lua = { icon = " " .. icons.language.lua },
        help = { icon = " " .. icons.misc.fat_question },
      },
    },
    popupmenu = {
      enabled = true,
      relative = 'editor',
      position = {
        row = 8,
        col = "50%",
      },
      size = {
        width = 60,
        height = 10,
      },
      border = {
        style = 'rounded',
        padding = { 0, 1 },
      },
      win_options = {
        winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
      },
    },
    notify = {
      enabled = true,
      view = "notify",
    },
    messages = {
      enabled = true, -- enables the Noice messages UI
      -- view = true, -- default view for messages
      view_error = "mini", -- view for errors
      view_warn = "mini", -- view for warnings
      view_history = "messages", -- view for :messages
      view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
    },
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = false, -- add a border to hover docs and signature help
    },
  }
end

return M
