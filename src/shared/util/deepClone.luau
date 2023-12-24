local function deepClone<T>(original: T & { [string]: any }): T
	local copy = {}

	for key, value in pairs(original) do
		if type(value) == "table" then
			value = deepClone(value)
		end
		copy[key] = value
	end

	return (copy :: any) :: T
end

return deepClone
