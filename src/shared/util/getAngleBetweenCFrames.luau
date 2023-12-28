local ReplicatedStorage = game:GetService("ReplicatedStorage")

local isNan = require(ReplicatedStorage.Shared.util.isNan)

local function getAngleBetweenCFrames(cframeA: CFrame, cframeB: CFrame): number
	local angle = 180 - math.deg(math.acos(cframeA.LookVector:Dot((cframeB.Position - cframeA.Position).Unit)))

	return isNan(angle) and 0 or angle
end

return getAngleBetweenCFrames
