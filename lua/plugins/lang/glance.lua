--[[
-- Glance Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-29
--]]


local status_ok, glance = pcall(require, 'glance')
if not status_ok then
  return
end



local filter = function(arr, fn)
  if type(arr) ~= "table" then
    return arr
  end

  local filtered = {}
  for k, v in pairs(arr) do
    if fn(v, k, arr) then
      table.insert(filtered, v)
    end
  end

  return filtered
end

glance.setup {
  hooks = {
    before_open = function(results, open, jump, method)
      if #results == 1 then
        jump(results[1])
      elseif method == "definitions" then
        -- results = filter(results, filterReactDTS)
        if #results == 1 then
          jump(results[1])
        else
          open(results)
        end
      else
        open(results)
      end
    end,
  },
}



vim.keymap.set('n', 'gD', '<CMD>Glance definitions<CR>', { noremap = true, silent = true, desc = "Definitions" })
vim.keymap.set('n', 'gR', '<CMD>Glance references<CR>', { noremap = true, silent = true, desc = "References" })
vim.keymap.set('n', 'gY', '<CMD>Glance type_definitions<CR>', { noremap = true, silent = true, desc = "Type Definitions" })
vim.keymap.set('n', 'gM', '<CMD>Glance implementations<CR>', { noremap = true, silent = true, desc = "Implementations" })
