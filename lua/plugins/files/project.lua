--[[
-- Projects
--
-- Author: Mark van der Meulen
-- Updated: 09-05-2022
--]]

local status_ok, project = pcall(require, 'project_nvim')
if not status_ok then
  return
end


local projects_path = vim.fn.expand(vim.fn.stdpath 'data' .. '/projects')
if vim.fn.isdirectory(projects_path) == 0 then
  vim.fn.mkdir(projects_path, 'p')
end

project.setup {
  active = true,
  on_config_done = nil,
  manual_mode = false,
  ---@usage Methods of detecting the root directory
  --- Allowed values: **"lsp"** uses the native neovim lsp
  --- **"pattern"** uses vim-rooter like glob pattern matching. Here
  --- order matters: if one is not detected, the other is used as fallback. You
  --- can also delete or rearangne the detection methods.
  -- detection_methods = { "lsp", "pattern" }, -- NOTE: lsp detection will get annoying with multiple langs in one project
  detection_methods = { 'pattern' },
  patterns = {
    '.git',
    '.venv',
    -- 'package.json',
    -- '.terraform',
    -- 'go.mod',
    -- 'requirements.yml',
    'pyrightconfig.json',
    -- 'pyproject.toml',
    -- 'Makefile',
    '.is_root_directory',
  },
  show_hidden = false, ---@ Show hidden files in telescope when searching for files in a project
  silent_chdir = false, -- When set to false, you will get a message when project.nvim changes your directory.
  ignore_lsp = {}, ---@usage list of lsp client names to ignore when using **lsp** detection. eg: { "efm", ... }
  datapath = vim.fn.expand(vim.fn.stdpath 'data' .. '/projects'), ---@usage path to store the project history for use in telescope
}

-- local tele_status_ok, telescope = pcall(require, 'telescope')
-- if not tele_status_ok then
--   return
-- end
--
-- telescope.load_extension('projects')
