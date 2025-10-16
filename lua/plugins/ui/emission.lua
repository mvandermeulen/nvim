--[[
-- Emission Plugin
-- Author: Mark van der Meulen
-- Updated: 2025-10-16
--]]


-- Link: https://github.com/aileot/emission.nvim

-- In the following example, added/removed highlights are restricted
-- to normal mode. Additionally, it will never highlight during
-- recorded macro execution.

---@param buf number attached buffer handle
---@return boolean Return false or nil to ignore; otherwise, highlight texts
local emission_filter = function(buf)
  -- Do not highlight during executing macro.
  if vim.fn.reg_executing() ~= "" then
    return false
  end
  -- Do not highlight except in Normal mode.
  if not vim.api.nvim_get_mode().mode:find("n") then
    return false
  end
  return true
end


return {
  'aileot/emission.nvim',
  event = 'VeryLazy',
  opts = {},
  config = function()
    require('emission').setup({
      added = {
        -- Set other options at `added`...
        filter = emission_filter,
      },
      removed = {
        -- Set other options at `removed`...
        -- You can also set another filter apart from `added` one.
        filter = emission_filter,
      },
    })
  end,
}
