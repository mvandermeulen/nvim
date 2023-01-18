local has_fterm, fterm = pcall(require, 'FTerm')
if not has_fterm then
  return
end

local utils = require'fymyte.utils'

fterm.setup {
  border = 'rounded',
}

utils.map { 'n', '<A-i>', '<cmd>lua require("FTerm").toggle()<CR>' }
utils.map { 't', '<A-i>', '<C-\\><C-n><cmd>lua require("FTerm").toggle()<CR>' }



