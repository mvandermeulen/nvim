--[[
-- Helper: Keys
--
-- Author: Mark van der Meulen
-- Updated: 2024-09-21
--]]

local M = {}

function M.send(keys, options)
    local mode = options.mode

    if mode == nil then
        vim.api.nvim_err_writeln("Sending keys requires mode")
        return
    end

    options.mode = nil

    if mode == "n" then
        local opts = vim.tbl_extend("keep", options, {
            from_part = true,
            do_lt = true,
            special = true,
        })

        local tc = vim.api.nvim_replace_termcodes(keys, opts.from_part, opts.do_lt, opts.special)

        vim.api.nvim_feedkeys(tc, mode, false)
    elseif mode == "x" then
        local opts = vim.tbl_extend("keep", options, {
            from_part = true,
            do_lt = false,
            special = true,
        })

        local tc = vim.api.nvim_replace_termcodes(keys, opts.from_part, opts.do_lt, opts.special)

        vim.api.nvim_feedkeys(tc, mode, false)
    elseif mode == "t" then
        vim.api.nvim_feedkeys(keys, mode, false)
    else
        vim.api.nvim_err_writeln("Unexpected mode")
    end
end

---Wrapper around vim.keymap.set that will
---not create a keymap if a lazy key handler exists.
---It will also set `silent` to true by default.
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts vim.keymap.set.Opts?
function M.safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler

  local modes = type(mode) == "string" and { mode } or mode
  ---@cast modes string[]

  ---@param m string
  modes = vim.tbl_filter(function(m)
    return not (keys.have and keys:have(lhs, m))
  end, modes)

  -- do not create the keymap if a lazy keys handler exists
  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end


---@alias KeymapSpec [string,function,vim.keymap.set.Opts?]
---@class RepeatablePairSpec
---@field next KeymapSpec
---@field prev KeymapSpec
---
---@param modes string|string[]
---@param specs RepeatablePairSpec
function M.map_repeatable_pair(modes, specs)
  local map = M.safe_keymap_set
  local next_repeat, prev_repeat = M.make_repeatable_move_pair { next = specs.next[2], prev = specs.prev[2] }
  map(modes, specs.next[1], next_repeat, specs.next[3])
  map(modes, specs.prev[1], prev_repeat, specs.prev[3])
end

---@class Moves
---@field next function
---@field prev function
---@param moves Moves
---@return function
---@return function
function M.make_repeatable_move_pair(moves)
  local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
  local next_repeat, prev_repeat = ts_repeat_move.make_repeatable_move_pair(moves.next, moves.prev)
  return next_repeat, prev_repeat
end



return M
