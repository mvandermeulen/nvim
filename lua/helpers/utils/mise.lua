--[[
-- Helpers: mise
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-23
--]]

--- Some helper to interact with mise

return {
    get_env = function()
        local obj = vim.system({ "mise", "env", "--json" }, { text = true }):wait()
        return vim.json.decode(obj.stdout)
    end,
}
