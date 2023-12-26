export type FireModes = "Auto" | "Semi"

export type AnimationsUnion =
	"Idle"
	| "Shoot"
	| "ShootEmpty"
	| "Reload"
	| "ReloadEmpty"
	| "Empty"
	| "Equip"
	| "Unequip"
	| "LowReady"
	| "Use"
export type AnimationTracks = { [AnimationsUnion]: { AnimationTrack } | AnimationTrack }
export type Animations = { [AnimationsUnion]: { number } | number }
export type Offsets = {
	Aim: CFrame,
}

export type Config = {
	ViewmodelName: string,
	FireRate: number,
	MaxAmmo: number,
	Ammo: number,
	Mags: number,
	Animations: Animations?,
	Offsets: Offsets,
	RecoilPunch: number,
	AimSpeed: number,
	AdsZoom: number,
	AvailibleFiremodes: { FireModes },
	FireMode: FireModes,
}

return table.freeze({})
