--[[
-- Mappings: Editor
-- Author: Mark van der Meulen
-- Updated: 2025-07-15
--]]

local log = require('plenary.log').new({ plugin = 'editor', level = 'debug', use_console = true })
local function mylog(msg, level)
  local level = level or 'debug'
  log.debug(msg)
  if level == 'info' or level == 'warn' or level == 'error' then
    vim.notify(msg, vim.log.levels.INFO, { title = 'editor' })
  end
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


----- <leader>e
----- Mappings: s
local editor_settings = {
  ----- <leader>es
  ----- Mappings: b, l, s, w, h, i, L, v, V, W, r
  { '<leader>esb', '<cmd>:Gitsigns toggle_current_line_blame<cr>', desc = 'Toggle Blame' },
  { '<leader>esl', '<cmd>:Gitsigns toggle_linehl<cr>', desc = 'Toggle modified line highlighting' },
  { '<leader>ess', '<cmd>:Gitsigns toggle_signs<cr>', desc = 'Toggle Git Signs' },
  { "<leader>esw", "<cmd>:Gitsigns toggle_word_diff<CR>", desc = "Toggle Word Diff"},
  { "<leader>esh", "<cmd>:nohlsearch<CR>", desc = "No Highlight" },
  { "<leader>esi", "<CMD>LspToggleInlayHints<CR>", desc = "Toggle Inlay Hints"},
  { '<leader>esL', function() _G.my.settings.toggle_lazy_redraw() end, desc = 'Toggle Lazyredraw' },
  { '<leader>esv', function() _G.my.settings.toggle_virtual_edit() end, desc = 'Toggle virtualedit' },
  { '<leader>esV', function() _G.my.settings.toggle_virtual_text() end, desc = 'LSP: Toggle virtual text of diagnostics' },
  { '<leader>esW', function() _G.my.settings.toggle_word_wrap() end, desc = 'Toggle Word Wrap' },
  { '<leader>esr', function() _G.my.settings:toggle_setting('auto_resize_splits') end, desc = 'Toggle Auto-Splits Resize' },
}

----- <leader>e
----- Mappings: g
local glance_mappings = {
  ----- <leader>eg
  ----- Mappings: d, i, r, R, t
  { '<leader>egd', "<cmd>Glance definitions<cr>", desc = 'Definitions' },
  { '<leader>egi', "<cmd>Glance implementations<cr>", desc = 'Implementations' },
  { '<leader>egr', "<cmd>Glance resume<cr>", desc = 'Resume' },
  { '<leader>egR', "<cmd>Glance references<cr>", desc = 'References' },
  { '<leader>egt', "<cmd>Glance type_definitions<cr>", desc = 'Type Definitions' },
}

----- <leader>e
----- Mappings: S
local snacks_mappings = {
  ----- <leader>eS
  ----- Mappings: d, p, P, h, g, s, l
  { '<leader>eSd', '<cmd>lua require("snacks").diagnostics.toggle()<cr>', desc = 'Diagnostics: Toggle' },
  { '<leader>eSg', '<cmd>lua require("snacks").gitbrowse()<cr>', desc = 'Git: Browse' },
  { '<leader>eSh', '<cmd>lua require("snacks").notifier.show_history()<cr>', desc = 'Notifications: History' },
  { '<leader>eSl', '<cmd>lua require("snacks").scratch.list()<cr>', desc = 'Scratch: List' },
  { '<leader>eSp', '<cmd>lua require("snacks").profiler.pick()<cr>', desc = 'Profiler: Pick' },
  { '<leader>eSs', '<cmd>lua require("snacks").scratch.select()<cr>', desc = 'Scratch: Select' },
  { '<leader>eSt', '<cmd>lua require("snacks").profiler.toggle()<cr>', desc = 'Profiler: Toggle' },
}

----- <leader>e
----- Mappings: L
local lazy_mappings = {
  ----- <leader>eL
  ----- Mappings: c, C, d, i, l, o, p, r, s, u
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
}

----- <leader>e
----- Mappings: f
local flash_mappings = {
  ----- <leader>ef
  ----- Mappings: 
  { '<leader>efr', "<cmd>lua require('flash').remote()<cr>", desc = 'Remote' },
  { '<leader>eft', "<cmd>lua require('flash').treesitter()<cr>", desc = 'Treesitter' },
  { '<leader>efb', "<cmd>lua require('flash').jump({search = { forward = false, wrap = false, multi_window = false },})<cr>", desc = 'Search Back' },
  { '<leader>eff', "<cmd>lua require('flash').jump({search = { forward = true, wrap = false, multi_window = false },})<cr>", desc = 'Search Forward' },
  { '<leader>efp', "<cmd>lua require('flash').jump({continue = true})<cr>", desc = 'Previous Jump' },
  { '<leader>efs', "<cmd>lua require('flash').jump()<cr>", desc = 'Search' },
  { '<leader>efR', "<cmd>lua require('flash').treesitter_search()<cr>", desc = 'Remote Treesitter' },
  { '<leader>efw', '<cmd>lua require("flash").jump({ pattern = vim.fn.expand("<cword>")})<cr>', desc = 'Current Word' },
  { '<leader>efd', "<cmd>FlashDiagnostics<cr>", desc = 'Diagnostics' },
}

----- <leader>e
----- Mappings: n
local noice_mappings = {
  ----- <leader>en
  ----- Mappings: a, c, d, D, e, E, f, h, l, L, p, r, s, t, x
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
}

----- <leader>e
----- Mappings: N, m, p
local custom_mappings = {
  -- Removed CodeLens action on 2025-07-15
  -- { "<leader>el", "<CMD>lua vim.lsp.codelens.run()<CR>", desc = "CodeLens Action" },
  { "<leader>eN", "<cmd>Notifications<cr>", desc = "󰵙 Notifications" },
  { '<leader>em', '<cmd>messages<cr>', desc = 'Messages' },
  { '<leader>ep', '<cmd>Lazy<cr>', desc = 'Plugins' },
}

----- <leader>e
----- Mappings: u
local user_mappings = {
  ----- <leader>eu
  ----- Mappings: d, F, i, r, v, w
  { "<leader>eud", "<CMD>Was<CR>", desc = "Development Log" },
  -- Fill Line
  { '<leader>euF-', function() FillLine("─") end, desc = 'Fill line with `─` characters' },
  { '<leader>euF=', function() FillLine("━") end, desc = 'Fill line with `━` characters' },
  -- Cursor Position
  { "<leader>eui", vim.show_pos, desc = "Inspect Cursor Position" },
  { '<leader>eur', "<ESC><C-r><ESC>", desc = 'Redo' },
  { '<leader>euv', "<CMD>lua require('helpers.user.notes').socket_paste()<CR>", desc = 'Socket Paste' },
  { '<leader>euw', "<CMD>lua require('helpers.user.notes').send_to_snuggle()<CR>", desc = 'Send to Snuggle' },
}


----- <leader>e
----- Mappings: c
local command_mappings = {
  ----- <leader>ec
  ----- Mappings: c, d, e, f, F, p, P, r
  { "<leader>ecc", "<CMD>RLC<CR>", desc = "Current File Reload" },
  { "<leader>ecd", "<CMD>SopsDecrypt<CR>", desc = "[SOPS] Decrypt" },
  { "<leader>ece", "<CMD>SopsEncrypt<CR>", desc = "[SOPS] Encrypt" },
  { "<leader>ecf", "<CMD>Finder<CR>", desc = "Finder" },
  { "<leader>ecF", "<CMD>ShowFilePath<CR>", desc = "File Path" },
  { "<leader>ecp", "<CMD>ShowDirPath<CR>", desc = "Directory Path" },
  { "<leader>ecP", "<CMD>GetPythonPath notify<CR>", desc = "Python Path" },
  { "<leader>ecr", "<CMD>RL<CR>", desc = "Reload" },
  ----- <leader>ect
  ----- Mappings: 3, 4, h, i, t, v
  { "<leader>ect3", "<CMD>NewTabTripleVSplit<CR>", desc = "Triple Vertical Split" },
  { "<leader>ect4", "<CMD>NewTabQuadVSplit<CR>", desc = "Quad Vertical Split" },
  { "<leader>ecth", "<CMD>NewTabHSplit<CR>", desc = "Horizontal Split" },
  { "<leader>ecti", "<CMD>TabInfo<CR>", desc = "Info" },
  { "<leader>ectv", "<CMD>NewTabVSplit<CR>", desc = "Vertical Split" },
  { "<leader>ectt", "<CMD>NewTabTiled<CR>", desc = "Tiled" },
  -- { "<leader>ecr", "<CMD><CR>", desc = "" },
}

----- <leader>e
----- Mappings: C
local copy_mappings = {
  ----- <leader>eC
  ----- Mappings: p
  { "<leader>eCp", "<CMD>GetPythonPath copy<CR>", desc = "Python Path" },
}



----- <leader>e
----- Mappings: c, C, g, L, m, n, N, p, s, S
return {
  -- Custom: <leader>eN <leader>em <leader>ep
  custom_mappings,
  -- User: <leader>eu
  user_mappings,
  -- Flash: <leader>ef
  -- flash_mappings,
  -- Glance: <leader>eg
  glance_mappings,
  -- Settings: <leader>es
  editor_settings,
  -- Snacks: <leader>eS
  snacks_mappings,
  -- Noice: <leader>en
  noice_mappings,
  -- Lazy: <leader>eL
  lazy_mappings,
  -- Command: <leader>ec
  command_mappings,
  -- Copy: <leader>eC
  copy_mappings,
}
