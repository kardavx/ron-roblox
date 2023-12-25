local Animator = {}
Animator.__index = Animator

function Animator.new(animator: Animator)
	local self = setmetatable({}, Animator)
	self.animator = animator
	self.animationTracks = {}

	return self
end

function Animator:LoadAnimations(animations: { any }): boolean
	for animationName, animationInfos: {} in animations do
		task.spawn(function()
			for _, animationInfo in animationInfos do
			end

			for _, id in animationId do
				task.spawn(function()
					local animation = Instance.new("Animation")
					animation.AnimationId = `rbxassetid://{id}`
					local track = viewmodel.Humanoid.Animator:LoadAnimation(animation)
					track.Looped = genericAnimationInfo.Looped
					track.Priority = genericAnimationInfo.Priority
					table.insert(tracks, track)
					animation:Destroy()

					waitForAnimationTrack(id, track)
					loadedAnimationsAmount += 1
				end)
			end

			animations[animationName] = tracks
		end)
	end
	return true
end

function Animator:Destroy() end

return Animator
