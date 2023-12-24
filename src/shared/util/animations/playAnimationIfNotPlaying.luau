local ReplicatedStorage = game:GetService("ReplicatedStorage")

local chooseRandomFromArray = require(ReplicatedStorage.Shared.util.chooseRandomFromArray)

local function playAnimationIfNotPlaying(animationTrack: { AnimationTrack } | AnimationTrack, ...)
	if type(animationTrack) == "table" then
		for _, actualTrack in animationTrack do
			if actualTrack.IsPlaying then
				return
			end
		end
	else
		if animationTrack.IsPlaying then
			return
		end
	end

	local actualAnimationTrack: AnimationTrack

	if type(animationTrack) == "table" then
		actualAnimationTrack = chooseRandomFromArray(animationTrack)
	else
		actualAnimationTrack = animationTrack
	end

	actualAnimationTrack:Play(...)
end

return playAnimationIfNotPlaying
