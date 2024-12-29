local lsputils_status, lsputils = pcall(require, 'config.lsp.utils')
if not lsputils_status then
  print('Error loading helper: lsputils')
  vim.notify('Error loading helpers: lsputils', vim.log.levels.ERROR)
  return M
end


local util_status, utils = pcall(require, 'helpers.utils')
if not util_status then
  print('Error loading helper: utils')
  vim.notify('Error loading helpers: utils', vim.log.levels.ERROR)
  return M
end

local conf_path = vim.fn.stdpath("config") .. "/pyproject.toml"

local lint_ignore = {
  "F541",
  "F401",
  "E401",
  "E701",
  "F841",
  "E722",
}


return {
  enabled = false,
  single_file_support = true,
  filetypes = { "python" },
  root_dir = function(fname)
    return utils.root_pattern(lsputils.root_files) or vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
  end,
  settings = {
    -- https://github.com/charliermarsh/ruff-lsp#settings
    interpreter = { lsputils.get_python_path() },
    organizeImports = false,
    configuration = conf_path,
    configurationPreferences = 'filesystemFirst',
    showSyntaxErrors = true,
    fixAll = false,
    codeAction = {
      disableRuleComment = { enable = true },
      fixViolation = { enable = true },
    },
    lineLength = 120,
    lint = {
      enable = true,
      preview = true,
      ignore = lint_ignore,
    },
  },
  cmd = { "ruff", "server", "--preview" },
  on_new_config = function(config, new_workspace)
    local python_path = lsputils.get_python_path(new_workspace)
    local new_workspace_name = utils.to_workspace_name(new_workspace)

    if python_path == "python" then
      local msg = "LSP python (ruff-lsp) - keeping previous python path '%s' for new_root_dir '%s'"
      vim.notify(msg:format(config.cmd[1], new_workspace), vim.log.levels.DEBUG)
      return config
    else
      local msg = "LSP python (ruff-lsp) - '%s' using path %s"
      vim.notify(msg:format(new_workspace_name, python_path), vim.log.levels.DEBUG)

      config.settings.interpreter = { python_path }
      return config
    end
  end,
}
