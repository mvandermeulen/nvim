local M = {}

---Finds the first element in a list that satisfies a given predicate.
---@param list table The list to search in.
---@param predicate fun(entry: any): boolean The predicate to satisfy.
---@return any|nil: The first element that satisfies the predicate, or nil if no element is found.
function M.find_first(list, predicate)
	for _, entry in pairs(list) do
		if predicate(entry) then return entry end
	end
	return nil
end

---Checks if an element is present in a list.
---@param list table: The list to search in.
---@param element any: The element to search for.
---@return boolean: Returns true if the element is found, false otherwise.
function M.contains(list, element)
	return M.find_first(list, function(e) return e == element end) ~= nil
end

---@param list table
---@param callback fun(entry: any, index: number)
function M.foreach(list, callback)
	for k, v in ipairs(list) do
		callback(v, k)
	end
end

function M.count(list)
	local count = 0
	M.foreach(list, function() count = count + 1 end)
	return count
end

function M.filter(tbl, predicate)
	local filtered = {}
	M.foreach(tbl, function(e)
		if predicate(e) then table.insert(filtered, e) end
	end)
	return filtered
end

function M.count_occurrences(list, element)
	local count = 0
	M.foreach(list, function(e)
		if e == element then count = count + 1 end
	end)
	return count
end

function M.any(list, predicate) return M.find_first(list, predicate) ~= nil end

function M.map(list, callback) return vim.tbl_map(callback, list) end

return M
