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
	},
	headMovementModifier = 1,
} :: {
	animationInfo: {
		[WeaponConfigTypes.AnimationsUnion]: {
			Looped: boolean,
			Priority: Enum.AnimationPriority,
		},
	},
	headMovementModifier: number,
}
