local function getDictionaryLength(dictionary): number
	local length = 0

	for _, _ in dictionary do
		length += 1
	end

	return length
end

return getDictionaryLength
