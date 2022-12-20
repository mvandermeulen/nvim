local M = {}

M.autopairs = function()
	local present1, autopairs = pcall(require, "nvim-autopairs")
	local present2, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")

	if not (present1 or present2) then
		return
	end

	autopairs.setup({
		ignored_next_char = string.gsub([[ [%w%%%[%.] ]], "%s+", ""),
	})

	local Rule = require("nvim-autopairs.rule")
	local npairs = require("nvim-autopairs")
	local cond = require("nvim-autopairs.conds")
	npairs.add_rule(Rule("**", "**", "markdown"))
	npairs.add_rule(Rule("$", "$", "tex"))
	npairs.add_rules(
		{
			Rule("'", "'", "python"):with_pair(cond.before_text_check("f")),
		}
		-- Rule("$", "$", 'tex')
		-- Rule("**", "**", "markdown")
	)
	-- not needed if you disable cmp, the above var related to cmp tooo! override default config for autopairs
	local cmp = require("cmp")
	cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end

M.blankline = function()
	require("indent_blankline").setup({
		indentLine_enabled = 1,
		char = "▏",
		filetype_exclude = {
			"help",
			"terminal",
			"dashboard",
			"packer",
			"lspinfo",
			"TelescopePrompt",
			"TelescopeResults",
		},
		buftype_exclude = { "terminal" },
		show_trailing_blankline_indent = false,
		show_first_indent_level = false,
	})
end

M.colorizer = function()
	local present, colorizer = pcall(require, "colorizer")
	if present then
		colorizer.setup({ "*" }, {
			RGB = true, -- #RGB hex codes
			RRGGBB = true, -- #RRGGBB hex codes
			names = false, -- "Name" codes like Blue
			RRGGBBAA = false, -- #RRGGBBAA hex codes
			rgb_fn = false, -- CSS rgb() and rgba() functions
			hsl_fn = false, -- CSS hsl() and hsla() functions
			css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
			css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn

			-- Available modes: foreground, background
			mode = "background", -- Set the display mode.
		})
		vim.cmd("ColorizerReloadAllBuffers")
	end
end

M.comment = function()
	local present, nvim_comment = pcall(require, "Comment")
	if present then
		nvim_comment.setup()
	end
end

M.luasnip = function()
	local present, luasnip = pcall(require, "luasnip")
	if not present then
		return
	end

	luasnip.config.set_config({
		history = true,
		updateevents = "TextChanged,TextChangedI",
	})

	require("luasnip/loaders/from_vscode").load({ paths = {} })
	require("luasnip/loaders/from_vscode").load()
end

M.signature = function()
	local present, lspsignature = pcall(require, "lsp_signature")
	if present then
		lspsignature.setup({
			bind = true,
			doc_lines = 0,
			floating_window = true,
			fix_pos = true,
			hint_enable = true,
			hint_prefix = " ",
			hint_scheme = "String",
			hi_parameter = "Search",
			max_height = 22,
			max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
			handler_opts = {
				border = "single", -- double, single, shadow, none
			},
			zindex = 200, -- by default it will be on top of all floating windows, set to 50 send it to bottom
			padding = "", -- character to pad on left and right of signature can be ' ', or '|'  etc
      -- transparency = 50,
		})
	end
end

M.rnvimr = function()
	vim.g.rnvimr_vanilla = 0
	vim.g.rnvimr_ex_enable = 1
	vim.g.rnvimr_pick_enable = 1
	vim.g.rnvimr_bw_enable = 1
	vim.g.rnvimr_draw_border = 0
	vim.g.rnvimr_border_attr = [['fg':14,'bg': -1]]
	vim.g.rnvimr_shadow_winblend = 70
	vim.api.nvim_exec(
		[[
    let g:rnvimr_ranger_cmd = 'ranger --cmd="set draw_borders both"'
    highlight link RnvimrNormal CursorLine
    let g:rnvimr_action = {'<C-t>': 'NvimEdit tabedit','<C-x>': 'NvimEdit split','<C-v>': 'NvimEdit vsplit','gw': 'JumpNvimCwd','yw': 'EmitRangerCwd'}

    let g:rnvimr_layout = {'relative': 'editor','width': float2nr(round(0.7 * &columns)),'height': float2nr(round(0.7 * &lines)),'col': float2nr(round(0.15 * &columns)),'row': float2nr(round(0.15 * &lines)),'style': 'minimal'}

    let g:rnvimr_presets = [{'width': 0.70, 'height': 0.70},{},{'width': 0.800, 'height': 0.800},{'width': 0.950, 'height': 0.950},{'width': 0.500, 'height': 0.500, 'col': 0, 'row': 0},{'width': 0.500, 'height': 0.500, 'col': 0, 'row': 0.5},{'width': 0.500, 'height': 0.500, 'col': 0.5, 'row': 0},{'width': 0.500, 'height': 0.500, 'col': 0.5, 'row': 0.5},{'width': 0.500, 'height': 1.000, 'col': 0, 'row': 0},{'width': 0.500, 'height': 1.000, 'col': 0.5, 'row': 0},{'width': 1.000, 'height': 0.500, 'col': 0, 'row': 0},{'width': 1.000, 'height': 0.500, 'col': 0, 'row': 0.5}]
  ]],
		false
	)
end

return M
