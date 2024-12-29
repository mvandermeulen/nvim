--[[
-- DAP Virtual Text Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-20
--]]


local status_ok, dap_virtual_text = pcall(require, 'nvim-dap-virtual-text')
if not status_ok then
  return
end

dap_virtual_text.setup({
  commented = true,
  show_stop_reason = true,
  virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
  enabled_commands = true,
})
