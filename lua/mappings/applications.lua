--[[
-- Mappings: Applications
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

local log = require('plenary.log').new({ plugin = 'which-key-apps', level = 'debug', use_console = true })
local function mylog(msg, level)
  local level = level or 'debug'
  log.debug(msg)
  if level == 'info' or level == 'warn' or level == 'error' then
    vim.notify(msg, vim.log.levels.INFO, { title = 'which-key-apps' })
  end
end

local ts_status, ts = pcall(require, 'mappings.apps.treesitter')
if not ts_status then
  mylog('Failed to load mappings: Treesitter', 'error')
  return
end

local terminal_status, term = pcall(require, 'mappings.apps.terminal')
if not terminal_status then
  mylog('Failed to load mappings: Terminal', 'error')
  return
end

local sshfs_status, sshfs = pcall(require, 'mappings.apps.sshfs')
if not sshfs_status then
  mylog('Failed to load mappings: SSHFS', 'error')
  return
end

local clipboard_status, clip = pcall(require, 'mappings.apps.clipboard')
if not clipboard_status then
  mylog('Failed to load mappings: Clipboard', 'error')
  return
end

local gist_status, gist = pcall(require, 'mappings.apps.gist')
if not gist_status then
  mylog('Failed to load mappings: Gist', 'error')
  return
end

local sops_status, sops = pcall(require, 'mappings.apps.sops')
if not sops_status then
  mylog('Failed to load mappings: SOPS', 'error')
  return
end

return {
  { "<leader>aC", "<cmd>Cheatsheet<cr>", desc = "Cheatsheet" },
  { '<leader>am', '<cmd>Mason<cr>', desc = 'Mason' },
  { "<leader>aS", "<cmd>FzfLua<cr>", desc = "Fuzzy Search" },
  { "<leader>aT", "<cmd>Telescope<cr>", desc = "  Telescope Extensions" },
  { "<leader>ay", "<ESC><CMD>YankBank<CR>", desc = " YankBank" },
  -- { "<leader>au", "<ESC><CMD>UrlView<CR>", desc = "Buffer URL View" },
  -- { "<leader>aL", "<ESC><CMD>UrlView lazy<CR>", desc = "Lazy URL View" },
  { '<leader>aV', "<cmd>lua _G.my.helpers.server:vdm_start_server()<cr>", desc = 'Start Server' },
  -- Clipboard: <leader>ac
  clip,
  -- Gist: <leader>ag
  gist,
  -- SSHFS: <leader>as
  sshfs,
  -- Terminal: <leader>at
  term,
  -- Treesitter: <leader>aT
  ts,
  -- SOPS: <leader>az
  sops,
  { '<leader>au', '<cmd>Atone toggle<cr>', desc = 'Undotree' },
}
