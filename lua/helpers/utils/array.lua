---@class Array
local Array = Class('Array')

---@param ... any
---@return Array
function Array:initialize(...)
	local temp = { ... }
	if #temp == 0 then return self end

	if #temp == 1 and type(temp[1]) == 'table' then --
		temp = temp[1]
	end

	for _, v in ipairs(temp) do
		self:push(v)
	end
	return self
end

function Array.is_array(element)
	if type(element) ~= 'table' then return false end
	local ok, is_array = pcall(function() return element:is_instance_of(Array) end)

	return ok and is_array
end

function Array:size() return #self end

---@param f fun(e: any, idx?: number)
function Array:foreach(f)
	for k, v in ipairs(self) do
		f(v, k)
	end
end

---@param f fun(e: any, idx?: number): any
function Array:map(f)
	for k, v in ipairs(self) do
		self[k] = f(v, k)
	end
	return self
end

---@param predicate fun(e: any): boolean
function Array:filter(predicate)
	local new_arr = vim.tbl_filter(predicate, self)
	return Array(new_arr)
end

function Array:push(v)
	local size = self:size()
	self[size + 1] = v
	return self
end

function Array:pop()
	local size = self:size()
	local v = self[size]
	self[size] = nil
	return v
end

function Array:shift()
	local size = self:size()
	local v = self[1]
	for i = 1, size - 1 do
		self[i] = self[i + 1]
	end
	self[size] = nil
	return v
end

function Array:join(sep)
	sep = sep or ''
	local res = ''
	for k, v in pairs(self) do
		if k == 1 then
			res = res .. tostring(v)
		else
			res = res .. sep .. tostring(v)
		end
	end
	return res
end

---Finds the first element in a list that satisfies a given predicate.
---@param predicate fun(entry: any): boolean The predicate to satisfy.
---@return any|nil: The first element that satisfies the predicate, or nil if no element is found.
---@return number|nil
function Array:find(predicate)
	for i, entry in ipairs(self) do
		if predicate(entry) then return entry, i end
	end
	return nil
end

---@param value any: The value to search for.
---@return boolean: Whether the array contains the value.
function Array:contains(value)
	return (self:find(function(e) return e == value end) ~= nil)
end

function Array:is_empty() return self:size() == 0 end

function Array:to_table() return { unpack(self) } end

function Array:extend(arr)
	for _, v in ipairs(arr) do
		self:push(v)
	end
	return self
end

function Array:last()
	local size = self:size()
	return self[size]
end

function Array:flatten()
	local result = {}
	for _, sub_table in pairs(self) do
		if type(sub_table) == 'table' then
			for k, v in pairs(sub_table) do
				result[k] = v
			end
		end
	end
	return Array(result)
end

---@alias Array.constructor fun(...): Array
---@type Array|Array.constructor
local _Array = Array
return _Array
