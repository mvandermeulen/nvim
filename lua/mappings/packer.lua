local M = {}

M.mappings = {
  name = ' Packer',
  c = { '<cmd>PackerCompile<cr>', ' Compile' },
  l = { "<CMD>PackerClean<CR>", " Clean" },
  i = { '<cmd>PackerInstall<cr>', ' Install' },
  s = { '<cmd>PackerSync<cr>', 'מּ Sync' },
  S = { '<cmd>PackerStatus<cr>', ' Status' },
  u = { '<cmd>PackerUpdate<cr>', 'ﮮ Update' },
}

M.options = {
  mode = "n",
  silent = true,
  noremap = true,
  prefix = "<leader>/",
  nowait = true,
}

return M

