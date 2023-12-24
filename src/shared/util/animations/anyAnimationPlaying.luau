local function anyAnimationPlaying(animationTracks: { [string]: { AnimationTrack } | AnimationTrack }): boolean
	for _, animationTrack in animationTracks do
		if type(animationTrack) == "table" then
			for _, actualTrack in animationTrack do
				if actualTrack.IsPlaying then
					return true
				end
			end
		else
			if animationTrack.IsPlaying then
				return true
			end
		end
	end

	return false
end

return anyAnimationPlaying
