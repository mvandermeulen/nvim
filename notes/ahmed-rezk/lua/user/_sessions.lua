local M = {}
M.setup = function()
  local opts = {
    log_level = "info",
    auto_session_enable_last_session = true,
    auto_session_root_dir = vim.fn.stdpath "data" .. "/sessions/",
    auto_session_enabled = false,
    auto_save_enabled = true,
  }

  require("auto-session").setup(opts)
end

return M
