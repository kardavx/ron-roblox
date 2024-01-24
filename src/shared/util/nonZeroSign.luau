local function nonZeroSign(number: number): number
	if number < 0 then
		return -1
	end

	return 1
end

return nonZeroSign
