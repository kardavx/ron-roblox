local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerGenericWeaponConfig = require(ServerScriptService.configurations.ServerGenericWeaponConfig)
local weaponAnimations = require(ServerScriptService.configurations.weaponAnimations)
local findConfig = require(ReplicatedStorage.Shared.functions.weapon.findConfig)
local loadAnimations = require(ReplicatedStorage.Shared.functions.weapon.loadAnimations)
local rigWeaponToCharacter = require(ReplicatedStorage.Shared.functions.weapon.rigWeaponToCharacter)
local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local onCustomLengthAnimationEneded = require(ReplicatedStorage.Shared.util.animations.onCustomLengthAnimationEneded)
local playAnimation = require(ReplicatedStorage.Shared.util.animations.playAnimation)
local playAnimationIfNotPlaying = require(ReplicatedStorage.Shared.util.animations.playAnimationIfNotPlaying)
local scaleTrackToLength = require(ReplicatedStorage.Shared.util.animations.scaleTrackToLength)
local stopAnimation = require(ReplicatedStorage.Shared.util.animations.stopAnimation)
local Maid = require(ReplicatedStorage.package.Maid)

local weaponsStorage = ReplicatedStorage.Weapons :: Folder

export type Class = {
	__index: Class,
	new: (character: Model, weaponName: string, animationPack: weaponAnimations.AnimationPack) -> Object,
	SetAiming: (self: Object, aiming: boolean) -> (),
	Shoot: (self: Object) -> (),
	Reload: (self: Object) -> (),
	Destroy: (self: Object) -> (),
}

export type ObjectProperties = {
	aiming: boolean,
	reloading: boolean,

	weaponMaid: Maid.Maid,
	config: WeaponConfigTypes.Config,
	model: WeaponTypes.Weapon,
	animations: { [string]: AnimationTrack | { AnimationTrack } },

	reloadSpeed: number,
}

export type Object = typeof(setmetatable({} :: ObjectProperties, {} :: Class))

local Weapon: Class = {} :: Class
Weapon.__index = Weapon

local function cloneDesiredModel(weaponName: string)
	local desired = weaponsStorage:FindFirstChild(weaponName) :: WeaponTypes.Weapon
	if not desired then
		error(`Couldn't find weapon of name {weaponName}`)
	end

	return desired:Clone()
end

function Weapon.new(character: Model, weaponName: string, animationPack: weaponAnimations.AnimationPack)
	local self: Object = setmetatable({} :: ObjectProperties, Weapon)

	self.aiming = false
	self.reloading = false

	self.weaponMaid = Maid.new()
	self.config = findConfig(weaponName)
	self.model = cloneDesiredModel(self.config.ViewmodelName)

	self.model:ScaleTo(self.config.ServerScale)
	rigWeaponToCharacter(character, self.model)

	local animationList = weaponAnimations[self.config.ServerWeaponType][animationPack]
	self.animations = loadAnimations(
		animationList,
		character :: Model & { Humanoid: Humanoid & { Animator: Animator } },
		ServerGenericWeaponConfig.animationInfo
	)

	self.reloadSpeed = scaleTrackToLength(self.animations.Reload :: AnimationTrack, self.config.ReloadLength)

	playAnimation(self.animations.Idle)
	self.weaponMaid:GiveTask(self.model)

	for _, animationTrack: AnimationTrack | { AnimationTrack } in self.animations do
		if type(animationTrack) == "table" then
			for _, singleTrack in animationTrack do
				self.weaponMaid:GiveTask(function()
					singleTrack:Stop()
					singleTrack:Destroy()
				end)
			end
		else
			self.weaponMaid:GiveTask(function()
				animationTrack:Stop()
				animationTrack:Destroy()
			end)
		end
	end

	return self
end

function Weapon:SetAiming(aiming: boolean)
	self.aiming = aiming
	if aiming then
		playAnimationIfNotPlaying(self.animations.Aim)
		stopAnimation(self.animations.Idle)
	else
		playAnimationIfNotPlaying(self.animations.Idle)
		stopAnimation(self.animations.Aim)
	end
end

function Weapon:Reload()
	if self.reloading then
		return
	end

	self.reloading = true
	self:SetAiming(false)
	self.animations.Reload:AdjustSpeed(self.reloadSpeed)
	onCustomLengthAnimationEneded(self.animations.Reload, function()
		self.reloading = false
	end, self.config.ReloadLength, 0.1, nil, self.reloadSpeed)
end

function Weapon:Shoot()
	if self.reloading then
		return
	end

	local desiredTrack

	if self.aiming then
		desiredTrack = self.animations.AimShoot
	else
		desiredTrack = self.animations.Shoot
	end

	stopAnimation(self.animations.AimShoot, 0)
	stopAnimation(self.animations.Shoot, 0)
	playAnimation(desiredTrack, 0)

	for _, child: Instance in self.model.Muzzle:GetChildren() do
		if child:IsA("ParticleEmitter") then
			child:Emit()
		elseif child:IsA("Sound") then
			child:Play()
		end
	end
end

function Weapon:Destroy()
	self.weaponMaid:Destroy()
end

return Weapon
