local M = {}

function M.edit_nvim()
	local dir = "~/.config/nvim"
	require("fzf-lua").files({
        cwd_prompt = false,
        prompt = "Nvim Config > ",
        cmd = "rg --files " .. dir,
        cwd = dir,
    })
end

vim.keymap.set("n", "<leader>ev", '<cmd>lua require"jb.fzf_custom".testies()<cr>')

return M
