--[[
-- Colourscheme Configuration
--
-- Author: Mark van der Meulen
-- Updated: 24-04-2022
--]]


-- vim.opt.background='light'
vim.opt.background=_G.my.ui.bg

if vim.fn.has("termguicolors") == 1 then
  vim.opt.termguicolors = true            -- True color support
end

-- Gruvbox settings
vim.g.gruvbox_material_background = "medium" -- hard, soft, medium
vim.g.gruvbox_material_palette = "mix" -- original, mix, material
vim.g.gruvbox_material_enable_italic = 1
vim.g.gruvbox_material_sign_column_background = 'none'

-- set colorscheme
--vim.cmd 'color gruvbox-material'
--vim.cmd("colorscheme " .. (vim.env.NVIM_COLORSCHEME or "onedark"))
--cmd 'colorscheme desert'            -- Put your favorite colorscheme here
--vim.cmd[[colorscheme tokyonight]]
--vim.cmd("colorscheme kanagawa")
--vim.cmd 'colorscheme material'
