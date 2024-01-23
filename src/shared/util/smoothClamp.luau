local function smoothClamp(x: number, a: number, b: number): number
	local t = math.clamp(x, a, b)
	return t ~= x and t or (b + (a - b) / (1 + math.exp(((b - a) * (3 * x - a - b)) / ((x - a) * (b - x)))))
end

return smoothClamp
