--[[
-- LSP Server: Lua
--
-- Author: Mark van der Meulen
-- Updated: August 09, 2023
--]]


local lsputils_status, lsputils = pcall(require, 'config.lsp.utils')
if not lsputils_status then
  return
end


local settings = {
  filetypes = { 'lua' },
  format = { enabled = false }, -- HACK: Hoping this will prevent automatic lua formatting at the moment.
  runtime = {
    version = lsputils.hs_version,
    path = lsputils.hs_path,
  },
  -- runtime = {
  --   version = 'LuaJIT',
  --   path = vim.split(package.path, ';'),
  -- },
  completion = { enable = true, callSnippet = 'Both' },
  diagnostics = {
    enable = true,
    globals = { 'vim', 'describe', 'hs', 'spoons' },
    disable = { 'lowercase-global' },
  },
  workspace = {
    library = {
      vim.api.nvim_get_runtime_file('', true),
      [vim.fn.expand '$VIMRUNTIME/lua'] = true,
      [vim.fn.expand '$VIMRUNTIME/lua/vim/lsp'] = true,
      [vim.fn.expand '/usr/share/awesome/lib'] = true,
      ['/Users/vandem/.hammerspoon/Spoons/EmmyLua.spoon/annotations/'] = true,
      ['/Applications/Hammerspoon.app/Contents/Resources/extensions/hs/'] = true,
    },
    -- adjust these two values if your performance is not optimal
    maxPreload = 9000,
    preloadFileSize = 9000,
  },
  telemetry = { enable = false },
}

local opts = {
  settings = {
    Lua = settings,
  },
}

return opts
