--[[
-- Helpers: Github
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-23
--]]


local M = {}

function M.open_git_repo()
  local repo = vim.fn.input "Repository name / URI: "
  if repo ~= "" then
    require("git-dev").open(repo)
  end
end


function M.close_git_repo()
  require("git-dev").close_buffers()
end

function M.clean_git_repo()
  require("git-dev").clean()
end

return M
