--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)

local config: WeaponConfigTypes.Config = {
	ViewmodelName = "Glock17",
	FireRate = 600,
	MaxAmmo = 17,
	Ammo = 17,
	Mags = 10,
	Animations = {
		Idle = 15784160422,
		Shoot = { 15784406280 },
		ShootEmpty = 15784225389,
		Reload = 15784174604,
		Equip = 15784166307,
		Unequip = 15784215352,
		ReloadEmpty = 15784428489,
		Empty = 15784282263,
		LowReady = 15784220515,
		Use = 15784231195,
	},
	RecoilPunch = 0.2,
	AdsZoom = -10,
	AimParts = { "DefaultAimPart" },
	AimSpeed = 11,
	AvailibleFiremodes = { "Semi" },
	FireMode = "Semi",
}

return config
