local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)
local getAmountOfAnimations = require(ReplicatedStorage.Shared.util.animations.getAmountOfAnimations)

local cachedTracks: { [string]: KeyframeSequence? } = {}
local activeCachingRequests: { [string]: boolean } = {}

local function cachedGetKeyframeSequence(id: string): KeyframeSequence
	while activeCachingRequests[id] do
		RunService.Heartbeat:Wait()
	end

	local sequence = cachedTracks[id]
	if sequence then
		return sequence:Clone()
	end

	local success, fail = pcall(function()
		activeCachingRequests[id] = true
		sequence = KeyframeSequenceProvider:GetKeyframeSequenceAsync(id)
		activeCachingRequests[id] = false
	end)

	if not success or not sequence then
		warn(`GetKeyframeSequenceAsync() failed for id {id}`)
		warn(fail)

		activeCachingRequests[id] = false
		return cachedGetKeyframeSequence(id)
	end

	cachedTracks[id] = sequence
	return cachedGetKeyframeSequence(id)
end

local function convertKeyframeToFormat(keyframe: Keyframe): { [string]: CFrame }
	local poses = {}

	for _, pose in keyframe:GetDescendants() do
		if not pose:IsA("Pose") then
			continue
		end

		poses[pose.Name] = (pose :: Pose).CFrame
	end

	return poses
end

local function convertKeyframeSequenceToFormat(keyframeSequence: KeyframeSequence): { { [string]: CFrame } }
	local keyframes = {}

	for _, keyframe in keyframeSequence:GetChildren() do
		if not keyframe:IsA("Keyframe") then
			continue
		end

		table.insert(keyframes, convertKeyframeToFormat(keyframe))
	end

	return keyframes
end

local function loadAnimationInformation(animationConfig: WeaponConfigTypes.Config): {
	[WeaponConfigTypes.AnimationsUnion]: { { [string]: CFrame } } | { { { [string]: CFrame } } },
}
	if not animationConfig.Animations then
		error(`what`)
	end

	local animationInfo = {}
	local expectedAnimationsAmount = getAmountOfAnimations(animationConfig.Animations)
	local loadedAnimationsAmount = 0

	for animationName, animationId: { number } | number in animationConfig.Animations do
		task.spawn(function()
			if type(animationId) == "table" then
				local infos = {}

				for _, id: number in animationId do
					task.spawn(function()
						local keyframeSequence = cachedGetKeyframeSequence(`rbxassetid://{id}`)
						table.insert(infos, convertKeyframeSequenceToFormat(keyframeSequence))
						loadedAnimationsAmount += 1
					end)
				end

				animationInfo[animationName] = infos
			else
				task.spawn(function()
					local keyframeSequence = cachedGetKeyframeSequence(`rbxassetid://{animationId}`)
					animationInfo[animationName] = convertKeyframeSequenceToFormat(keyframeSequence)
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
			warn(`Infinite yield possible when loading animation info, have been loading for 5 seconds`)
		end

		task.wait()
	until loadedAnimationsAmount == expectedAnimationsAmount

	return animationInfo
end

return loadAnimationInformation
