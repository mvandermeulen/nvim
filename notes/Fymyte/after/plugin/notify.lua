local ok, notify = pcall(require, 'notify')
if not ok then
  return
end

notify.setup {
  stages = 'slide',
  timeout = 3000,
}

-- Replace standard notification with prettyfied ones
vim.notify = notify
