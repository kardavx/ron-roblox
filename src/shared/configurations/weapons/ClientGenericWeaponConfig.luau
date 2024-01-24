local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)
return {
	animationInfo = {
		Idle = {
			Looped = true,
			Priority = Enum.AnimationPriority.Action,
		},
		Shoot = {
			Looped = false,
			Priority = Enum.AnimationPriority.Action2,
		},
		ShootEmpty = {
			Looped = false,
			Priority = Enum.AnimationPriority.Action2,
		},
		Reload = {
			Looped = false,
			Priority = Enum.AnimationPriority.Action2,
		},
		ReloadEmpty = {
			Looped = false,
			Priority = Enum.AnimationPriority.Action2,
		},
		Unequip = {
			Looped = false,
			Priority = Enum.AnimationPriority.Action2,
		},
		Equip = {
			Looped = false,
			Priority = Enum.AnimationPriority.Action2,
		},
		Empty = {
			Looped = true,
			Priority = Enum.AnimationPriority.Action3,
		},
		LowReady = {
			Looped = true,
			Priority = Enum.AnimationPriority.Action,
		},
		Use = {
			Looped = false,
			Priority = Enum.AnimationPriority.Action,
		},
		Radio = {
			Looped = true,
			Priority = Enum.AnimationPriority.Action4,
		},
		MagCheck = {
			Looped = false,
			Priority = Enum.AnimationPriority.Action2,
		},
	},
	genericSounds = {
		AimUp = 4615180894,
		AimDown = 3432364020,
		Click = 743780661,
		Equip = 8169246285,
		MagDrop = 166084088,
		MagGrab = 5750591807,
		MagIn = 4681157223,
		MagOut = 4681158033,
		MagPouchIn = 6276676295,
		MagPouchOut = 4681162356,
		SlidePull = 4631203170,
		SlideRelease = 4631203302,
		Movement1 = 4085850946,
		Movement2 = 4085851292,
	},
	headMovementMultiplier = 1,
	aimingHandleTransformMultiplier = 0.2,
}
