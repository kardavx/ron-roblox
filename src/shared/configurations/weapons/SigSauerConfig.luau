--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)

local config: WeaponConfigTypes.Config = {
	ViewmodelName = "SigSauer",
	FireRate = 600,
	MaxAmmo = 17,
	Ammo = 17,
	Mags = 10,
	Animations = {
		Idle = 15740848081,
		Shoot = { 15740758462, 15740767803 },
		ShootEmpty = 15740773444,
		Reload = 15740829246,
		Equip = 15740830297,
		Unequip = 15740831957,
		ReloadEmpty = 15746342918,
		Empty = 15746341233,
		LowReady = 15750486825,
		Use = 15740845896,
	},
	RecoilPunch = 0.3,
	AdsZoom = -20,
	AimParts = { "ReflexAimPart" },
	AimSpeed = 10,
	AvailibleFiremodes = { "Semi" },
	FireMode = "Semi",
}

return config
