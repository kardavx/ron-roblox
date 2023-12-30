local function randomBoolean(chance: number?): boolean
	return math.random(1, chance or 2) == 1
end

return randomBoolean
