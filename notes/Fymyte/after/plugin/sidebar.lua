if vim.g.started_by_firenvim then
  return
end

local has_sidebar, sidebar = pcall(require, 'sidebar-nvim')
if not has_sidebar then
  return
end

sidebar.setup {
  disable_default_keybindings = 0,
  bindings = nil,
  open = false, -- Default window status at startup
  side = "left",
  initial_width = 30,
  hide_statusline = true,
  update_interval = 1000,
  section_separator = "──────",
  disable_closing_prompt = true,
  datetime = {
    format = "%a %b %d, %H:%M",
    clocks = { { name = "local" } }
  },
  git = {
    icon = "",
  },
  diagnostics = {
    icon = "",
  },
  containers = {
    icon = "",
    use_podman = false,
    attach_shell = "/bin/sh",
    show_all = true, -- whether to run `docker ps` or `docker ps -a`
    interval = 5000, -- the debouncer time frame to limit requests to the docker daemon
  },
  todos = {
    ignored_paths = { "~" }
  },
  buffers = {
    icon = "",
  },
  files = {
    icon = "",
    show_hidden = false,
  },
  symbols = {
    icon = "ƒ",
  },
  sections = { 'datetime', 'git', 'diagnostics', 'todos' },
}
