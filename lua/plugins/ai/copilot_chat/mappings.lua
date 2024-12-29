--[[
-- Copilot Chat Plugin: Mappings
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-26
--]]


return {
  -- Use tab for completion
  complete = {
    detail = "Use @<Tab> or /<Tab> for options.",
    insert = "<Tab>",
  },
  -- Close the chat
  close = {
    normal = "q",
    insert = "<C-c>",
  },
  -- Reset the chat buffer
  reset = {
    normal = "<C-x>",
    insert = "<C-x>",
  },
  -- Submit the prompt to Copilot
  submit_prompt = {
    normal = "<CR>",
    insert = "<C-o>",
  },
  toggle_sticky = {
    detail = 'Makes line under cursor sticky or deletes sticky line.',
    normal = 'gr',
  },
  -- Accept the diff
  accept_diff = {
    normal = "<C-y>",
    insert = "<C-y>",
  },
  jump_to_diff = {
    normal = 'gj',
  },
  quickfix_diffs = {
    normal = 'gq',
  },
  -- Yank the diff in the response to register
  yank_diff = {
    normal = "gmy",
  },
  -- Show the diff
  show_diff = {
    normal = "gd",
  },
  -- Show the info
  show_info = {
    normal = "gi",
  },
  -- Show the context
  show_context = {
    normal = "gc",
  },
  -- Show help
  show_help = {
    normal = "gh",
  },
}
