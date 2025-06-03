--[[
-- Mappings: Copilot
-- Author: Mark van der Meulen
-- Updated: 2025-06-03
--]]

return {
  { "<leader>ce", "<cmd>Copilot enable<cr>", desc = "Enable" },
  { "<leader>cd", "<cmd>Copilot disable<cr>", desc = "Disable" },
  { "<leader>ct", "<cmd>Copilot toggle<cr>", desc = "Toggle" },
  { "<leader>cs", "<cmd>Copilot status<cr>", desc = "Status" },
  { "<leader>cv", "<cmd>Copilot version<cr>", desc = "Version" },
  { "<leader>cp", "<cmd>Copilot panel<cr>", desc = "Panel" },
  { "<leader>ca", "<cmd>Copilot auth<cr>", desc = "Auth" },
  { "<leader>cS", "<cmd>Copilot suggestion<cr>", desc = "Suggestion" },
  { "<leader>ca", "<cmd>Copilot attach<cr>", desc = "Attach" },
  { "<leader>cD", "<cmd>Copilot detach<cr>", desc = "Detach" },
-- Copilot Chat: <leader>cc
  { '<leader>cca', "<cmd>CopilotChatAnnotations<CR>", desc = "Add a comment" },
  { "<leader>ccd", "<Cmd>CopilotChatDocs<CR>", desc = "Document code" },
  { '<leader>ccD', "<cmd>CopilotChatDebugInfo<cr>", desc = "Show diff" },
  { '<leader>cce', "<cmd>CopilotChatExplain<cr>", desc = "Explain code" },
  { '<leader>ccf', "<cmd>CopilotChatFixError<cr>", desc = "Fix Error" },
  { "<leader>ccF", "<Cmd>CopilotChatFixDiagnostic<CR>", desc = "Fix diagnostic" },
  { "<leader>ccm", "<Cmd>CopilotChatCommit<CR>", desc = "Write commit message for the change" },
  { "<leader>ccM", "<Cmd>CopilotChatCommitStaged<CR>", desc = "Write commit message for the change in staged"},
  { '<leader>cco', "<cmd>CopilotChatOpen<cr>", desc = "Open chat" },
  { "<leader>ccO", "<Cmd>CopilotChatOptimize<CR>", desc = "Optimize code" },
  { '<leader>ccq', "<cmd>CopilotChatClose<cr>", desc = "Close chat" },
  { '<leader>ccr', "<cmd>CopilotChatRefactor<cr>", desc = "Refactor code" },
  { "<leader>ccR", "<Cmd>CopilotChatReview<CR>", desc = "Review code" },
  { '<leader>ccs', "<cmd>CopilotChatSuggestion<cr>", desc = "Provide suggestion" },
  { "<leader>cct", "<Cmd>CopilotChatTests<CR>", desc = "Generate tests" },
  { '<leader>cct', "<cmd>CopilotChatToggle<cr>", desc = "Toggle chat" },
  { '<leader>ccX', "<cmd>CopilotChatReset<cr>", desc = "Reset chat" },
  -- Custom Prompts
  { "<leader>ccw", "<Cmd>CopilotChatWording<CR>", desc = "Improve wording" },
  -- Models
  { "<leader>cc.", "<Cmd>CopilotChatModels<CR>", desc = "Available Models" },
  { "<leader>cc_", "<Cmd>CopilotChatModel<CR>", desc = "Current Model" },
  { "<leader>ccA", "<cmd>CopilotChatAgents<cr>", desc = "Agents" },
}
