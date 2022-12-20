local title = "A"

return function()
	local buf = vim.api.nvim_buf_get_name(0)

	if buf == "" then
		vim.notify("Empty buffer name", "info", { title = title })
		return
	end

	if vim.fn.system("which alt") == "" then
		vim.notify("Could not find alt", "warn", { title = title })
		return
	end

	local alt = vim.fn.system("alt" .. " " .. buf)

	if alt == "" then
		local msg = "No alternate file" .. " " .. "for" .. buf .. " " .. "exists!"
		vim.notify(msg, "info", { title = title })
	else
		vim.cmd(":edit" .. " " .. alt)
	end
end
