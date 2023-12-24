local ReplicatedStorage = game:GetService("ReplicatedStorage")

local chooseRandomFromArray = require(ReplicatedStorage.Shared.util.chooseRandomFromArray)

local function PlayAnimation(animationTrack: { AnimationTrack } | AnimationTrack, ...)
	local actualAnimationTrack: AnimationTrack

	if type(animationTrack) == "table" then
		actualAnimationTrack = chooseRandomFromArray(animationTrack)
	else
		actualAnimationTrack = animationTrack
	end

	actualAnimationTrack:Play(...)
end

return PlayAnimation
