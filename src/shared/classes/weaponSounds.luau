local ReplicatedStorage = game:GetService("ReplicatedStorage")

local weaponSoundsConfig = require(ReplicatedStorage.Shared.configurations.weaponSoundsConfig)
local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)
local Maid = require(ReplicatedStorage.package.Maid)

export type Class = {
	__index: Class,
	new: (soundIdList: { [WeaponConfigTypes.SoundUnion]: number }, soundAdornee: BasePart) -> Object,
	AttachToAnimations: (self: Object, animations: { [WeaponConfigTypes.AnimationsUnion]: AnimationTrack }) -> (),
	Play: (self: Object, soundName: WeaponConfigTypes.SoundUnion) -> (),
	Destroy: (self: Object) -> (),
}

export type Object = typeof(setmetatable(
	{} :: {
		maid: Maid.Maid,
		sounds: { [WeaponConfigTypes.SoundUnion]: Sound },
		attached: boolean,
	},
	{} :: Class
))

local animationSounds: Class = {} :: Class
animationSounds.__index = animationSounds

local function createSounds(idList: { [WeaponConfigTypes.SoundUnion]: number }, adornee: BasePart): { [string]: Sound }
	local sounds = {}

	for soundName, soundId in idList do
		if sounds[soundName] then
			error(`Sound name duplication at {soundName}, devs pls fix!!!`)
		end

		local sound = Instance.new("Sound")
		sound.SoundId = `rbxassetid://{soundId}`
		sound.Volume = weaponSoundsConfig.soundVolume
		sound.Parent = adornee

		sounds[soundName] = sound
	end

	return sounds
end

function animationSounds.new(soundIdList: { [WeaponConfigTypes.SoundUnion]: number }, soundAdornee: BasePart)
	local self = setmetatable({}, animationSounds)

	self.maid = Maid.new()
	self.attached = false
	self.sounds = createSounds(soundIdList, soundAdornee)

	for _, sound in self.sounds do
		self.maid:GiveTask(sound)
	end

	return self
end

function animationSounds:AttachToAnimations(animations: {
	[WeaponConfigTypes.AnimationsUnion]: AnimationTrack | { AnimationTrack },
})
	if self.attached then
		error(`Animations have been already attached!`)
	end

	self.attached = true
	for _, animationTrack in animations do
		if typeof(animationTrack) == "table" then
			for _, actualAnimationTrack in animationTrack do
				self.maid:GiveTask(
					actualAnimationTrack
						:GetMarkerReachedSignal(weaponSoundsConfig.keyframeEventName)
						:Connect(function(soundName: WeaponConfigTypes.SoundUnion)
							self:Play(soundName)
						end)
				)
			end
		else
			self.maid:GiveTask(
				animationTrack
					:GetMarkerReachedSignal(weaponSoundsConfig.keyframeEventName)
					:Connect(function(soundName: WeaponConfigTypes.SoundUnion)
						self:Play(soundName)
					end)
			)
		end
	end
end

function animationSounds:Play(soundName: WeaponConfigTypes.SoundUnion)
	local desiredSound = self.sounds[soundName]
	if not desiredSound then
		warn(`Attempt to play sound that doesnt exist ({soundName})`)
		return
	end

	desiredSound:Play()
end

function animationSounds:Destroy()
	self.maid:Destroy()
end

return animationSounds
