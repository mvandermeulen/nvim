local M = {}

M.setup = function()
	vim.api.nvim_exec(
		[[
  let g:bullets_enabled_file_types = ['markdown', 'text', 'gitcommit', 'scratch']
  ]],
		false
	)
end
return M
