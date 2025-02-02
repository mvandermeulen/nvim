--[[
-- Git Client Configuration
--
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]

local neogit = require("neogit")

neogit.setup {
    integrations = {
      telescope = true,
      diffview = true,
    },
    signs = {
      hunk = { "", "" },
      item = { "▷", "▽" },
      section = { "▷", "▽" },
    },
    console_timeout = 10000,
    -- disable_signs = false,
    -- disable_context_highlighting = false,
    -- disable_commit_confirmation = false,
    -- customize displayed signs
    -- override/add mappings
    --mappings = {
        -- modify status buffer mappings
        --status = {
            -- Adds a mapping with "B" as key that does the "BranchPopup" command
            -- ["B"] = "BranchPopup",
            -- ["C"] = "CommitPopup",
            -- ["P"] = "PullPopup",
            -- ["S"] = "Stage",
            -- ["D"] = "Discard",
            -- Removes the default mapping of "s"
            -- ["s"] = "",
        --}
    --}
}
