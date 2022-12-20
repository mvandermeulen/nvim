return {
  settings = {
    html = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/snap"] = true,
          [vim.fn.stdpath "config" .. "/snap"] = true,
        },
      },
      filetypes = { "html", "*.snap" },
    },
  },
}
