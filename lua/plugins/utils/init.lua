--[[
-- Plugins: Utils
-- Author: Mark van der Meulen
-- Updated: 2024-09-21
--]]

local helper_icons = require('helpers.ui.icons')

local M = {
  {-- nvim-terminal.lua
    'norcalli/nvim-terminal.lua',
    lazy = false,
    priority = 1000,
    concurrency = 2,
    config = function()
      require('terminal').setup()
    end,
  },
  {-- sqlite.lua
    'tami5/sqlite.lua',
    name = 'sqlite',
    lazy = false,
    priority = 1000,
  },
  {-- mini.nvim
    'echasnovski/mini.nvim',
    version = '*',
    config = function()
      require('plugins.utils.mini')
    end,
  },
  {-- sudormrfbin/cheatsheet.nvim
    'sudormrfbin/cheatsheet.nvim',
    config = function()
      require('plugins.utils.cheatsheet')
    end,
  },
  {-- chrisgrieser/nvim-scissors
    "chrisgrieser/nvim-scissors",
    dependencies = { "nvim-telescope/telescope.nvim", "L3MON4D3/LuaSnip" },
    config = function()
      require('plugins.utils.scissors')
    end,
    opts = {
      snippetDir = os.getenv("HOME") .. "/.config/nvim/snippets/vsc",
    },
  },
  {-- Registers
    'tversteeg/registers.nvim',
    lazy = false,
    config = function()
      require('plugins.utils.registers')
    end,
    name = "registers",
  },
  {-- neoclip
    'AckslD/nvim-neoclip.lua',
    lazy = false,
    dependencies = { { 'tami5/sqlite.lua' }, { 'nvim-telescope/telescope.nvim' } },
    config = function()
      require('plugins.utils.neoclip')
    end,
    name = "neoclip",
  },
  {-- Yankbank
    "ptdewey/yankbank-nvim",
    dependencies = "kkharji/sqlite.lua",
    config = function()
        require('yankbank').setup({
            persist_type = "sqlite",
        })
    end,
  },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  {-- LudoPinelli/comment-box.nvim
    'LudoPinelli/comment-box.nvim',
    lazy = false,
    config = function()
      require('plugins.utils.comment-box')
    end,
  },
  -- { 'famiu/bufdelete.nvim', lazy = false },
  -- {-- asmorris/line_notes.nvim
  --   'asmorris/line_notes.nvim',
  --   dependencies = { "nvim-telescope/telescope.nvim" },
  --   lazy = false,
  --   config = function()
  --     require('plugins.utils.line_notes')
  --   end,
  -- },
  {-- folke/which-key.nvim
    'folke/which-key.nvim',
    event = "VeryLazy",
    opts = {
      icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "", -- symbol prepended to a group
        rules = {
          -- Verbs
          { pattern = "insert", icon = " ", color = "cyan" },
          { pattern = "create", icon = " ", color = "purple" },
          { pattern = "new", icon = " ", color = "purple" },
          { pattern = "run", icon = " ", color = "green" },
          { pattern = "launch", icon = " ", color = "green" },
          { pattern = "close", icon = helper_icons.ui.Close, color = "red" },
          { pattern = "stop", icon = " ", color = "red" },
          { pattern = "reset", icon = " ", color = "grey" },
          { pattern = "restore", icon = " ", color = "grey" },
          { pattern = "reload", icon = " ", color = "grey" },
          { pattern = "open", icon = " ", color = "green" },
          { pattern = "delete", icon = " ", color = "blue" },
          { pattern = "top", icon = " ", color = "grey" },
          { pattern = "up", icon = " ", color = "grey" },
          { pattern = "bottom", icon = " ", color = "grey" },
          { pattern = "down", icon = " ", color = "grey" },
          { pattern = "left", icon = " ", color = "grey" },
          { pattern = "right", icon = " ", color = "grey" },
          { pattern = "switch", icon = " ", color = "grey" },
          { pattern = "move", icon = " ", color = "grey" },
          { pattern = "Pin", icon = helper_icons.ui.Pin, color = "red" },
          { pattern = "Sort", icon = helper_icons.misc.sort, color = "grey" },
          -- Nouns
          { pattern = "fold", icon = " ", color = "azure" },
          { pattern = "color", icon = " ", color = "red" },
          { pattern = "highlight", icon = " ", color = "red" },
          { pattern = "tree", icon = " ", color = "green" },
          { pattern = "mark", icon = " ", color = "yellow" },
          { pattern = "task", icon = " ", color = "green" },
          { pattern = "help", icon = " ", color = "cyan" },
          { pattern = "info", icon = " ", color = "cyan" },
          { pattern = "blame", icon = " ", color = "cyan" },
          { pattern = "program", icon = " ", color = "azure" },
          { pattern = "plugin", icon = " ", color = "azure" },
          { pattern = "package", icon = " ", color = "yellow" },
          { pattern = "lsp", icon = " ", color = "red" },
          { pattern = "test", icon = " ", color = "yellow" },
          { pattern = "manage", icon = " ", color = "orange" },
          { pattern = "outline", icon = " ", color = "purple" },
          { pattern = "symbol", icon = " ", color = "orange" },
          { pattern = "annotation", icon = " ", color = "grey" },
          { pattern = "comment", icon = " ", color = "grey" },
          { pattern = "term", icon = " ", color = "cyan" },
          { pattern = "grep", icon = " ", color = "orange" },
          { pattern = "quickfix", icon = " ", color = "yellow" },
          { pattern = "list", icon = " ", color = "yellow" },
          { pattern = "workspace", icon = " ", color = "yellow" },
          { pattern = "regex", icon = " ", color = "yellow" },
          -- Override default
          { plugin = "nvim-spectre", icon = " ", color = "blue" },
          { pattern = "file", icon = " ", color = "cyan" },
          { pattern = "debug", icon = " ", color = "red" },
          { pattern = "find", icon = " ", color = "green" },
          { pattern = "search", icon = " ", color = "green" },
          { pattern = "session", icon = " ", color = "azure" },
          { pattern = "format", icon = " ", color = "cyan" },
          { pattern = "tab", icon = " ", color = "purple" },
          { pattern = "buffer", icon = " ", color = "azure" },
          { pattern = "window", icon = " ", color = "azure" },
          { pattern = "history", icon = " ", color = "azure" },
          { pattern = "History", icon = " ", color = "azure" },
          { pattern = "Avante", icon = " ", color = "azure" },
          { pattern = "avante", icon = " ", color = "azure" },
          { pattern = "AI", icon = helper_icons.ui.Eye, color = "yellow" },
          { pattern = "ai", icon = helper_icons.ui.Eye, color = "yellow" },
          { pattern = "Cheatsheet", icon = " ", color = "yellow" },
          { pattern = "cheatsheet", icon = " ", color = "yellow" },
          { pattern = "Toggle", icon = " ", color = "azure" },
          { pattern = "toggle", icon = " ", color = "azure" },
          { pattern = "Preview", icon = "󰇘 ", color = "azure" },
          { pattern = "preview", icon = "󰇘 ", color = "azure" },
          { pattern = "Code", icon = "  ", color = "azure" },
          { pattern = "Telescope", icon = "  ", color = "azure" },
          { pattern = "Marks", icon = "  ", color = "azure" },
          { pattern = "marks", icon = "  ", color = "azure" },
          { pattern = "Github", icon = helper_icons.ui.GitHub, color = "azure" },
          { pattern = "github", icon = helper_icons.ui.GitHub, color = "azure" },
          { pattern = "Application", icon = " ", color = "azure" },
          { pattern = "application", icon = " ", color = "azure" },
          { pattern = "Copilot", icon = helper_icons.copilot.Enabled, color = "azure" },
          { pattern = "copilot", icon = helper_icons.copilot.Enabled, color = "azure" },
          { pattern = "Visits", icon = " ", color = "azure" },
          { pattern = "visits", icon = " ", color = "azure" },
          { pattern = "Misc", icon = " ", color = "azure" },
          { pattern = "misc", icon = " ", color = "azure" },
          { pattern = "Explorer", icon = helper_icons.ui.Explorer, color = "azure" },
          { pattern = "explorer", icon = helper_icons.ui.Explorer, color = "azure" },
          { pattern = "Connect", icon = helper_icons.misc.connected, color = "azure" },
          { pattern = "Disconnect", icon = helper_icons.misc.connected, color = "azure" },
          { pattern = "PyEnv", icon = helper_icons.language.python, color = "yellow" },
          { pattern = "Python", icon = helper_icons.language.python, color = "yellow" },
          { pattern = "Git ", icon = "  ", color = "purple" },
          { pattern = "SSH", icon = helper_icons.misc.communicator, color = "azure" },
          { pattern = "SSHFS", icon = helper_icons.misc.communicator, color = "azure" },
          { pattern = "Chat", icon = helper_icons.misc.message, color = "azure" },
          { pattern = "Attach", icon = helper_icons.misc.connected, color = "azure" },
          { pattern = "Disable", icon = helper_icons.ui.Disable, color = "red" },
          { pattern = "Enable", icon = helper_icons.ui.Ligthbulb, color = "azure" },
          { pattern = "Status", icon = helper_icons.diagnostics.Information_alt, color = "azure" },
          { pattern = "Suggestion", icon = helper_icons.misc.comment, color = "azure" },
          { pattern = "Editor", icon = helper_icons.ui.Neovim, color = "azure" },
          -- { pattern = "Detach", icon = helper_icons.misc.communicator, color = "azure" },
          -- { pattern = "", icon = "", color = "azure" },
          -- { pattern = "", icon = " ", color = "azure" },
          -- { pattern = "git", icon = "  ", color = "purple" },
          -- { pattern = "", icon = "", color = "purple" },
        },
      },
      preset = "modern",
      win = {
        padding = { 2, 2, 2, 2 },
        border = "rounded",
        -- border = vim.g.border_enabled and "rounded" or "none",
      },
      -- ignore_missing = true,
      -- show_help = false,
      show_keys = true,
      disable = {
        buftypes = {},
        filetypes = { "TelescopePrompt" },
      },
      filter = function(mapping)
        return mapping.desc and mapping.desc ~= ""
      end,
      delay = function()
        return 0
      end,
      plugins = {
        marks = true,     -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        spelling = {
          enabled = false,  -- enabling this will show WhichKey when pressing z= to spell suggest
        },
        presets = {
          operators = false,    -- adds help for operators like d, y, ...
          motions = false,      -- adds help for motions
          text_objects = false, -- help for text objects triggered after entering an operator
          windows = true,       -- default bindings on <c-w>
          nav = true,           -- misc bindings to work with windows
          z = true,             -- bindings for folds, spelling and others prefixed with z
          g = true              -- bindings for prefixed with g
        }
      },
      -- icons = { mappings = false },
      spec = {
        { "<leader>a", group = "Application" },
        { "<leader>ac", group = " Clipboard" },
        { "<leader>af", group = "Focus" },
        { "<leader>ag", group = "Gist" },
        { "<leader>as", group = "SSHFS" },
        { "<leader>at", group = "Terminal" },
        { "<leader>aT", group = "Treesitter" },
        { "<leader>az", group = "SOPS" },
        { "<leader>A", group = "AI" },
        { "<leader>AC", group = "Avante: Conflict" },
        { "<leader>AS", group = "Avante: Switch Model" },
        { "<leader>b", group = "Buffer" },
        { "<leader>bs", group = "Sort" },
        { "<leader>B", group = "Tab" },
        { "<leader>c", group = "Copilot" },
        { "<leader>cc", group = "Copilot Chat" },
        { "<leader>d", group = "Diagnostic" },
        { "<leader>e", group = "Editor" },
        { "<leader>ef", group = "Flash" },
        { "<leader>en", group = "Noice" },
        { "<leader>el", group = "Lazy" },
        { "<leader>es", group = "Snacks" },
        { "<leader>f", group = "Find" },
        { "<leader>ff", group = "File" },
        { "<leader>fg", group = "Git" },
        { "<leader>fd", group = "Debug" },
        { "<leader>fl", group = "LSP" },
        { "<leader>F", group = "File" },
        { "<leader>g", group = "Git" },
        { "<leader>gn", group = "Neogit" },
        { "<leader>go", group = "Open Repo" },
        { "<leader>gv", group = "VGit" },
        { "<leader>gvb", group = "Buffer" },
        { "<leader>gvt", group = "Toggle" },
        { "<leader>h", group = "Helper" },
        { "<leader>I", group = "Inserts" },
        { "<leader>l", group = "LSP" },
        { "<leader>lc", group = "Commands" },
        -- { "<leader>l", group = " LSP" },
        { "<leader>lm", group = "Marks" },
        -- { "<leader>lP", group = " PyEnv" },
        { "<leader>lP", group = "PyEnv" },
        { "<leader>lw", group = "Workspace" },
        { "<leader>m", group = "Misc" },
        { "<leader>M", group = "Marks" },
        { "<leader>Mb", group = "Bookmarks" },
        { "<leader>Mg", group = "Grapple" },
        { "<leader>p", group = "Preview" },
        { "<leader>P", group = "Program" },
        { "<leader>s", group = "Search" },
        { "<leader>S", group = "Session" },
        { "<leader>Sc", group = "Current" },
        { "<leader>t", group = "Telescope" },
        -- { "<leader>t", group = " Telescope" },
        { "<leader>tc", group = "Code" },
        { "<leader>tcl", group = "LSP" },
        { "<leader>tf", group = "File Operations" },
        { "<leader>tg", group = "Git Files" },
        -- { "<leader>tg", group = " Git Files" },
        { "<leader>th", group = "Help" },
        { "<leader>tH", group = "History" },
        { "<leader>ts", group = "Glyphs and Symbols" },
        { "<leader>tw", group = "Web Browse" },
        { "<leader>v", group = "Visits" },
        { "<leader>w", group = "Window" },
        { "<leader>W", group = "Workspace" },
        -- { "<leader>W", group = " Workspace" },
        -- { "<leader>c", group = "[C]ode", mode = { "n", "x" } },
        -- { "<leader>d", group = "[D]ocument" },
        -- { "<leader>r", group = "[R]ename" },
        -- { "<leader>s", group = "[S]earch" },
        -- { "<leader>w", group = "[W]orkspace" },
        -- { "<leader>m", group = "[M]eta", { "<leader>ml", "<cmd>Lazy<CR>", desc = "Open [L]azy" } },
        -- { "<leader>z", group = "[Z]en", { "<leader>zt", "<cmd>Twilight<CR>", desc = "Toggle [T]wilight" } },
        -- Global
        -- { "<leader>a", group = "ai" },
        -- { "<leader>c", group = "code" },
        -- { "<leader>cd", group = "documentation" },
        -- { "<leader>cm", group = "markdown" },
        -- { "<leader>ct", group = "trouble" },
        -- { "<leader>cu", group = "ui" },
        -- { "<leader>d", group = "debugger" },
        -- { "<leader>e", group = "explorer" },
        -- { "<leader>f", group = "file-manager" },
        -- { "<leader>fd", group = "finder" },
        -- { "<leader>fdg", group = "git" },
        -- { "<leader>fdl", group = "lsp" },
        -- { "<leader>g", group = "git" },
        -- { "<leader>gc", group = "commit" },
        -- { "<leader>gh", group = "hunk" },
        -- { "<leader>ght", group = "toggle" },
        -- { "<leader>G", group = "grep-operator" },
        -- { "<leader>h", group = "harpoon" },
        -- { "<leader>i", group = "ui-interface" },
        -- { "<leader>im", group = "minimap" },
        -- { "<leader>l", group = "lsp" },
        -- { "<leader>m", group = "misc" },
        -- { "<leader>mc", group = "cellular-automaton" },
        -- { "<leader>o", group = "open" },
        -- { "<leader>p", group = "plugin-manager" },
        -- { "<leader>r", group = "text-editting" },
        -- { "<leader>ra", group = "align" },
        -- { "<leader>raa", group = "after" },
        -- { "<leader>rc", group = "text-case" },
        -- { "<leader>rca", group = "cursor-and-rename" },
        -- { "<leader>rce", group = "operator" },
        -- { "<leader>re", group = "register" },
        -- { "<leader>rm", group = "muren" },
        -- { "<leader>rt", group = "search-and-replace" },
        -- { "<leader>ry", group = "yank" },
        -- { "<leader>s", group = "session" },
        -- { "<leader>t", group = "tools" },
        -- { "<leader>td", group = "diff" },
        -- { "<leader>tl", group = "leetcode" },
        -- { "<leader>tr", group = "repl" },
        -- { "<leader>ts", group = "code-runner" },
        -- { "<leader>w", group = "web-dev" },
        -- { "<leader>wr", group = "rest" },
        -- { "<leader>z", desc = "toggle fold" },
        -- { "<leader>Z", desc = "fold all except current" },
        -- LocalLeader
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {-- Terminal & Commands/Tasks
    'akinsho/nvim-toggleterm.lua',
    version = "*",
    lazy = false,
    config = function()
      require('plugins.utils.toggleterm')
    end,
  },
  {-- telescope-termfinder.nvim: for displaying terminal colors in the pane_contents previewer with telescope-tmux
    'tknightz/telescope-termfinder.nvim',
    lazy = false,
    config = function()
      require('telescope').load_extension("termfinder")
    end,
  },
  {-- jedrzejboczar/toggletasks.nvim
    'jedrzejboczar/toggletasks.nvim',
    lazy = false,
    dependencies = { 'nvim-lua/plenary.nvim', 'akinsho/toggleterm.nvim', 'nvim-telescope/telescope.nvim' },
    config = function()
      require('plugins.utils.toggletasks')
    end,
  },
  {-- numToStr/Comment.nvim
    'numToStr/Comment.nvim',
    lazy = false,
    config = function()
      require('plugins.utils.comment')
    end,
  },
  {-- meznaric/key-analyzer.nvim
    'meznaric/key-analyzer.nvim',
    lazy = false,
    config = function()
      require('plugins.utils.key-analyzer')
    end,
  },
  {-- folke/snacks.nvim
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = {
        enabled = true,
        notify = true,
        size = 200 * 1024, -- 200 KB
      },
      bufdelete = { enabled = true },
      dashboard = {
        sections = {
          { section = 'header' },
          { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
          { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
          { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
          { section = 'startup' },
        },
      },
      dim = { enabled = true },
      git = { enabled = true },
      gitbrowse = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      lazygit = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      notify = { enabled = true },
      profiler = { enabled = true },
      quickfile = { enabled = false },
      rename = { enabled = true },
      scope = { enabled = true },
      scratch = {
        enabled = true,
        name = 'Scratch',
        ft = function()
          if vim.bo.buftype == '' and vim.bo.filetype ~= '' then
            return vim.bo.filetype
          end
          return 'markdown'
        end,
        icon = nil,
        root = vim.fn.stdpath('data') .. '/scratch',
        autowrite = true,
        filekey = {
          cwd = true,
          branch = true,
          count = true,
        },
        win = {
          width = 120,
          height = 40,
          bo = { buftype = '', buflisted = false, bufhidden = 'hide', swapfile = false },
          minimal = false,
          noautocmd = false,
          zindex = 20,
          wo = { winhighlight = 'NormalFloat:Normal' },
          border = 'rounded',
          title_pos = 'center',
          footer_pos = 'center',

          keys = {
            ['execute'] = {
              '<cr>',
              function(_)
                vim.cmd('%SnipRun')
              end,
              desc = 'Execute buffer',
              mode = { 'n', 'x' },
            },
          },
        },
        win_by_ft = {
          lua = {
            keys = {
              ['source'] = {
                '<cr>',
                function(self)
                  local name = 'scratch.' .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ':e')
                  Snacks.debug.run({ buf = self.buf, name = name })
                end,
                desc = 'Source buffer',
                mode = { 'n', 'x' },
              },
              ['execute'] = {
                'e',
                function(_)
                  vim.cmd('%SnipRun')
                end,
                desc = 'Execute buffer',
                mode = { 'n', 'x' },
              },
            },
          },
        },
      },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      terminal = { enabled = false },
      toggle = { enabled = true },
      util = { enabled = true },
      win = { enabled = true },
      words = { enabled = true },
      zen = { enabled = true },
      styles = {
        notification = {
          wo = { wrap = true }, -- Wrap notifications
        },
      },
    },
    keys = {
      { "<leader>mz",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
      { "<leader>wz",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
      { "<leader>m.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>ms",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>mn",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
      -- { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
      { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
      -- { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
      { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)" },
      { "<leader>mH", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      -- { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
      -- { "<c-_>",      function() Snacks.terminal() end, desc = "which_key_ignore" },
      { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
      { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
    },
  },
  {-- axieax/urlview.nvim
    'axieax/urlview.nvim',
    lazy = false,
  },
  {-- nguyenvukhang/nvim-toggler
    'nguyenvukhang/nvim-toggler',
    config = function()
      require('plugins.utils.toggler')
    end,
  },
  {
    "roobert/f-string-toggle.nvim",
    config = function()
      require("f-string-toggle").setup({
        key_binding = "<localleader>pf",
        key_binding_desc = "Toggle f-string"
      })
    end,
  }
  -- {-- 
  --   '',
  --   config = function()
  --     require('plugins.utils.')
  --   end,
  -- },
}

return M
