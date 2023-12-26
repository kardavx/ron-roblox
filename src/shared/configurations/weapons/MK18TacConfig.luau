--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)

local config: WeaponConfigTypes.Config = {
	ViewmodelName = "MK18_TACTICAL",
	FireRate = 780,
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
		LowReady = 15757539020,
		Use = 15757536137,
	},
	RecoilPunch = 0.7,
	Offsets = {
		Aim = CFrame.new(-0.7, 0.14, 0),
	},
	AdsZoom = -60,
	AimSpeed = 7,
	AvailibleFiremodes = { "Semi", "Auto" },
	FireMode = "Auto",
}

return config
