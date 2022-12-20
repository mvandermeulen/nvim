local M = {}
local function warn(msg)
    vim.cmd(string.format('echohl WarningMsg | echo "Warning: %s" | echohl None', msg))
end

local terminal_opts = {
	-- size can be a number or function which is passed the current terminal
  size = function(term)
    if term.direction == "horizontal" then
      return 10
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    else
      return 20
    end
  end,
	open_mapping = [[<c-\>]],
	hide_numbers = true, -- hide the number column in toggleterm buffers
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = 2, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
	start_in_insert = true,
	insert_mappings = true, -- whether or not the open mapping applies in insert mode
	persist_size = false,
	-- direction = 'vertical' | 'horizontal' | 'window' | 'float',
	direction = "float",
	close_on_exit = true, -- close the terminal window when the process exits
	shell = vim.o.shell, -- change the default shell
	-- This field is only relevant if direction is set to 'float'
	float_opts = {
		-- The border key is *almost* the same as 'nvim_win_open'
		-- see :h nvim_win_open for details on borders however
		-- the 'curved' border is a custom border type
		-- not natively supported but implemented in this plugin.
		-- border = 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
		border = "curved",
		-- width = <value>,
		-- height = <value>,
		winblend = 0,
		highlights = {
			border = "Normal",
			background = "Normal",
		},
	},
	-- Add executables on the config.lua
	-- { exec, keymap, name}
	-- laughing.builtin.terminal.execs = {{}} to overwrite
	-- laughing.builtin.terminal.execs[#laughing.builtin.terminal.execs+1] = {"gdb", "tg", "GNU Debugger"}
	execs = {
    { "lazygit", "<leader>gg", "LazyGit", "float" },
		-- { "lf", "<leader>.", "f" },
	},
}

M.add_exec = function(opts)
  local binary = opts.cmd:match "(%S+)"
  if vim.fn.executable(binary) ~= 1 then
    warn("Skipping configuring executable " .. binary .. ". Please make sure it is installed properly.")
    return
  end

  local exec_func = string.format(
    "<cmd>lua require('plugins.configs.terminal')._exec_toggle({ cmd = '%s', count = %d, direction = '%s'})<CR>",
    opts.cmd,
    opts.count,
    opts.direction
  )

  -- this will slowdown the startup time.
  -- local wk_status_ok, wk = pcall(require, "which-key")
  -- if not wk_status_ok then
  --   return
  -- end
  -- wk.register({ [opts.keymap] = { exec_func, opts.label } }, { mode = "n" })
  -- wk.register({ [opts.keymap] = { exec_func, opts.label } }, { mode = "t" })

  vim.api.nvim_set_keymap("n", opts.keymap, exec_func, { noremap=true, silent = true })
end

M._exec_toggle = function(opt)
  local Terminal = require("toggleterm.terminal").Terminal
  local term = Terminal:new { cmd = opt.cmd, count = opt.count, direction = opt.direction }
  term:toggle(terminal_opts.size, opt.direction)
end

M.setup = function()
	local terminal = require("toggleterm")
	terminal.setup(terminal_opts)
  for i, exec in pairs(terminal_opts.execs) do
    local opt = {
      cmd = exec[1],
      keymap = exec[2],
      label = exec[3],
      count = i + 1,
      direction = exec[4] or terminal_opts.direction,
      size = terminal_opts.size,
    }
    M.add_exec(opt)
	end
end

return M
