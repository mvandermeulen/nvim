local dap = require "dap"

dap.adapters.chrome = {
  type = "executable",
  command = "node",
  args = { os.getenv "HOME" .. "/.local/share/nvim/dapinstall/chrome/vscode-chrome-debug/out/src/chromeDebug.js" },
}

dap.configurations.javascriptreact = { -- change this to javascript if needed
  {
    type = "chrome",
    request = "launch",
    program = "${file}",
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = "inspector",
    port = 9222,
    host = "127.0.0.1:3000",
    url = "http://localhost:3000/",
    webRoot = "${workspaceFolder}/src",

    -- type = "chrome",
    -- request = "attach",
    -- program = "${file}",
    -- cwd = vim.fn.getcwd(),
    -- sourceMaps = true,
    -- protocol = "inspector",
    -- port = 9222,
    -- webRoot = "${workspaceFolder}",
  },
}

dap.configurations.typescriptreact = { -- change this to javascript if needed
  {
    type = "chrome",
    request = "launch",
    program = "${file}",
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = "inspector",
    port = 9222,
    --[[ host = "127.0.0.1:3000",
    url = "http://localhost:3000/", ]]
    host = "https://localhost:5001",
    url = "https://localhost:5001",
    webRoot = "${workspaceFolder}/src",
  },
}

dap.configurations.typescript = { -- change this to javascript if needed
  {
    type = "chrome",
    request = "launch",
    program = "${file}",
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = "inspector",
    port = 9222,
    --[[ host = "127.0.0.1:3000",
    url = "http://localhost:3000/", ]]
    host = "https://localhost:5001",
    url = "https://localhost:5001",
    webRoot = "${workspaceFolder}/src",
  },
}

require("dap").set_log_level "TRACE"
-- lua print(vim.fn.stdpath('cache'))
