local ReplicatedStorage = game:GetService("ReplicatedStorage")

local inverseLerpNumber = require(ReplicatedStorage.Shared.util.inverseLerpNumber)

local function clampedInverseLerpNumber(min: number, max: number, number: number)
	return math.clamp(inverseLerpNumber(min, max, number), 0, 1)
end

return clampedInverseLerpNumber
