export type WeaponType = "Primary" | "Secondary"
export type AnimationPack = "Trained"

return {
	Primary = {
		Trained = {
			Idle = 15877938100,
			Aim = 15877935129,
			Shoot = 16066306387,
			AimShoot = 16066298566,
			Reload = 15877939303,
		},
	},
	Secondary = {
		Trained = {
			Idle = 15877921832,
			Aim = 15877923422,
			Shoot = 16066342081,
			AimShoot = 16066337372,
			Reload = 15877928853,
		},
	},
} :: {
	[WeaponType]: {
		[AnimationPack]: {
			Idle: number,
			Aim: number,
			AimShoot: number,
			Shoot: number,
			Reload: number,
		},
	},
}
