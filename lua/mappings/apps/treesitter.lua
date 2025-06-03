--[[
-- Mappings: Treesitter
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

return {
  { "<leader>aTc", "<cmd>TSContext toggle<cr>", desc = "Context: Toggle" },
  { "<leader>aTe", "<cmd>TSEnable<cr>", desc = "Enable" },
  { "<leader>aTd", "<cmd>TSDisable<cr>", desc = "Disable" },
  { "<leader>aTm", "<cmd>TSModuleInfo<cr>", desc = "Module Info" },
  { "<leader>aTC", "<cmd>TSConfigInfo<cr>", desc = "Config Info" },
  { "<leader>aTi", "<cmd>TSInstallInfo<cr>", desc = "Install Info" },
  { "<leader>aTv", "<cmd>NvimContextVtToggle<CR>", desc = "VT Context: Toggle" },
}
