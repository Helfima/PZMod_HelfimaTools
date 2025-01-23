-------------------------------------------------------------------------------
---Use to iterate over a table.
---Returns three values: the `next` function, the table `t`, and nil,
---so that the construction :
---
---    for k,v in spairs(t) do *body* end
---will iterate over all key-value pairs of table `t`.
---
---    for k,v in pairs(t, function(t,a,b) return t[b] > t[a] end) do *body* end
---will iterate over all key-value pairs of table `t` with sorting function.
---
---    for k,v in pairs(t, function(t,a,b) return t[b].level > t[a].level end) do *body* end
---will iterate over all key-value pairs of table `t` with sorting function.
---
---@param t table --table to traverse.
---@param order function ---sort function.
function spairs(t, order)
	---bypass
	if order == nil then return pairs(t) end
	---collect the keys
	local keys = {}
	for k in pairs(t) do keys[#keys+1] = k end

	---if order function given, sort by it by passing the table and keys a, b,
	---otherwise just sort the keys
	pcall(function()
		table.sort(keys, function(a,b) return order(t, a, b) end)
	end)

	---return the iterator function
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end