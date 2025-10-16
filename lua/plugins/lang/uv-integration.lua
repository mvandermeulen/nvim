--[[
-- UV Integration Plugin
-- Author: Mark van der Meulen
-- Updated: 2025-10-16
--]]


-- Link: https://github.com/benomahony/uv.nvim

return {
  {
    "benomahony/uv.nvim",
    ft = "python",
    opts = {
      auto_activate = true,
      auto_commands = true,
    },
    keys = {
      { "<leader>aur", "<cmd>UVRun<cr>", desc = "UV Run" },
      { "<leader>aua", "<cmd>UVAdd<cr>", desc = "UV Add Package" },
      { "<leader>aud", "<cmd>UVRemove<cr>", desc = "UV Remove Package" },
      { "<leader>aui", "<cmd>UVInit<cr>", desc = "UV Init Project" },
      { "<leader>aus", "<cmd>UVSync<cr>", desc = "UV Sync" },
      { "<leader>auv", "<cmd>UVStatus<cr>", desc = "UV Status" },
    },
  },
}
