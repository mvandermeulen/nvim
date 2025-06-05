--[[
-- Mappings: Editor
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

local log = require('plenary.log').new({ plugin = 'editor', level = 'debug', use_console = true })
local function mylog(msg, level)
  local level = level or 'debug'
  log.debug(msg)
  if level == 'info' or level == 'warn' or level == 'error' then
    vim.notify(msg, vim.log.levels.INFO, { title = 'editor' })
  end
end

local settings_status, settings = pcall(require, 'mappings.settings')
if not settings_status then
  mylog('Failed to load mappings: settings', 'error')
  return
end


-- Fill the rest of line with characters
local function FillLine(ch)
    ch = ch or "-"
    local width = 100
    local line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1
    local line = vim.api.nvim_buf_get_lines(0, line_nr, line_nr + 1, false)[1]

    local line_len = string.len(line)
    vim.api.nvim_buf_set_lines(0, line_nr, line_nr + 1, false,
        { line .. " " .. string.rep(ch, width - line_len - 2) })
end

return {
  { "<leader>ed", "<CMD>Was<CR>", desc = "Development Log" },
  { "<leader>el", "<CMD>lua vim.lsp.codelens.run()<CR>", desc = "CodeLens Action" },
  -- Flash
  { '<leader>efr', "<cmd>lua require('flash').remote()<cr>", desc = 'Remote' },
  { '<leader>eft', "<cmd>lua require('flash').treesitter()<cr>", desc = 'Treesitter' },
  { '<leader>efb', "<cmd>lua require('flash').jump({search = { forward = false, wrap = false, multi_window = false },})<cr>", desc = 'Search Back' },
  { '<leader>eff', "<cmd>lua require('flash').jump({search = { forward = true, wrap = false, multi_window = false },})<cr>", desc = 'Search Forward' },
  { '<leader>efp', "<cmd>lua require('flash').jump({continue = true})<cr>", desc = 'Previous Jump' },
  { '<leader>efs', "<cmd>lua require('flash').jump()<cr>", desc = 'Search' },
  { '<leader>efR', "<cmd>lua require('flash').treesitter_search()<cr>", desc = 'Remote Treesitter' },
  { '<leader>efw', '<cmd>lua require("flash").jump({ pattern = vim.fn.expand("<cword>")})<cr>', desc = 'Current Word' },
  { '<leader>efd', "<cmd>FlashDiagnostics<cr>", desc = 'Diagnostics' },
  -- Fill Line
  { '<leader>eF-', function() FillLine("─") end, desc = 'Fill line with `─` characters' },
  { '<leader>eF=', function() FillLine("━") end, desc = 'Fill line with `━` characters' },
  -- Glance
  { '<leader>egr', "<cmd>Glance resume<cr>", desc = 'Resume' },
  { '<leader>egR', "<cmd>Glance references<cr>", desc = 'References' },
  { '<leader>egd', "<cmd>Glance definitions<cr>", desc = 'Definitions' },
  { '<leader>egi', "<cmd>Glance implementations<cr>", desc = 'Implementations' },
  { '<leader>egt', "<cmd>Glance type_definitions<cr>", desc = 'Type Definitions' },
  -- Cursor Position
  { "<leader>ei", vim.show_pos, desc = "Inspect Position" },
  -- Settings
  settings,
  -- Snacks
  { '<leader>eSd', '<cmd>lua require("snacks").diagnostics.toggle()<cr>', desc = 'Diagnostics: Toggle' },
  { '<leader>eSp', '<cmd>lua require("snacks").profiler.pick()<cr>', desc = 'Profiler: Pick' },
  { '<leader>eSP', '<cmd>lua require("snacks").profiler.toggle()<cr>', desc = 'Profiler: Toggle' },
  { '<leader>eSh', '<cmd>lua require("snacks").notifier.show_history()<cr>', desc = 'Notifications: History' },
  { '<leader>eSg', '<cmd>lua require("snacks").gitbrowse()<cr>', desc = 'Git: Browse' },
  { '<leader>eSs', '<cmd>lua require("snacks").scratch.select()<cr>', desc = 'Scratch: Select' },
  { '<leader>eSl', '<cmd>lua require("snacks").scratch.list()<cr>', desc = 'Scratch: List' },
  { '<leader>et', '<cmd>lua require("snacks").profiler.toggle()<cr>', desc = 'Profiler: Toggle' },
  { '<leader>eP', '<cmd>lua require("snacks").profiler.pick()<cr>', desc = 'Profiler: Pick' },
  -- Noice
  { '<leader>ena', '<cmd>NoiceAll<cr>', desc = 'Noice: All' },
  { '<leader>enc', '<cmd>NoiceConfig<cr>', desc = 'Noice: Config' },
  { '<leader>end', '<cmd>Noice dismiss<cr>', desc = 'Noice: Dismiss' },
  { '<leader>enD', '<cmd>NoiceDebug<cr>', desc = 'Noice: Debug' },
  { '<leader>ene', '<cmd>Noice errors<cr>', desc = 'Noice: Errors' },
  { '<leader>enE', '<cmd>Noice enable<cr>', desc = 'Noice: Enable' },
  { '<leader>enf', '<cmd>NoiceFzf<cr>', desc = 'Noice: FZF' },
  { '<leader>enh', '<cmd>Noice history<cr>', desc = 'Noice: History' },
  { '<leader>enl', '<cmd>Noice last<cr>', desc = 'Noice: Last' },
  { '<leader>enL', '<cmd>NoiceLog<cr>', desc = 'Noice: Log' },
  { '<leader>enp', '<cmd>NoicePick<cr>', desc = 'Noice: Pick' },
  { '<leader>enr', '<cmd>NoiceRoutes<cr>', desc = 'Noice: Routes' },
  { '<leader>ens', '<cmd>Noice stats<cr>', desc = 'Noice: Stats' },
  { '<leader>ent', '<cmd>Noice telescope<cr>', desc = 'Noice: Telescope History' },
  { '<leader>enx', '<cmd>Noice disable<cr>', desc = 'Noice: Disable' },
  { "<leader>eN", "<cmd>Notifications<cr>", desc = "󰵙 Notifications" },
  { '<leader>em', '<cmd>messages<cr>', desc = 'Messages' },
  { '<leader>ep', '<cmd>Lazy<cr>', desc = 'Plugins' },
  -- Lazy
  { '<leader>eLc', '<cmd>Lazy check<cr>', desc = 'Lazy: Check' },
  { '<leader>eLC', '<cmd>Lazy clean<cr>', desc = 'Lazy: Clean' },
  { '<leader>eLd', '<cmd>Lazy debug<cr>', desc = 'Lazy: Debug' },
  { '<leader>eLi', '<cmd>Lazy install<cr>', desc = 'Lazy: Install' },
  { '<leader>eLl', '<cmd>Lazy log<cr>', desc = 'Lazy: Log' },
  { '<leader>eLo', '<cmd>:Lazy<cr>', desc = 'Lazy: Open' },
  { '<leader>eLp', '<cmd>Lazy profile<cr>', desc = 'Lazy: Profile' },
  { '<leader>eLr', '<cmd>Lazy restore<cr>', desc = 'Lazy: Restore' },
  { '<leader>eLs', '<cmd>Lazy sync<cr>', desc = 'Lazy: Sync' },
  { '<leader>eLu', '<cmd>Lazy update<cr>', desc = 'Lazy: Update' },
  -- Custom
  { '<leader>er', "<ESC><C-r><ESC>", desc = 'Redo' },
  { '<leader>ev', "<CMD>lua require('helpers.user.notes').socket_paste()<CR>", desc = 'Socket Paste' },
  { '<leader>ew', "<CMD>lua require('helpers.user.notes').send_to_snuggle()<CR>", desc = 'Send to Snuggle' },
}
