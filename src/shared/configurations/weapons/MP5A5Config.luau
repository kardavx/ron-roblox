--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientGenericWeaponConfig = require(ReplicatedStorage.Shared.configurations.weapons.ClientGenericWeaponConfig)
local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)

local config: WeaponConfigTypes.Config = {
	ViewmodelName = "MP5A5",
	ConfigName = "MP5A5",
	ServerWeaponType = "Primary",
	FireRate = 800,
	MaxAmmo = 30,
	Ammo = 30,
	Mags = 10,
	Animations = {
		Idle = 15757497815,
		Shoot = { 15758492225, 15758498739 },
		ShootEmpty = 15758506191,
		Reload = 15757521652,
		Equip = 15757510671,
		Unequip = 15757515092,
		ReloadEmpty = 15757528097,
		MagCheck = 16074349679,

		LowReady = 15757539020,
		Use = 15757536137,
		Radio = 15823314705,
	},
	Sounds = {
		AimUp = ClientGenericWeaponConfig.genericSounds.AimUp,
		AimDown = ClientGenericWeaponConfig.genericSounds.AimDown,
		Click = ClientGenericWeaponConfig.genericSounds.Click,
		Equip = ClientGenericWeaponConfig.genericSounds.Equip,
		MagDrop = ClientGenericWeaponConfig.genericSounds.MagDrop,
		MagGrab = ClientGenericWeaponConfig.genericSounds.MagGrab,
		MagIn = ClientGenericWeaponConfig.genericSounds.MagIn,
		MagOut = ClientGenericWeaponConfig.genericSounds.MagOut,
		MagPouchIn = ClientGenericWeaponConfig.genericSounds.MagPouchIn,
		MagPouchOut = ClientGenericWeaponConfig.genericSounds.MagPouchOut,
		SlidePull = ClientGenericWeaponConfig.genericSounds.SlidePull,
		SlideRelease = ClientGenericWeaponConfig.genericSounds.SlideRelease,
		Movement1 = ClientGenericWeaponConfig.genericSounds.Movement1,
		Movement2 = ClientGenericWeaponConfig.genericSounds.Movement2,
	},
	ReloadLength = 4.25,
	RecoilPunch = 0.3,
	ClientScale = 1,
	ServerScale = 1,
	AdsZoom = -20,
	AimParts = { "IronAimPart" },
	AimSpeed = 13,
	AvailibleFiremodes = { "Semi", "Auto" },
	FireMode = "Auto",
}

return config
