local function scaleTrackToLength(track: AnimationTrack, length: number): number
	if track.Length == 0 then
		local waitStartedTick = tick()
		repeat
			if tick() - waitStartedTick > 10 then
				error(`Couldn't load animation {track} in 10 seconds!`)
			end
			task.wait()
		until track.Length > 0
	end

	local baseLength = track.Length
	track:AdjustSpeed(baseLength / length)
	return baseLength / length
end

return scaleTrackToLength
