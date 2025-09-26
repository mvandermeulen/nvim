return {
  'lukas-reineke/headlines.nvim',
  opts = {
    markdown = {
      headline_highlights = { 'Headline1', 'Headline2', 'Headline3', 'Headline4', 'Headline5', 'Headline6' },
    },
  },
  config = function(_, opts)
    require('headlines').setup(opts)

    -- Custom highlight definitions
    -- vim.api.nvim_set_hl(0, 'Headline1', { fg = '#FF6C6B', bg = '#1E1E1E', bold = true })
    -- vim.api.nvim_set_hl(0, 'Headline2', { fg = '#98BE65', bg = '#1E1E1E', bold = true })
    -- vim.api.nvim_set_hl(0, 'Headline3', { fg = '#ECBE7B', bg = '#1E1E1E', bold = true })
    -- vim.api.nvim_set_hl(0, 'Headline4', { fg = '#51AFEF', bg = '#1E1E1E', bold = true })
    -- vim.api.nvim_set_hl(0, 'Headline5', { fg = '#C678DD', bg = '#1E1E1E', bold = true })
    -- vim.api.nvim_set_hl(0, 'Headline6', { fg = '#46D9FF', bg = '#1E1E1E', bold = true })

    -- Headline colors (text and darker background)
    local colors = {
      { fg = '#FF6C6B', bg = '#2A1C1C' }, -- red
      { fg = '#98BE65', bg = '#1F2A1C' }, -- green
      { fg = '#ECBE7B', bg = '#2A251C' }, -- yellow
      { fg = '#51AFEF', bg = '#1C2430' }, -- blue
      { fg = '#C678DD', bg = '#2A1C2A' }, -- purple
      { fg = '#46D9FF', bg = '#1A2A2F' }, -- cyan
    }

    for i, c in ipairs(colors) do
      vim.api.nvim_set_hl(0, 'Headline' .. i, {
        fg = c.fg,
        bg = c.bg,
        bold = true,
        -- underline = true,
      })
    end

    -- Code block background
    vim.api.nvim_set_hl(0, 'CodeBlock', {
      bg = '#0a0a0a',
    })

    vim.api.nvim_set_hl(0, 'CodeBlockBorder', {
      fg = '#0a0a0a',
    })
  end,
}

