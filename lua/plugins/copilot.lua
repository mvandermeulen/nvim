--[[
-- Copilot
--
-- Author: Mark van der Meulen
-- Updated: 09-05-2022
--]]

vim.g.copilot_filetypes = {
  ["*"] = false,
}

vim.cmd [[
  imap <silent><script><expr> <C-A> copilot#Accept("\<CR>")
  let g:copilot_no_tab_map = v:true
]]


