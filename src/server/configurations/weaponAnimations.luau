export type WeaponType = "Primary" | "Secondary"
export type AnimationPack = "Trained"

return {
	Primary = {
		Trained = {
			Idle = 15877938100,
			Aim = 15877935129,
			Shoot = 15877940225,
			AimShoot = 15877936656,
			Reload = 15877939303,
		},
	},
	Secondary = {
		Trained = {
			Idle = 15877921832,
			Aim = 15877923422,
			Shoot = 15877924953,
			AimShoot = 15877926753,
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
