--[[
-- Commands: Files
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-25
--]]



local function create_sops_command(action)
  return function()
    local current_file = vim.fn.expand("%")
    local command = string.format("sops %s -i %s", action, current_file)
    vim.fn.system(command)
    vim.cmd("edit!")
  end
end

vim.api.nvim_create_user_command("SopsDecrypt", create_sops_command("-d"), {
  desc = "Decrypt the current file using sops",
  force = false,
})

vim.api.nvim_create_user_command("SopsEncrypt", create_sops_command("-e"), {
  desc = "Encrypt the current file using sops",
  force = false,
})


vim.api.nvim_create_user_command("Finder", function(opts)
  vim.fn.system { "open", opts.fargs[1] or vim.fn.expand("%:p:h") }
end, { nargs = 1 })


local function show_path_to_file()
  local current_path = vim.fn.expand("%:p")
  print("File Path: " .. current_path)
end

local function show_path_of_file()
  local current_path = vim.fn.expand("%:p:h")
  print("Directory Path: " .. current_path)
end

vim.api.nvim_create_user_command("ShowFilePath", show_path_to_file, { nargs = "?" })
vim.api.nvim_create_user_command("ShowDirPath", show_path_of_file, { nargs = "?" })
