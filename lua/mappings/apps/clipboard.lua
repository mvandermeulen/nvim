--[[
-- Mappings: Clipboard
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

return {
  -- { "<leader>ach", "<cmd>:Telescope neoclip<cr>", desc = "History" },
  { "<leader>acm", "<cmd>lua require('telescope').extensions.macroscope.default()<cr>", desc = "Macros" },
  -- { "<leader>acp", "<cmd>:Telescope neoclip plus<cr>", desc = "Yank to Plus" },
  -- { "<leader>acP", '<cmd>lua require("neoclip").pause()<cr>', desc = "Pause Recording" },
  -- { "<leader>acs", "<cmd>:Telescope neoclip star<cr>", desc = "Yank to Star" },
  -- { "<leader>acS", '<cmd>lua require("neoclip").start()<cr>', desc = "Start Recording" },
  -- { "<leader>act", '<cmd>lua require("neoclip").toggle()<cr>', desc = "Toggle Recording" },
  -- { "<leader>acu", "<cmd>:Telescope neoclip unnamed<cr>", desc = "Yank to Unnamed" },
  { "<leader>acc", '"+y', desc = "Copy to Clipboard" },
}
