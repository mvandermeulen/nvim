return {
  'echasnovski/mini.ai',
  -- similar to 'nvim-treesitter/nvim-treesitter-textobjects'
  -- as it also creates 'textobjects'
  -- for functions, arguments, tags etc
  -- and provide a/i (around/inside) + move functionalities for them
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-ai.md
  event = 'VeryLazy',
  version = '*',
  opts = {
    mappings = {
      -- Main textobject prefixes
      around = 'a',
      inside = 'i',

      -- Next/last variants
      around_next = 'an',
      -- like inside the next single quotes
      -- 'vin'
      -- or move inside the bracket
      -- 'vinb'
      inside_next = 'in',
      -- same but for last/prev
      -- like delete around last function
      -- 'dalf'
      around_last = 'al',
      inside_last = 'il',

      -- Move cursor to corresponding edge of `a` textobject
      goto_left = 'g[',
      goto_right = 'g]',
    },

    -- Number of lines within which textobject is searched
    n_lines = 50,

    -- How to search for object (first inside current line, then inside
    -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
    -- 'cover_or_nearest', 'next', 'previous', 'nearest'.
    search_method = 'cover_or_next',

    -- Whether to disable showing non-error feedback
    -- This also affects (purely informational) helper messages shown after
    -- idle time if user input is required.
    silent = false,
  },
}
