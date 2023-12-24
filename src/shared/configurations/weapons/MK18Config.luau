--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)

local config: WeaponConfigTypes.Config = {
	ViewmodelName = "MK18",
	FireRate = 600,
	MaxAmmo = 30,
	Ammo = 30,
	Mags = 1,
	Animations = {
		Idle = 15716298491,
		Shoot = { 15716295420, 15716297191 },
		ShootEmpty = 15716274272,
		Reload = 15716299612,
		Equip = 15716283956,
		Unequip = 15716285840,
		ReloadEmpty = 15716291908,
		Empty = 15716293981,
		LowReady = 15735109362,
	},
	RecoilPunch = 0.7,
	Offsets = {
		Aim = CFrame.new(-0.25, 0.45, 0.2) * CFrame.Angles(math.rad(-3), math.rad(-2), math.rad(-4)),
	},
	AimSpeed = 10,
	AvailibleFiremodes = { "Semi", "Auto" },
	FireMode = "Auto",
}

return config
