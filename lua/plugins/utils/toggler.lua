--[[
-- Toggler Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-20
--]]


local status_ok, toggler = pcall(require, 'toggler')
if not status_ok then
  return
end

toggler.setup({
  -- your own inverses
  inverses = {
    ["before"] = "after",
    ["true"] = "false",
    ["True"] = "False",
    ["TRUE"] = "FALSE",
    ["Yes"] = "No",
    ["YES"] = "NO",
    ["On"] = "Off",
    ["ON"] = "OFF",
    ["left"] = "right",
    ["Left"] = "Right",
    ["LEFT"] = "RIGHT",
    ["Up"] = "Down",
    ["UP"] = "DOWN",
    ["enable"] = "disable",
    ["Enable"] = "Disable",
    ["ENABLE"] = "DISABLE",
    ["next"] = "previous",
    ["Next"] = "Previous",
    ["NEXT"] = "PREVIOUS",
    ["above"] = "below",
    ["Above"] = "Below",
    ["ABOVE"] = "BELOW",
    ["!="] = "==",
    ["yes"] = "no",
    ["on"] = "off",
    ["up"] = "down",
    ["public"] = "private",
    ["!"] = "=",
    ["->"] = "<-",
    ["?"] = "¿",
    ["<"] = ">",
    ["[x]"] = "[ ]",
    ["enabled"] = "disabled",
    ["active"] = "inactive",
    ['class'] = 'className',
    ['xelatex'] = 'lualatex',
    ['const'] = 'let',
    ['main'] = 'master',
    ['optional'] = 'required'
  },
  remove_default_keybinds = true,
  remove_default_inverses = false,
  -- auto-selects the longest match when there are multiple matches
  autoselect_longest_match = true
})
