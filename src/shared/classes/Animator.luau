local Animator = {}
Animator.__index = Animator

function Animator.new(humanoid: Humanoid)
	local self = setmetatable({}, Animator)
	self.humanoid = humanoid
	self.animationTracks = {}

	return self
end

function Animator:LoadAnimations(animations: { any }): boolean
	for _, animationInfos: {} in animations do
		task.spawn(function()
			for _, animationInfo in animationInfos do
				local animation = Instance.new("Animation")
				animation.AnimationId = `rbxassetid://{animationInfo.Id}`

				local animationTrack = self.humanoid.Animator:LoadAnimation(animation)
				animation:Destroy()

				for property, value in animationInfo do
					if property == "Id" then
						continue
					end

					animationTrack[property] = value
				end

				table.insert(self.animationTracks, animationTrack)
			end
		end)
	end
	return true
end

function Animator:Destroy() end

return Animator
