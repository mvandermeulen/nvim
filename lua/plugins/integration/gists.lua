--[[
-- Gist Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-23
--]]

local status_ok, gist = pcall(require, 'gist')
if not status_ok then
  return
end

gist.setup({
    private = false, -- All gists will be private, you won't be prompted again
    clipboard = "+", -- The registry to use for copying the Gist URL
    list = {
        -- If there are multiple files in a gist you can scroll them,
        -- with vim-like bindings n/p next previous
        mappings = {
            next_file = "<C-n>",
            prev_file = "<C-p>"
        }
    }
})
