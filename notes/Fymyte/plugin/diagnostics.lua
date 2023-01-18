vim.diagnostic.config({
  virtual_text = {
    prefix = '●',
    border = 'rounded'
  },
  signs = true,
  underline = true,
  update_in_insert = true,
  severity_sort = false,
  float = { focusable = false },
})

-- Change diagnostic symbols in the sign column
local signs = {
  Error = "",
  Warn = "",
  Hint = "",
  Info = ""
}
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
