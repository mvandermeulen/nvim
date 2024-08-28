--[[
-- Filetype Plugin
--
-- Author: Mark van der Meulen
-- Updated: 01-05-2023
--]]

local status_ok, ftype = pcall(require, "filetype")
if not status_ok then
  vim.notify = require("notify")
  vim.notify("Failed to load plugin: filetype", "error")
	return
end

ftype.setup {
  overrides = {
    literal = {
      ["kitty.conf"] = "kitty",
      [".gitignore"] = "conf",
    },
    complex = {
      [".clang*"] = "yaml",
      [".*%.env.*"] = "sh",
      [".*ignore"] = "conf",
    },
    extensions = {
      tf = "terraform",
      tfvars = "terraform",
      hcl = "hcl",
      tfstate = "json",
      eslintrc = "json",
      prettierrc = "json",
      mdx = "markdown",
      sh = "sh",
      html = "html",
    },
  },
}
