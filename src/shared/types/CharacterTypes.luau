export type Dummy = Model & {
	Humanoid: Humanoid & {
		HumanoidDescription: HumanoidDescription,
		Animator: Animator,
	},
	PrimaryPart: BasePart,
	Head: BasePart,
	Torso: BasePart,
	["Left Arm"]: BasePart,
	["Right Arm"]: BasePart,
	["Left Leg"]: BasePart,
	["Right Leg"]: BasePart,
	HumanoidRootPart: BasePart,
}

return table.freeze({})
