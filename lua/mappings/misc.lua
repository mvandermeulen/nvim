local M = {}

M.mappings = {
    name = 'Misc',
    a = {
      "<cmd>lua require'telegraph'.telegraph({cmd='gitui', how='tmux_popup'})<cr>",
      'Test Telegraph',
    },
    h = { '<cmd>nohlsearch<CR>', 'No Highlight' },
    l = { '<cmd>lua vim.lsp.codelens.run()<cr>', 'CodeLens Action' },
    o = { '<cmd>SymbolsOutline<cr>', 'Outline' },
    p = { '<cmd>PackerSync<cr>', 'מּ  Packer Sync' },
    s = { '<cmd>SymbolsOutline<cr>', 'Toggle SymbolsOutline' },
    u = { '<cmd>UndotreeToggle<cr>', 'Undotree' },
    z = { '<cmd>ZenMode<cr>', 'Toggle ZenMode' },
}

M.options = {
  mode = "n",
  silent = true,
  noremap = true,
  prefix = "<leader><leader>",
  nowait = false,
}

return M

