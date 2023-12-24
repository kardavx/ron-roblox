local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local playAnimation = require(ReplicatedStorage.Shared.util.animations.playAnimation)
local chooseRandomFromArray = require(ReplicatedStorage.Shared.util.chooseRandomFromArray)

local function onAnimationEnded(animationTrack: { AnimationTrack } | AnimationTrack, func: () -> (), ...)
	local actualAnimationTrack: AnimationTrack

	if type(animationTrack) == "table" then
		actualAnimationTrack = chooseRandomFromArray(animationTrack)
	else
		actualAnimationTrack = animationTrack
	end

	if actualAnimationTrack.Length == 0 then
		repeat
			RunService.Heartbeat:Wait()
		until actualAnimationTrack.Length > 0
	end

	playAnimation(actualAnimationTrack, ...)
	task.delay(actualAnimationTrack.Length, func)
end

return onAnimationEnded
