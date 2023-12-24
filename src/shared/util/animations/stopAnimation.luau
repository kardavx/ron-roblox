local function StopAnimation(animationTrack: { AnimationTrack } | AnimationTrack, ...)
	if type(animationTrack) == "table" then
		for _, actualTrack in animationTrack do
			actualTrack:Stop(...)
		end
	else
		animationTrack:Stop(...)
	end
end

return StopAnimation
