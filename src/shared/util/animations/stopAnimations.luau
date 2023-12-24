local function StopAnimations(animationTracks: { [string]: { AnimationTrack } | AnimationTrack }, ...)
	for _, animationTrack in animationTracks do
		if type(animationTrack) == "table" then
			for _, actualTrack in animationTrack do
				actualTrack:Stop(...)
			end
		else
			animationTrack:Stop(...)
		end
	end
end

return StopAnimations
