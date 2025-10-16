return {
  "suryagaddipati/claudecode.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
  },
  config = function()
    require('claudecode').setup({
      -- terminal_cmd = 'claude',
      terminal = {
        split_side = "right",           -- "left", "right", "top", "bottom"
        split_height_percentage = 0.30, -- For horizontal splits (top/bottom)
        split_width_percentage = 0.40,  -- For vertical splits (left/right)
        provider = "auto",              -- "auto", "toggleterm", "native"
        direction = nil,                -- Auto-determined from split_side
        auto_close = true,
      },
      window = {
        split_ratio = 0.3,      -- Percentage of screen for the terminal window (height for horizontal, width for vertical splits)
        position = "botright",  -- Position of the window: "botright", "topleft", "vertical", "float", etc.
        enter_insert = true,    -- Whether to enter insert mode when opening Claude Code
        hide_numbers = true,    -- Hide line numbers in the terminal window
        hide_signcolumn = true, -- Hide the sign column in the terminal window
      },
      refresh = {
        enable = true,           -- Enable file change detection
        updatetime = 100,        -- updatetime when Claude Code is active (milliseconds)
        timer_interval = 1000,   -- How often to check for file changes (milliseconds)
        show_notifications = true, -- Show notification when files are reloaded
      },
      git = {
        use_git_root = true,     -- Set CWD to git root when opening Claude Code (if in git project)
      },
      shell = {
        separator = '&&',        -- Command separator used in shell commands
        pushd_cmd = 'pushd',     -- Command to push directory onto stack (e.g., 'pushd' for bash/zsh, 'enter' for nushell)
        popd_cmd = 'popd',       -- Command to pop directory from stack (e.g., 'popd' for bash/zsh, 'exit' for nushell)
      },
      command = "claude",        -- Command used to launch Claude Code
      command_variants = {
        continue = "--continue", -- Resume the most recent conversation
        resume = "--resume",     -- Display an interactive conversation picker
        verbose = "--verbose",   -- Enable verbose logging with full turn-by-turn output
      },
      keymaps = {
        toggle = {
          normal = "<C-,>",       -- Normal mode keymap for toggling Claude Code, false to disable
          terminal = "<C-,>",     -- Terminal mode keymap for toggling Claude Code, false to disable
          variants = {
            continue = "<leader>cC", -- Normal mode keymap for Claude Code with continue flag
            verbose = "<leader>cV",  -- Normal mode keymap for Claude Code with verbose flag
          },
        },
        window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
        scrolling = true,         -- Enable scrolling keymaps (<C-f/b>) for page up/down
      }
    })
  end,
  keys = {
    -- Core Claude Code operations
    { '<leader>C',  nil,                              desc = 'Claude Code' },
    { '<leader>Cc', '<cmd>ClaudeCode<cr>',            desc = 'Toggle Claude' },
    { '<leader>Cf', '<cmd>ClaudeCodeFocus<cr>',       desc = 'Focus Claude' },
    { '<leader>Cr', '<cmd>ClaudeCode --resume<cr>',   desc = 'Resume Claude' },
    { '<leader>CC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
    { '<leader>Cb', '<cmd>ClaudeCodeAdd %<cr>',       desc = 'Add current buffer' },
    { '<leader>Cs', '<cmd>ClaudeCodeSend<cr>',        mode = 'v',                 desc = 'Send to Claude' },
    {
      '<leader>Ct',
      '<cmd>ClaudeCodeTreeAdd<cr>',
      desc = 'Add file',
      ft = { 'NvimTree', 'neo-tree', 'oil' },
    },
    { '<leader>Ca', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
    { '<leader>Cd', '<cmd>ClaudeCodeDiffDeny<cr>',   desc = 'Deny diff' },

    -- Git + Claude Integration (moved to <leader>g* namespace)
    { '<leader>Ga', '<cmd>ClaudeCodeSendHunk<cr>',   desc = 'Git: Add hunk to Claude' },
    { '<leader>GA', '<cmd>ClaudeCodeAdd %<cr>',      desc = 'Git: Add buffer to Claude' },
    { '<leader>Gi', '<cmd>ClaudeCodeSendHunk<cr>',   desc = 'Git: Send hunk info to Claude' },
    {
      '<leader>GI',
      function()
        -- Send entire diff to Claude for review
        vim.cmd('ClaudeCodeAdd %')
        vim.notify('Buffer added to Claude for diff review', vim.log.levels.INFO)
      end,
      desc = 'Git: Send diff to Claude for review'
    },
  },
}
