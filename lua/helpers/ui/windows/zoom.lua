local M = {}
M.zoomed = false

function M.toggle_zoom()
  if M.zoomed then
    vim.cmd "wincmd ="
    M.zoomed = false
  else
    vim.cmd "wincmd _"
    vim.cmd "wincmd |"
    M.zoomed = true
  end
end

vim.keymap.set("n", "<leader>wZ", M.toggle_zoom, { noremap = true, silent = true, desc ='Toggle Zoom' })
vim.keymap.set("n", "<C-\">", M.toggle_zoom, { noremap = true, silent = true, desc ='Toggle Zoom' })

return M
