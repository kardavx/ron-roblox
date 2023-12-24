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
		Idle = 15716298491,
		Shoot = { 15716295420, 15716297191 },
		ShootEmpty = 15716274272,
		Reload = 15716299612,
		Equip = 15716283956,
		Unequip = 15716285840,
		ReloadEmpty = 15716291908,
		Empty = 15716293981,
		LowReady = 15735109362,
		Use = 15739698704,
	},
	RecoilPunch = 0.3,
	Offsets = {
		Aim = CFrame.new(-0.25, 0.45, 0.2) * CFrame.Angles(math.rad(-3), math.rad(-2), math.rad(-4)),
	},
	AimSpeed = 10,
	AvailibleFiremodes = { "Semi" },
	FireMode = "Semi",
}

return config
