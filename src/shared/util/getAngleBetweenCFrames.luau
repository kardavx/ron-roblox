local function getAngleBetweenCFrames(cframeA: CFrame, cframeB: CFrame): number
	return 180 - math.deg(math.acos(cframeA.LookVector:Dot((cframeB.Position - cframeA.Position).Unit)))
end

return getAngleBetweenCFrames
