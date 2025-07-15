local M = {}

-- Configuration
M.config = {
  log_file = vim.fn.stdpath("cache") .. "/nvim_custom.log",
  log_level = vim.log.levels.INFO,
  output_methods = { "print", "notify", "file" },
}

local function write_to_file(message)
  local file = io.open(M.config.log_file, "a")
  if file then
    file:write(os.date("%Y-%m-%d %H:%M:%S") .. " " .. message .. "")
    file:close()
  end
end


-- get length of current word
function M.get_word_length()
    local word = vim.fn.expand "<cword>"
    return #word
end


-- Extract plugin-name:init.lua or plain filename
function M.extract_tag_from_source(source)
  source = source:gsub("\\", "/")
  local file = source:match("[^/]+$") or "<unknown>"
  if file == "init.lua" then
    local module = source:match("/lua/([^/]+)/init%.lua$")
    if module then
      return "@" .. module:gsub("%s+", "_") .. ":init.lua"
    end
  end

  return "@" .. file:gsub("%s+", "_")
end


-- Main log function
-- function M.log(...)
--   local info = debug.getinfo(2, "S")
--   local source = info and info.short_src or "<unknown>"
--   local tag = M.extract_tag_from_source(source)

--   local args = { ... }
--   table.insert(args, 1, tag)

--   M.write(table.concat(args, " "))
-- end


function M.log(message, level, methods)
  level = level or M.config.log_level
  methods = methods or M.config.output_methods

  local formatted_message =
    string.format("[%s] %s", vim.log.levels[level], message)

  for _, method in ipairs(methods) do
    if method == "print" then
      print(formatted_message)
    elseif method == "notify" then
      vim.notify(message, level)
    elseif method == "file" then
      write_to_file(formatted_message)
    end
  end
end

-- Convenience functions for different log levels
function M.debug(message, methods)
  M.log(message, vim.log.levels.DEBUG, methods)
end

function M.info(message, methods)
  M.log(message, vim.log.levels.INFO, methods)
end

function M.warn(message, methods)
  M.log(message, vim.log.levels.WARN, methods)
end

function M.error(message, methods)
  M.log(message, vim.log.levels.ERROR, methods)
end

return M

