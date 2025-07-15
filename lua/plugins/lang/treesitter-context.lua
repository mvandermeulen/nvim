--[[
-- Treesitter Context Plugin
--
-- Author: Mark van der Meulen
-- Updated: 29-04-2022
--]]

local tscontext = require('treesitter-context')

tscontext.setup{
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to show for a single context
  trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
  on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
}

vim.keymap.set("n", "[s", function() tscontext.go_to_context() end, { silent = true })

-- local status_ok, context = pcall(require, "ts_context_commentstring")
-- if not status_ok then
--   return
-- end

-- context.setup({
-- 	enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
-- 	throttle = true, -- Throttles plugin updates (may improve performance)
-- 	max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
-- 	patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
-- 		-- For all filetypes
-- 		-- Note that setting an entry here replaces all other patterns for this entry.
-- 		-- By setting the 'default' entry below, you can control which nodes you want to
-- 		-- appear in the context window.
-- 		default = {
-- 			"class",
-- 			"function",
-- 			"method",
-- 			-- 'for', -- These won't appear in the context
-- 			-- 'while',
-- 			-- 'if',
-- 			-- 'switch',
-- 			-- 'case',
-- 		},
-- 		-- Example for a specific filetype.
-- 		-- If a pattern is missing, *open a PR* so everyone can benefit.
-- 		--   rust = {
-- 		--       'impl_item',
-- 		--   },
-- 	},
-- 	exact_patterns = {
-- 		-- Example for a specific filetype with Lua patterns
-- 		-- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
-- 		-- exactly match "impl_item" only)
-- 		-- rust = true,
-- 	},
-- })
