--[[
-- Code Companion: Adapters
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-26
--]]

return {
  qwen_7b_worker = function()
    return require("codecompanion.adapters").extend("ollama", {
      name = 'qwen',
      env = {
        url = "ml-worker:11434",
      },
      headers = {
        ["Content-Type"] = "application/json",
        -- ["Authorization"] = "Bearer ${api_key}",
      },
      parameters = {
        sync = true,
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
  qwen_7b_mba = function()
    return require("codecompanion.adapters").extend("ollama", {
      name = 'qwen',
      env = {
        url = "mba:11434",
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
  copilot_sonnet = function()
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
        api_key = "cmd:pass show openai/personal/apikey",
      },
    })
  end,
  azure_openai_gpt4 = function()
    return require("codecompanion.adapters").extend("azure_openai", {
      env = {
        api_key = 'cmd:pass show github/personal/apikey_mbp_cli',
        endpoint = 'https://models.inference.ai.azure.com/chat/completions',
      },
      schema = {
        model = {
          default = "gpt-4o",
        }
      },
    })
  end,
  azure_openai_gpt4_mini = function()
    return require("codecompanion.adapters").extend("azure_openai", {
      env = {
        api_key = 'cmd:pass show github/personal/apikey_mbp_cli',
        endpoint = 'https://models.inference.ai.azure.com/chat/completions',
      },
      schema = {
        model = {
          default = "gpt-4o-mini",
        }
      },
    })
  end,
}

