--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientGenericWeaponConfig = require(ReplicatedStorage.Shared.configurations.weapons.ClientGenericWeaponConfig)
local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)

local config: WeaponConfigTypes.Config = {
	ViewmodelName = "USP",
	ConfigName = "USP",
	ServerWeaponType = "Secondary",
	FireRate = 759,
	MaxAmmo = 15,
	Ammo = 15,
	Mags = 10,
	Animations = {
		Idle = 15784160422,
		Shoot = { 15784406280 },
		ShootEmpty = 15784225389,
		Reload = 16094912871,
		Equip = 15784166307,
		Unequip = 15784215352,
		ReloadEmpty = 15784428489,
		MagCheck = 16074349679,
		Empty = 15784282263,
		LowReady = 15784220515,
		Use = 15784231195,
		Radio = 15823284406,
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
	ReloadLength = 1.6,
	RecoilPunch = 0.3,
	ClientScale = 1,
	ServerScale = 1.125,
	AdsZoom = -10,
	AimParts = { "DefaultAimPart" },
	AimSpeed = 8,
	AvailibleFiremodes = { "Semi" },
	FireMode = "Semi",
}

return config
