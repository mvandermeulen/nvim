--[[
-- REST Plugin
--
-- Author: Mark van der Meulen
-- Updated: 01-06-2022
--]]



require("rest-nvim").setup({
  result_split_horizontal = false, -- Open request results in a horizontal split
  skip_ssl_verification = true, -- Skip SSL verification, useful for unknown certificates
  -- Highlight request on run
  highlight = {
    enabled = true,
    timeout = 150,
  },
  result = {
    -- toggle showing URL, HTTP info, headers at top the of result window
    show_url = true,
    show_http_info = true,
    show_headers = true,
  },
  jump_to_request = false, -- Jump to request line on run
  env_file = '.env',
  custom_dynamic_variables = {},
  yank_dry_run = true,
})
