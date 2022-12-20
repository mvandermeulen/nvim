local g = vim.g

g.dashboard_disable_at_vimenter = 0
g.dashboard_disable_statusline = 1
g.dashboard_default_executive = "telescope"
g.dashboard_custom_header = {
	"                                                                               ",
	"                                                                               ",
	"                                                                               ",
	"██╗      █████╗ ██╗   ██╗ ██████╗ ██╗  ██╗██╗███╗   ██╗ ██████╗        ██████╗ ",
	"██║     ██╔══██╗██║   ██║██╔════╝ ██║  ██║██║████╗  ██║██╔════╝       ██╔═══██╗",
	"██║     ███████║██║   ██║██║  ███╗███████║██║██╔██╗ ██║██║  ███╗█████╗██║   ██║",
	"██║     ██╔══██║██║   ██║██║   ██║██╔══██║██║██║╚██╗██║██║   ██║╚════╝██║▄▄ ██║",
	"███████╗██║  ██║╚██████╔╝╚██████╔╝██║  ██║██║██║ ╚████║╚██████╔╝      ╚██████╔╝",
	"╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝        ╚══▀▀═╝ ",
	"                                                                               ",
	"                                                                               ",
	"                                                                               ",
}

g.dashboard_custom_section = {
	a = { description = { "洛 New File                  SPC f n" }, command = "DashboardNewFile" },
	b = { description = { "  Find File                 SPC f f" }, command = "Telescope find_files" },
  c = { description = { "  Find Word                 SPC f w" }, command = "Telescope live_grep" },
	d = { description = { "  Recents                   SPC f h" }, command = "Telescope oldfiles" },
	e = { description = { "  Bookmarks                 SPC b m" }, command = "Telescope marks" },
	f = { description = { "  Colorscheme               SPC f C" }, command = "Telescope colorscheme" },
}

-- g.dashboard_custom_footer = {
-- 	"   ",
-- }
