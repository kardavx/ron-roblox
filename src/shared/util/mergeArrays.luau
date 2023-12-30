return function<T>(...: T)
	local arrays = { ... }
	local finalArray = {}

	for _, array in arrays do
		for _, value in array do
			table.insert(finalArray, value)
		end
	end

	return finalArray :: { T }
end
