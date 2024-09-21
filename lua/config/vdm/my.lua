M = {}

M.plugins = {}
M.plugins.themes = require('config.vdm.theme-plugins')
M.ui = { theme = 'catpuccin-mocha', bg = 'dark' }
M.helpers = {
  venv_paths_added = {},
}

return M
