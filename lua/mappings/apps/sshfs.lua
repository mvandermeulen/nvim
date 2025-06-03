--[[
-- Mappings: SSHFS
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

return {
  { "<leader>asc", "<cmd>RemoteSSHFSConnect<cr>", desc = "Connect" },
  { "<leader>asd", "<cmd>RemoteSSHFSDisconnect<cr>", desc = "Disconnect" },
  { "<leader>ase", "<cmd>RemoteSSHFSEdit<cr>", desc = "Edit" },
  { "<leader>asf", "<cmd>RemoteSSHFSFindFiles<cr>", desc = "Find Files" },
  { "<leader>asg", "<cmd>RemoteSSHFSLiveGrep<cr>", desc = "Live Grep" },
}
