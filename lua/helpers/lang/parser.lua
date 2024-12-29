--[[
-- Helpers: Parser
--
-- Author: Mark van der Meulen
-- Updated: 2024-12-23
--]]

local M = {}

function M.find_lines_between_separator(lines, pattern, at_least_one)
  local line_count            = #lines
  local separator_line_start  = 1
  local separator_line_finish = line_count
  local found_one             = false

  -- Find the last occurrence of the separator
  for i = line_count, 1, -1 do -- Reverse the loop to start from the end
    local line = lines[i]
    if string.find(line, pattern) then
      if i < (separator_line_finish + 1) and (not at_least_one or found_one) then
        separator_line_start = i + 1
        break -- Exit the loop as soon as the condition is met
      end

      found_one = true
      separator_line_finish = i - 1
    end
  end

  if at_least_one and not found_one then
    return {}, 1, 1, 0
  end

  -- Extract everything between the last and next separator
  local result = {}
  for i = separator_line_start, separator_line_finish do
    table.insert(result, lines[i])
  end

  return result, separator_line_start, separator_line_finish, line_count
end


return M
