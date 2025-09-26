return {
  'echasnovski/mini.comment',
  event = 'VeryLazy',
  version = '*',
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-comment.md
  opts = {
    options = {
      -- Function to compute custom 'commentstring' (optional)
      custom_commentstring = nil,

      -- Whether to ignore blank lines when commenting
      ignore_blank_line = true,

      -- Whether to ignore blank lines in actions and textobject
      start_of_line = false,

      -- Whether to force single space inner padding for comment parts
      pad_comment_parts = true,
    },

    mappings = {
      -- Toggle comment (like `gcip` - comment inner paragraph) for both
      -- Normal and Visual modes
      -- comment = 'gc',
      comment = '<A-c>',

      -- Toggle comment on current line
      -- comment_line = 'gcc',
      comment_line = '<A-c>',

      -- Toggle comment on visual selection
      -- comment_visual = 'gc',
      comment_visual = '<A-c>',

      -- Define 'comment' textobject (like `dgc` - delete whole comment block)
      -- Works also in Visual mode if mapping differs from `comment_visual`
      textobject = 'gc',
    },
  },
}
