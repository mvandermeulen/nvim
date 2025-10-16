-- Python-specific configuration and keybindings

-- Auto-detect virtual environments
vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    -- Reload LSP servers when changing projects
    vim.cmd("LspRestart")
    
    -- Update UV project context
    if vim.fn.filereadable("pyproject.toml") == 1 then
      vim.g.current_uv_project = vim.fn.getcwd()
    end
  end,
})

-- Python-specific keybindings grouped by functionality
local function setup_python_keymaps()
  local wk = require("which-key")
  
  wk.add({
    { "<leader>p", group = "Python" },
    { "<leader>pr", "<cmd>!python %<cr>", desc = "Run Python File" },
    { "<leader>pi", "<cmd>!python -i %<cr>", desc = "Interactive Python" },
    { "<leader>pt", "<cmd>!python -m pytest<cr>", desc = "Run Tests" },
    { "<leader>pf", "<cmd>!python -m pytest %<cr>", desc = "Test Current File" },
    
    -- UV package management
    { "<leader>x", group = "UV" },
    { "<leader>xa", "<cmd>UVAdd<cr>", desc = "Add Package" },
    { "<leader>xd", "<cmd>UVRemove<cr>", desc = "Remove Package" },
    { "<leader>xr", "<cmd>UVRun<cr>", desc = "UV Run" },
    { "<leader>xi", "<cmd>UVInit<cr>", desc = "Init Project" },
    { "<leader>xs", "<cmd>UVSync<cr>", desc = "Sync Dependencies" },
    { "<leader>xv", "<cmd>UVStatus<cr>", desc = "UV Status" },
  })
end

-- Setup keymaps when which-key is available
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  callback = function(event)
    if event.data == "which-key.nvim" then
      setup_python_keymaps()
    end
  end,
})

-- Python file settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 88
    vim.opt_local.colorcolumn = "89"
  end,
})