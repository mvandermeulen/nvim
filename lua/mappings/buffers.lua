--[[
-- Mappings: Buffers
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

return {
  { '<leader>bb', "<CMD>lua require'telescope.builtin'.buffers({ sort_mru = true, ignore_current_buffer = true })<CR>", desc = 'Find buffer' },
  { '<leader>ba', '<CMD>BufferLineCloseLeft<CR><CMD>BufferLineCloseRight<CR>', desc = 'Close All but current' },
  { '<leader>bc', "<CMD>BufferLinePickClose<CR>", desc = "Pick Close" },
  -- { '<leader>bc', "<CMD>BufferLinePickClose<CR>", desc = " Pick close" },
  -- { '<leader>bd', '<CMD>TSContextDisable<CR><CMD>TSBufDisable rainbow<CR><CMD>TSBufDisable highlight<CR><CMD>Bdelete<CR>', desc = 'Close Buffer' },
  { '<leader>bd', '<CMD>BufferDelete<CR>', desc = 'Delete Buffer' },
  { '<leader>be', '<CMD>!chmod +x %<CR>', desc = 'Make Executable' },
  { '<leader>bf', '<CMD>BufferLinePick<CR>', desc = ' Pick buffer' },
  { '<leader>bg', "<CMD>BufferLineGroupClose<CR>", desc = "  Group close" },
  { '<leader>bl', '<CMD>BufferLineCloseLeft<CR>', desc = ' Close left' },
  { '<leader>bp', '<CMD>BufferLineMovePrev<CR>', desc = ' Move previous' },
  { '<leader>bn', '<CMD>BufferLineMoveNext<CR>', desc = ' Move next' },
  { '<leader>bq', '<CMD>BufferLineCloseRight<CR>', desc = ' Close right' },
  { '<leader>br', '[[:%s/<<C-r><C-w>>/<C-r><C-w>/gI<Left><Left><Left>]]', desc = 'Replace' },
  { '<leader>bR', '<CMD>:lua vim.lsp.buf.rename()<CR>', desc = 'Rename' },
  { '<leader>bs', '<CMD>noautocmd w<CR>', desc = 'Save no autocmd' },
  { '<leader>bS', '<CMD>setlocal winfixbuf<CR>', desc = 'Sticky Buffer' },
  { '<leader>bP', '<CMD>PinBuffer<CR>', desc = ' 󰐃 Pin Buffer' },
  -- Sort
  { '<leader>bsd', "<CMD>BufferLineSortByDirectory<CR>", desc = " Directory" },
  { '<leader>bst', "<CMD>BufferLineSortByTabs<CR>", desc = "Tabs" },
  { '<leader>bse', "<CMD>BufferLineSortByExtension<CR>", desc = "  Extension" },
  { '<leader>bsr', "<CMD>BufferLineSortByRelativeDirectory<CR>", desc = " Relative Directory" },
}
