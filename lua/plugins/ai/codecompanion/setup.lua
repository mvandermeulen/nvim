--[[
-- Code Companion: Setup
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-26
--]]


local codecompanion = {}

-- Ref: [Snippet to add the ability to saveload CodeCompanion chats in neovim](https://gist.github.com/itsfrank/942780f88472a14c9cbb3169012a3328)
codecompanion.setup_save_load = function()
  -- require("vimrc.profile").setup()
  -- require("plug.config_cache").setup()

  -- add 2 commands:
  --    CodeCompanionSave [space delimited args]
  --    CodeCompanionLoad
  -- Save will save current chat in a md file named 'space-delimited-args.md'
  -- Load will use a telescope filepicker to open a previously saved chat

  -- create a folder to store our chats
  local Path = require("plenary.path")
  local data_path = vim.fn.stdpath("data")
  local save_folder = Path:new(data_path, "cc_saves")
  if not save_folder:exists() then
    save_folder:mkdir({ parents = true })
  end

  -- telescope picker for our saved chats
  vim.api.nvim_create_user_command("CodeCompanionLoad", function()
    local t_builtin = require("telescope.builtin")
    local t_actions = require("telescope.actions")
    local t_action_state = require("telescope.actions.state")

    local function start_picker()
      t_builtin.find_files({
        prompt_title = "Saved CodeCompanion Chats | <c-d>: delete",
        cwd = save_folder:absolute(),
        attach_mappings = function(_, map)
          map("i", "<c-d>", function(prompt_bufnr)
            local selection = t_action_state.get_selected_entry()
            local filepath = selection.path or selection.filename
            os.remove(filepath)
            t_actions.close(prompt_bufnr)
            start_picker()
          end)
          return true
        end,
      })
    end
    start_picker()
  end, {})

  -- save current chat, `CodeCompanionSave foo bar baz` will save as 'foo-bar-baz.md'
  vim.api.nvim_create_user_command("CodeCompanionSave", function(opts)
    local cc = require("codecompanion")
    local success, chat = pcall(function()
      return cc.buf_get_chat(0)
    end)
    if not success or chat == nil then
      vim.notify(
        "CodeCompanionSave should only be called from CodeCompanion chat buffers",
        vim.log.levels.ERROR
      )
      return
    end
    if #opts.fargs == 0 then
      vim.notify("CodeCompanionSave requires at least 1 arg to make a file name", vim.log.levels.ERROR)
    end
    local save_name = table.concat(opts.fargs, "-") .. ".md"
    local save_path = Path:new(save_folder, save_name)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    save_path:write(table.concat(lines, "\n"), "w")
  end, { nargs = "*" })
end

codecompanion.setup_autocmd = function()
  -- TODO: Make this work with CopilotChat.nvim & Avante.nvim without duplicating code
  -- Trick to make copilot.lua work with CodeCompanion
  local augroup_id = vim.api.nvim_create_augroup("codecompanion_settings", {})
  vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    group = augroup_id,
    pattern = "*",
    callback = function()
      if vim.bo.filetype == "codecompanion" then
        vim.opt.buflisted = true
        vim.opt.buftype = ""
        -- vim.cmd("Copilot enable")
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "InsertLeave" }, {
    group = augroup_id,
    pattern = "*",
    callback = function()
      if vim.bo.filetype == "codecompanion" then
        vim.opt.buflisted = false
        vim.opt.buftype = "nofile"
      end
    end,
  })
end

codecompanion.setup = function()
  codecompanion.setup_save_load()
  codecompanion.setup_autocmd()
end

return codecompanion
