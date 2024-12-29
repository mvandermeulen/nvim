--[[
-- DAP Python Plugin
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-20
--]]


local status_ok, dap_python = pcall(require, 'dap-python')
if not status_ok then
  return
end

-- dap_python.setup('python3')
dap_python.setup('uv')
