local cmd = vim.cmd

-- Add Packer commands because we are not loading it at startup
cmd("silent! command PackerClean lua require 'plugins' require('packer').clean()")
cmd("silent! command PackerCompile lua require 'plugins' require('packer').compile()")
cmd("silent! command PackerInstall lua require 'plugins' require('packer').install()")
cmd("silent! command PackerStatus lua require 'plugins' require('packer').status()")
cmd("silent! command PackerSync lua require 'plugins' require('packer').sync()")
cmd("silent! command PackerUpdate lua require 'plugins' require('packer').update()")

-- bufferline
cmd("silent! command BufferKill lua require('plugins.configs.bufferline').buf_kill('bd') ")
cmd("silent! command BufferCloseAllButCurrent lua require('plugins.configs.bufferline').buf_kill_others('bd') ")
