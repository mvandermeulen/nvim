--[[
-- Code Companion: Adapters
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-26
--]]

return {
  qwen = function()
    return require("codecompanion.adapters").extend("ollama", {
      name = 'qwen',
      env = {
        url = "ml-worker:11434",
      },
      schema = {
        name = "qwen2.5-coder",
        model = {
          default = "RobinBially/qwen2.5-coder-16k:7b-instruct-q4_K_M",
        },
        num_ctx = {
          default = 16384,
        },
        num_predict = {
          default = -1,
        },
      },
    })
  end,
  copilot = function()
    return require("codecompanion.adapters").extend("copilot", {
      schema = {
        model = {
          default = "claude-3.5-sonnet",
        },
        max_tokens = {
          default = 195000,
        }
      },
    })
  end,
  openai = function()
    return require("codecompanion.adapters").extend("openai", {
      env = {
        api_key = "OPENAI_API_KEY",
      },
    })
  end,
}

