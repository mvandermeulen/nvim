--[[
-- Mappings: Files
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

return {
  { '<leader>Fa', '<cmd>CopyFileAbsolutePath<cr>', desc = 'Copy Absolute File Path' },
  { '<leader>FA', '<cmd>CopyFileAbsolutePathWithLine<cr>', desc = 'Copy Absolute File Path with Line' },
  { '<leader>Fb', '<cmd>Telescope file_browser<cr>', desc = ' File Browser' },
  { '<leader>Fc', '<cmd>CopyFileRelativePath<cr>', desc = 'Copy Relative File Path' },
  { '<leader>Fe', '<cmd>NvimTreeToggle<cr>', desc = 'Explorer' },
  { '<leader>Ff', '<cmd>NvimTreeFindFile<CR>', desc = 'Find in Tree' },
  { '<leader>Fl', '<cmd>CopyFileRelativePathWithLine<cr>', desc = 'Copy Relative File Path with Line' },
  { '<leader>Fn', '<cmd>CopyFileName<cr>', desc = 'Copy Filename' },
  { '<leader>Fr', '<cmd>Telescope oldfiles<cr>', desc = 'Open Recent File' },
  { '<leader>Fu', '<cmd>CopyAbsolutePath<cr>', desc = 'Copy Absolute Path' },
  { '<leader>Fv', '<cmd>CopyRelativePath<cr>', desc = 'Copy Relative Path' },
}
