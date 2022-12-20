return {
  settings = {
    graphql = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/json"] = true,
          [vim.fn.stdpath "config" .. "/json"] = true,
        },
      },
    },
  },
}
