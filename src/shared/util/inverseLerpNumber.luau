local function inverseLerpNumber(min: number, max: number, number: number)
	return (number - min) / (max - min)
end

return inverseLerpNumber
