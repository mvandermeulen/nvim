-------------------------------------------------------------------------------
-- File: lua/statusline.lua
-- Author: Fymyte - @Fymyte
-------------------------------------------------------------------------------

--local theme = require('lualine.themes.material')
--theme.normal.c.bg = '#333333'
--local theme = require('material.lualine')

require('lualine').setup({
  options = {
--    theme = theme,
    section_separators = '',
    component_separators = { left = '∣', right = '∣' },
  },
  sections = {
    lualine_b = { 'branch', 'diff', { 'diagnostics', sources={ 'nvim_diagnostic' } } },
  }
})
