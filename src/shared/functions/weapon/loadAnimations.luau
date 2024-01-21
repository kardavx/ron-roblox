local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)
local getAmountOfAnimations = require(ReplicatedStorage.Shared.util.animations.getAmountOfAnimations)

local function waitForAnimationTrack(animationId: number, animationTrack: AnimationTrack)
	if animationTrack.Length == 0 and not animationTrack.Looped then
		local waitStartTick = tick()
		local hasWarned = false
		repeat
			if tick() - waitStartTick > 5 and not hasWarned then
				hasWarned = true
				warn(`Infinite yield possible on Animation {animationId}`)
			end
			task.wait()
		until animationTrack.Length > 0
	end
end

local function loadAnimations<T>(
	animationConfig: { [T]: { number } | number },
	adornee: Model & { Humanoid: Humanoid & { Animator: Animator } },
	genericAnimationMap: { [T]: { Looped: boolean, Priority: Enum.AnimationPriority } }
): { [T]: AnimationTrack | { AnimationTrack } }
	local animations = {}

	local expectedAnimationsAmount = getAmountOfAnimations((animationConfig :: any) :: WeaponConfigTypes.Animations)
	local loadedAnimationsAmount = 0

	for animationName, animationId: { number } | number in animationConfig do
		task.spawn(function()
			local genericAnimationInfo = genericAnimationMap[animationName]

			if type(animationId) == "table" then
				local tracks = {}

				for _, id in animationId do
					task.spawn(function()
						local animation = Instance.new("Animation")
						animation.AnimationId = `rbxassetid://{id}`
						local track = adornee.Humanoid.Animator:LoadAnimation(animation)
						track.Looped = genericAnimationInfo.Looped
						track.Priority = genericAnimationInfo.Priority
						table.insert(tracks, track)
						animation:Destroy()

						waitForAnimationTrack(id, track)
						loadedAnimationsAmount += 1
					end)
				end

				animations[animationName] = tracks
			else
				task.spawn(function()
					local animation = Instance.new("Animation")
					animation.AnimationId = `rbxassetid://{animationId}`
					animations[animationName] = adornee.Humanoid.Animator:LoadAnimation(animation)
					animations[animationName].Looped = genericAnimationInfo.Looped
					animations[animationName].Priority = genericAnimationInfo.Priority
					animation:Destroy()

					waitForAnimationTrack(animationId, animations[animationName])
					loadedAnimationsAmount += 1
				end)
			end
		end)
	end

	local waitStartTick = tick()
	local hasWarned = false

	repeat
		if tick() - waitStartTick >= 5 and not hasWarned then
			hasWarned = true
			warn(`Infinite yield possible when loading animations, have been loading for 5 seconds`)
		end
		task.wait()
	until loadedAnimationsAmount == expectedAnimationsAmount

	return animations
end

return loadAnimations
