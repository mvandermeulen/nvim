local present, comments = pcall(require, "Comment")

if not present then
  return
end

local config = {
  padding = true,
  sticky = true,
  ignore = "^$",
  toggler = {
    line = "gcc",
    block = "gbc",
  },
  opleader = {
    line = "gc",
    block = "gb",
  },
  extra = {
    above = "gcO",
    below = "gco",
    eol = "gcA",
  },
  mappings = {
    basic = true,
    extra = true,
    extended = true,
  },
  ---@type fun(ctx: Ctx):string
  pre_hook = function(ctx)
    -- Only calculate commentstring for tsx filetypes
    if bo.filetype == "typescriptreact" then
      local U = require "Comment.utils"
      -- Detemine whether to use linewise or blockwise commentstring
      local type = ctx.ctype == U.ctype.line and "__default" or "__multiline"
      -- Determine the location where to calculate commentstring from
      local location = nil
      if ctx.ctype == U.ctype.block then
        location = require("ts_context_commentstring.utils").get_cursor_location()
      elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
        location = require("ts_context_commentstring.utils").get_visual_start_location()
      end

      return require("ts_context_commentstring.internal").calculate_commentstring {
        key = type,
        location = location,
      }
    end
  end,
  ---@type fun(ctx: Ctx)
  post_hook = nil,
}

comments.setup(config)

-- vim:ft=lua
