local function forEach<T>(array: { T }, func: (element: T) -> ())
	for _, element in array do
		task.spawn(function()
			func(element)
		end)
	end
end

return forEach
