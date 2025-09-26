return {
  'stevearc/conform.nvim',
  event = { 'BufEnter' },
  cmd = { 'ConformInfo' },
  opts = {
    -- https://github.com/stevearc/conform.nvim#formatters
    -- list of all formatters
    -- make sure to run :checkhealth conform
    -- to see whether tools are present or not for formatting
    formatters_by_ft = {
      lua = { 'stylua' },
      -- Conform will run multiple formatters sequentially
      -- python = { "ruff" },
      python = { 'ruff_organize_imports', 'ruff_fix', 'ruff_format' },
      go = { 'goimports', 'gofmt' },
      yaml = { 'yamlfmt' },
      -- yaml = { 'prettierd', 'prettier', stop_after_first = true },
      bash = { 'shfmt' },
      zsh = { 'shfmt' },
      sh = { 'shfmt' },
      json = { 'prettierd', 'prettier', stop_after_first = true },
      toml = { 'taplo' },
      markdown = { 'mdformat', 'mdsf' },
      -- You can customize some of the format options for the filetype (:help conform.format)
      -- rust = { "rustfmt" },
      -- Conform will run the first available formatter
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      -- typescript = { "prettierd", "prettier", stop_after_first = true },
    },
    format_on_save = {
      -- These options will be passed to conform.format()
      timeout_ms = 500,
      lsp_format = 'fallback',
    },
  },
}
