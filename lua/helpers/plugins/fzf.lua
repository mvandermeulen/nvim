--[[
-- FZF: Helpers
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-26
--]]

local fzf_lua = require("fzf-lua")
local utils = require('helpers.utils')
local Path = require('helpers.utils.path')
local fzf_config = require('helpers.plugins.fzf_config')


local M = {}

local function make_fzf_dir()
  if utils.is_monorepo() then
    return utils.find_root_dir(vim.loop.cwd(), { "package.json" })
  else
    return utils.find_root_dir(vim.loop.cwd(), { ".git" })
  end
end

---@class FzfFileEntry
---@field filename string
---@field lnum number
---@field col number
---@field text string

---@param entries table<string>
---@param opts table<any>
---@return table<FzfFileEntry>
local function parse_entries(entries, opts)
  return vim.tbl_map(function(entry)
    local file = fzf_lua.path.entry_to_file(entry, opts)
    local text = entry:match(":%d+:%d?%d?%d?%d?:?(.*)$")
    return {
      filename = file.bufname or file.path,
      lnum = file.line,
      col = file.col,
      text = text,
    }
  end, entries)
end


local function fn_selected_multi(selected, opts)
  if not selected then
    return
  end

  -- first element of "selected" is the keybind pressed
  if #selected <= 2 then
    fzf_lua.actions.act(opts.actions, selected, opts)
  else -- here we multi-selected ("select-all+accept" on fzf lua view point)
    local _, entries = fzf_lua.actions.normalize_selected(opts.actions, selected, {})
    entries = parse_entries(entries, opts)

    vim.fn.setqflist(entries, "r")
    vim.cmd("cfirst")

    -- local function action_choice_on_multiselect()
    --   local multiselect_actions = {
    --     "Open occurrences in qf list",
    --     "Open unique files in qf list",
    --   }
    --   vim.ui.select(
    --     multiselect_actions,
    --     { prompt = "FZF Actions (multi select)> " },
    --     function(choice, idx)
    --       vim.cmd("stopinsert")

    --       log.debug("fzf multi select: ", choice)

    --       if idx == 2 then
    --         local seen = {}
    --         entries = vim.tbl_filter(function(entry)
    --           if vim.tbl_contains(seen, entry.filename) then
    --             return false
    --           else
    --             table.insert(seen, entry.filename)
    --             return true
    --           end
    --         end, entries)
    --       end

    --       vim.fn.setqflist(entries, "r")
    --       vim.cmd("cfirst")
    --     end
    --   )
    -- end
  end
end

--
---------- Grep ----------
--
-- Fzf Grep
function M.fzf_grep(cwd)
  require("fzf-lua").grep({
    cwd = cwd or make_fzf_dir(),
    search = "",
    fn_selected = fn_selected_multi,
  })
end

-- Live Grep
function M.live_grep(cwd)
  fzf_lua.live_grep({
    cwd = cwd or make_fzf_dir(),
    fn_selected = fn_selected_multi,
  })
end

-- Fzf Grep word under cursor
function M.grep_word_under_cursor()
  vim.cmd([[normal! "wyiw]])
  local word = vim.fn.getreg('"')
  fzf_lua.grep({
    cwd = make_fzf_dir(),
    search = word,
    fn_selected = fn_selected_multi,
  })
end

---------- Files ----------
function M.rg_files(rg_opts, cwd)
  -- local rg_cmd = ("rg %s --files --hidden %s"):format(rg_opts or "", rg_ignore_arg)
  local rg_cmd = (fzf_config.files_custom_rg_cmd):format(rg_opts or "", fzf_config.rg_ignore_arg)
  return fzf_lua.fzf_exec(rg_cmd, {
    prompt = "Files > ",
    multiprocess = fzf_config.files_config.multiprocess,
    previewer = "builtin",
    cwd = cwd or make_fzf_dir(),
    actions = fzf_config.files_actions,
    fn_transform = function(x)
      return fzf_lua.make_entry.file(x, { file_icons = true, color_icons = true })
    end,
  })
end

---------- LSP ----------
-- lsp issue with tips and tricks: https://github.com/ibhagwan/fzf-lua/issues/441
function M.lsp_references()
  fzf_lua.lsp_references({
    async = true,
    file_ignore_patterns = { "miniconda3", "node_modules" }, -- ignore references in env libs
  })
end

--
------- VDM files -------

function M.my_files()
  local home = vim.env.HOME
  local abs_paths = vim.tbl_map(function(path)
    return home .. "/" .. path
  end, fzf_config.fzf_custom_paths.my_files_config)
  local cmd = ("rg --hidden %s --files %s"):format(fzf_config.rg_ignore_arg, table.concat(abs_paths, " "))
  return fzf_lua.fzf_exec(cmd, {
    prompt = "MyFiles > ",
    previewer = "builtin",
    cwd = vim.env.HOME,
    cwd_prompt = false,
    actions = fzf_config.files_actions,
    fn_transform = function(x)
      return fzf_lua.make_entry.file(x, { file_icons = true, color_icons = true })
    end,
  })
end

-- Alternative implementation using `fzf_lua.files`
function M.my_files_alt()
  local home = vim.env.HOME
  local abs_paths = vim.tbl_map(function(path)
    return home .. "/" .. path
  end, fzf_config.fzf_custom_paths.my_files_config)
  local mycmd = ("rg --hidden %s --files %s"):format(fzf_config.rg_ignore_arg, table.concat(abs_paths, " "))
  require("fzf-lua").files({
    cwd_prompt = false,
    prompt = "My Files > ",
    cmd = mycmd,
    cwd = vim.env.HOME,
  })
end






------- Project Select first -------
local function pick_project(fn)
  local src_path = Path.home():join("projects")

  local projects = vim.tbl_filter(function(path)
    return path:is_directory()
  end, src_path:ls())

  projects = vim.tbl_map(function(path)
    return (path:make_relative(src_path)).path
  end, projects)

  vim.ui.select(projects, { prompt = "Select project> " }, function(choice, _)
    vim.cmd("stopinsert")
    if choice then
      fn(src_path:join(choice):absolute())
    end
  end)
end

function M.select_project_find_file()
  -- if is_monorepo() then
  --   return fzf_grep(find_root_dir(vim.loop.cwd(), { ".git" }))
  -- else
  return pick_project(function(path)
    fzf_lua.files({ cwd = path })
  end)
end

function M.select_project_fzf_grep()
  -- if is_monorepo() then
  --   return live_grep(find_root_dir(vim.loop.cwd(), { ".git" }))
  -- else
  return pick_project(function(path)
    fzf_lua.grep({ cwd = path, search = "" })
  end)
end


function M.edit_nvim()
  local dir = "~/resources/configs/nvim"
  require("fzf-lua").files({
        cwd_prompt = false,
        prompt = "Nvim Config > ",
        cmd = "rg --files " .. dir,
        cwd = dir,
    })
end





-- return {
--   -- grep
--   fzf_grep = fzf_grep,
--   live_grep = live_grep,
--   grep_word_under_cursor = grep_word_under_cursor,
--   -- files
--   rg_files = rg_files,
--   -- lsp
--   lsp_references = lsp_references,
--   -- custom
--   my_files = my_files,
--   select_project_find_file = select_project_find_file,
--   select_project_fzf_grep = select_project_fzf_grep,
-- }

return M
