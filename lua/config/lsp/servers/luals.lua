--[[
-- LSP Server: Lua
--
-- Author: Mark van der Meulen
-- Updated: 2025-06-17
--]]



local _name = 'Lua LSP'
local _log = require('plenary.log').new({ plugin = _name, level = 'debug', use_console = true })
local function mylog(msg, level)
  local level = level or 'debug'
  if level == 'error' then
    vim.api.nvim_err_writeln(msg)
    _log.error(msg)
  elseif level == 'notify' then
    vim.notify(msg, vim.log.levels.INFO, { title = _name })
    _log.info(msg)
  elseif level == 'info' then
    _log.info(msg)
  else
    _log.debug(msg)
  end
end


local lsputils_status, lsputils = pcall(require, 'config.lsp.utils')
if not lsputils_status then
  mylog('Error loading helper: lsputils', 'error')
  return
end

local hammerspoom_runtime = {
  version = lsputils.hs_version,
  path = lsputils.hs_path,
}
local hammerspoon_globals = { 'hs', 'spoons' }

local neovim_runtime = {
  version = 'LuaJIT',
  path = vim.split(package.path, ';'),
}
local neovim_globals = { 'vim', 'describe', 'require', 'vim', 'vim' }

local diagnostics_globals = function()
  -- mylog('Loading Lua LSP globals', 'info')
  local root = require('helpers.utils.fs').get_root_dir()
  local is_hammerspoon = string.find(root, 'hammer') or string.find(root, 'spoon')
  if is_hammerspoon then
    -- mylog('Loaded Hammerspoon globals', 'info')
    return hammerspoon_globals
  else
    -- mylog('Loaded Neovim globals', 'info')
    return neovim_globals
  end
end

local diagnostics_runtime = function()
  -- mylog('Loading Lua LSP runtime', 'info')
  local root = require('helpers.utils.fs').get_root_dir()
  local is_hammerspoon = string.find(root, 'hammer') or string.find(root, 'spoon')
  if is_hammerspoon then
    -- mylog('Loaded Hammerspoon runtime', 'info')
    return hammerspoom_runtime
  else
    -- mylog('Loaded Neovim runtime', 'info')
    return neovim_runtime
  end
end

local hammerspoon_library = {
  '/Users/vandem/.hammerspoon/Spoons/EmmyLua.spoon/annotations/',
  '/Applications/Hammerspoon.app/Contents/Resources/extensions/hs/',
}

local neovim_library = {
  vim.api.nvim_get_runtime_file('', true),
  vim.env.VIMRUNTIME,
  vim.fn.expand '$VIMRUNTIME/lua',
  vim.fn.expand '$VIMRUNTIME/lua/vim/lsp',
  vim.fn.expand '/usr/share/awesome/lib',
}

local workspace_library = function()
  local root = require('helpers.utils.fs').get_root_dir()
  local is_hammerspoon = string.find(root, 'hammer') or string.find(root, 'spoon')
  if is_hammerspoon then
    return hammerspoon_library
  else
    return neovim_library
  end
end

-- mylog('Loading Lua LSP settings', 'info')
local settings = {
  filetypes = { 'lua' },
  format = { enabled = false }, -- HACK: Hoping this will prevent automatic lua formatting at the moment.
  runtime = diagnostics_runtime(),
  -- runtime = neovim_runtime,
  flags = { debounce_text_changes = 150 },
  completion = { enable = true, callSnippet = 'Both' },
  diagnostics = {
    enable = true,
    -- globals = neovim_globals,
    globals = diagnostics_globals(),
    -- globals = { 'vim', 'describe', 'hs', 'spoons' },
    disable = { 'lowercase-global' },
  },
  workspace = {
    -- library = {
    --   vim.api.nvim_get_runtime_file('', true),
    --   vim.fn.expand '$VIMRUNTIME/lua',
    --   vim.fn.expand '$VIMRUNTIME/lua/vim/lsp',
    --   vim.fn.expand '/usr/share/awesome/lib',
    --   '/Users/vandem/.hammerspoon/Spoons/EmmyLua.spoon/annotations/',
    --   '/Applications/Hammerspoon.app/Contents/Resources/extensions/hs/',
    -- },
    -- adjust these two values if your performance is not optimal
    library = workspace_library(),
    -- library = neovim_library,
    maxPreload = 9000,
    preloadFileSize = 9000,
    checkThirdParty = false,
    ignoreDir = {
      'examples',
      'notes',
    },
  },
  codeLens = {
    enable = true,
  },
  hint = {
    enable = true,
    -- setType = false,
    -- paramType = true,
    -- paramName = "Disable",
    -- semicolon = "Disable",
    -- arrayIndex = "Disable",
  },
  telemetry = { enable = false },
}

local opts = {
  settings = {
    Lua = settings,
  },
}
mylog('Lua LSP settings loaded', 'info')

return opts
