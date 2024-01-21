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
	| "Radio"
export type AnimationTracks = { [AnimationsUnion]: { AnimationTrack } | AnimationTrack }
export type Animations = { [AnimationsUnion]: { number } | number }

export type Config = {
	ViewmodelName: string,
	ConfigName: string,
	ServerWeaponType: "Primary" | "Secondary",
	FireRate: number,
	MaxAmmo: number,
	Ammo: number,
	Mags: number,
	Animations: Animations?,
	ReloadLength: number,
	RecoilPunch: number,
	AimParts: { string },
	AimSpeed: number,
	ClientScale: number,
	ServerScale: number,
	AdsZoom: number,
	AvailibleFiremodes: { FireModes },
	FireMode: FireModes,
}

return table.freeze({})
