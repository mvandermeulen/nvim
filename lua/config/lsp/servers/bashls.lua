-- Done
-- https://github.com/mads-hartmann/bash-language-server

local util = require("lspconfig.util")

local bin_name = "bash-language-server"
local cmd = { bin_name, "start" }

return {
  settings = {
    cmd = cmd,
    cmd_env = {
      -- Prevent recursive scanning which will cause issues when opening a file
      -- directly in the home directory (e.g. ~/foo.sh).
      --
      -- Default upstream pattern is "**/*@(.sh|.inc|.bash|.command)".
      GLOB_PATTERN = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
    },
    filetypes = { "sh", "zsh", "bash" },
    single_file_support = true,
    root_dir = [[util.find_git_ancestor]],
  },
}
