--[[
-- LSP Server: bashls
--
-- Author: Mark van der Meulen
-- Updated: August 09, 2023
--]]


-- local lsputils_status, lsputils = pcall(require, 'config.lsp.utils')
-- if not lsputils_status then
--   return
-- end


-- local util = require 'lspconfig.util'
-- return function(on_attach)
-- 	return {
-- 		on_attach = function(client, bufnr)
-- 			on_attach(client, bufnr)
-- 		end,
-- 		cmd = { 'bash-language-server', 'start' },
-- 		cmd_env = {
-- 			GLOB_PATTERN = "*@(.sh|.inc|.bash|.command|.zsh)",
-- 		},
-- 		settings = {
-- 			bashIde = {
-- 				globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command|.zsh)',
-- 			},
-- 		},
-- 		filetypes = { "sh", "zsh" },
-- 		root_dir = util.find_git_ancestor,
-- 		single_file_support = true,
-- 	}
-- end
