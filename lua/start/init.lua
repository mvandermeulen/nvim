--[[
-- Neovim Startup
-- Author: Mark van der Meulen
-- Updated: 2024-09-16
--]]


vim.g.mapleader = ' '
vim.g.maplocalleader = ","
vim.g.log_level = 'warn' -- Use this for global debugging

_G.my = require('config.vdm.my')

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local firstload = not (vim.uv or vim.loop).fs_stat(lazypath) 
if firstload then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


local masonpath = vim.fn.stdpath("data") .. "/mason/bin" 
if (vim.uv or vim.loop).fs_stat(masonpath) then
  vim.env.PATH = masonpath .. ":" .. vim.env.PATH
end

if not firstload then
  vim.loader.enable() -- Faster startup
end

_G.my.firstload = firstload
vim.cmd(string.format('set background=%s', _G.my.ui.bg)) -- Finalise UI
