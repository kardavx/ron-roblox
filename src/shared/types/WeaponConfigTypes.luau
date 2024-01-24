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
	| "MagCheck"
	| "LowReady"
	| "Use"
	| "Radio"
export type AnimationTracks = { [AnimationsUnion]: { AnimationTrack } | AnimationTrack }
export type Animations = { [AnimationsUnion]: { number } | number }

export type SoundUnion =
	"AimUp"
	| "AimDown"
	| "Click"
	| "Equip"
	| "MagDrop"
	| "MagGrab"
	| "MagIn"
	| "MagOut"
	| "MagPouchIn"
	| "MagPouchOut"
	| "SlidePull"
	| "SlideRelease"
	| "Movement1"
	| "Movement2"

export type Sounds = { [SoundUnion]: number }

export type Config = {
	ViewmodelName: string,
	ConfigName: string,
	ServerWeaponType: "Primary" | "Secondary",
	FireRate: number,
	MaxAmmo: number,
	Ammo: number,
	Mags: number,
	Animations: Animations,
	Sounds: Sounds,
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
