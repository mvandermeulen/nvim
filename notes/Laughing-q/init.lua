------------------------------------------------------------------------------------
-- ██╗      █████╗ ██╗   ██╗ ██████╗ ██╗  ██╗██╗███╗   ██╗ ██████╗        ██████╗ --
-- ██║     ██╔══██╗██║   ██║██╔════╝ ██║  ██║██║████╗  ██║██╔════╝       ██╔═══██╗--
-- ██║     ███████║██║   ██║██║  ███╗███████║██║██╔██╗ ██║██║  ███╗█████╗██║   ██║--
-- ██║     ██╔══██║██║   ██║██║   ██║██╔══██║██║██║╚██╗██║██║   ██║╚════╝██║▄▄ ██║--
-- ███████╗██║  ██║╚██████╔╝╚██████╔╝██║  ██║██║██║ ╚████║╚██████╔╝      ╚██████╔╝--
-- ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝        ╚══▀▀═╝ --
------------------------------------------------------------------------------------

local core_modules = {
	"autocmds",
	"options",
  "commands",
	"keymappings",
}
pcall(require, "impatient")

for _, module in ipairs(core_modules) do
	local ok, err = pcall(require, module)
	if not ok then
		error("Error loading " .. module .. "\n\n" .. err)
	end
end
require("keymappings").misc()

-- colorscheme
local colorscheme = "tokyonight"
-- plugin global settings
require("plugins.configs.global").setup(colorscheme)

local ok, _ = pcall(require, colorscheme)
if ok then
	vim.cmd("colorscheme " .. colorscheme)
end
