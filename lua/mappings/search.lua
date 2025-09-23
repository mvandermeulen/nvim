-- local M = {}
-- M.mappings = {
--   name = 'Search',
--   a = { '<cmd>Telescope autocommands<cr>', 'Auto Commands' },
--   b = { '<cmd>Telescope git_branches<cr>', 'Checkout branch' },
--   c = { '<cmd>Telescope commands<cr>', 'Commands' },
--   C = { '<cmd>Telescope colorscheme<cr>', 'Colorscheme' },
--   f = {
--     "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>",
--     'Find files',
--   },
--   h = { '<cmd>Telescope help_tags<cr>', 'Find Help' },
--   H = { '<cmd>Telescope heading<cr>', 'Find Header' },
--   i = { "<cmd>lua require('telescope').extensions.media_files.media_files()<cr>", 'Media' },
--   j = { '<cmd>Telescope jumplist<cr>', 'Jumplist' },
--   k = { '<cmd>Telescope keymaps<cr>', 'Keymaps' },
--   l = { '<cmd>Telescope resume<cr>', 'Last Search' },
--   m = { '<cmd>require("telescope").extensions.macroscope.default()<cr>', 'Macros' },
--   M = { '<cmd>Telescope man_pages<cr>', 'Man Pages' },
--   n = { "<cmd>lua require('telescope').extensions.neoclip.default()<cr>", 'Neoclip' },
--   N = { '<cmd>Telescope notify<cr>', ' Notifications' },
--   p = { '<cmd>Telescope projects<cr>', 'Projects' },
--   P = {
--     "<cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<cr>",
--     'Colorscheme with Preview',
--   },
--   r = { '<cmd>Telescope oldfiles<cr>', 'Recent File' },
--   R = { '<cmd>Telescope registers<cr>', 'Registers' },
--   s = { '<cmd>Telescope grep_string<cr>', 'Text under cursor' },
--   S = { '<cmd>Telescope symbols<cr>', 'Search Emoji' },
--   t = { '<cmd>Telescope live_grep<cr>', 'Text' },
--   T = { '<cmd>Telescope treesitter<cr>', 'Treesitter' },
-- }

--[[
-- Mappings: Search
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

return {
  { '<leader>sa', '<cmd>Telescope autocommands<cr>', desc = 'Auto Commands' },
  { '<leader>sb', '<cmd>Telescope git_branches<cr>', desc = 'Checkout branch' },
  { '<leader>sc', '<cmd>Telescope commands<cr>', desc = 'Commands' },
  { '<leader>sC', '<cmd>Telescope colorscheme<cr>', desc = 'Colorscheme' },
  { '<leader>sf', "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>", desc = 'Find files' },
  { '<leader>sh', '<cmd>Telescope help_tags<cr>', desc = 'Find Help' },
  { '<leader>sH', '<cmd>Telescope heading<cr>', desc = 'Find Header' },
  -- { '<leader>si', "<cmd>lua require('telescope').extensions.media_files.media_files()<cr>", desc = 'Media' },
  { '<leader>sj', '<cmd>Telescope jumplist<cr>', desc = 'Jumplist' },
  { '<leader>sk', '<cmd>Telescope keymaps<cr>', desc = 'Keymaps' },
  { '<leader>sl', '<cmd>Telescope resume<cr>', desc = 'Last Search' },
  { '<leader>sm', '<cmd>require("telescope").extensions.macroscope.default()<cr>', desc = 'Macros' },
  { '<leader>sM', '<cmd>Telescope man_pages<cr>', desc = 'Man Pages' },
  { '<leader>sn', "<cmd>lua require('telescope').extensions.neoclip.default()<cr>", desc = 'Neoclip' },
  { '<leader>sN', '<cmd>Telescope notify<cr>', desc = ' Notifications' },
  { '<leader>sp', '<cmd>Telescope projects<cr>', desc = ' Projects' },
  { '<leader>sP', "<cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<cr>", desc = 'Colorscheme with Preview' },
  { '<leader>sr', '<cmd>Telescope oldfiles<cr>', desc = 'Recent File' },
  { '<leader>sR', '<cmd>Telescope registers<cr>', desc = 'Registers' },
  { '<leader>ss', '<cmd>Telescope grep_string<cr>', desc = 'Text under cursor' },
  { '<leader>sS', '<cmd>Telescope symbols<cr>', desc = 'Search Symbols' },
  { '<leader>st', '<cmd>Telescope live_grep<cr>', desc = 'Text' },
  { '<leader>sT', '<cmd>Telescope treesitter<cr>', desc = 'Treesitter' },
}
