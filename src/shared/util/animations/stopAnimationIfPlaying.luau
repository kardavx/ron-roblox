local function stopAnimationIfPlaying(animationTrack: { AnimationTrack } | AnimationTrack, ...)
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

	if type(animationTrack) == "table" then
		for _, actualTrack in animationTrack do
			actualTrack:Stop(...)
		end
	else
		animationTrack:Stop(...)
	end
end

return stopAnimationIfPlaying
