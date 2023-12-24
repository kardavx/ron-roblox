local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GenericWeaponConfig = require(ReplicatedStorage.Shared.configurations.weapons.GenericWeaponConfig)
local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local getAmountOfAnimations = require(ReplicatedStorage.Shared.util.animations.getAmountOfAnimations)
local getDictionaryLength = require(ReplicatedStorage.Shared.util.getDictionaryLength)

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

local function loadAnimations(
	animationConfig: WeaponConfigTypes.Config,
	viewmodel: WeaponTypes.Viewmodel
): { [WeaponConfigTypes.AnimationsUnion]: AnimationTrack }
	local animations = {}

	if not animationConfig.Animations then
		error(`what`)
	end

	local expectedAnimationsAmount = getAmountOfAnimations(animationConfig.Animations)
	local loadedAnimationsAmount = 0

	for animationName, animationId: { number } | number in animationConfig.Animations do
		task.spawn(function()
			local genericAnimationInfo = GenericWeaponConfig.animationInfo[animationName]

			if type(animationId) == "table" then
				local tracks = {}

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
			else
				task.spawn(function()
					local animation = Instance.new("Animation")
					animation.AnimationId = `rbxassetid://{animationId}`
					animations[animationName] = viewmodel.Humanoid.Animator:LoadAnimation(animation)
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
