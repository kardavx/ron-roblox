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
		Idle = 15740848081,
		Shoot = { 15740758462, 15740767803 },
		ShootEmpty = 15740773444,
		Reload = 15740829246,
		Equip = 15740830297,
		Unequip = 15740831957,
		ReloadEmpty = 15740829246,
		Empty = 15740773444,
		LowReady = 15740844263,
		Use = 15740845896,
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
