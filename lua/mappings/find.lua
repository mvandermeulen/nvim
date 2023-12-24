local M = {}

M.mappings = {
    name = ' Find',
    c = { '<cmd>lua require("fzf-lua").command_history()<cr>', ' Command History' },
    -- c = { '<cmd>Telescope colorscheme<cr>', 'Colorscheme' },
    -- t = { '<cmd>Telescope live_grep theme=ivy<cr>', 'Find Text' },
    -- h = { '<cmd>Telescope help_tags<cr>', 'Help' },
    -- M = { '<cmd>Telescope man_pages<cr>', 'Man Pages' },
    -- R = { '<cmd>Telescope registers<cr>', 'Registers' },
    -- k = { '<cmd>Telescope keymaps<cr>', 'Keymaps' },
    -- C = { '<cmd>Telescope commands<cr>', 'Commands' },
}

M.options = {
  mode = "n",
  silent = true,
  noremap = true,
  prefix = "<leader><leader>",
  nowait = false,
}

return M
