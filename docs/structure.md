
## Configuration Structure

The init.lua file is the where the entire high level configuration reside. This file works as follows:

1. Sets leader to `<space>` and log level to `warn`
2. Creates global `_G.my = {}`
3. Sets UI config in global variable `_G`: `_G.my.ui = { theme = 'rose-pine', bg = 'dark' }`
4. Loads Plugin: impatient.nvim
5. Loads config module: plugins
6. Loads config module: settings
7. Loads config module: mappings
8. Sets the colorscheme


