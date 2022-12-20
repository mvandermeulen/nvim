return {
  -- more settings see https://github.com/microsoft/pyright/blob/main/packages/vscode-pyright/package.json
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        autoImportCompletions = false,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
        typeCheckingMode = "off",
        logLevel = "Warning",
        diagnosticSeverityOverrides = {
          reportUnusedImport = "off",
        },
      },
    },
  }
}
