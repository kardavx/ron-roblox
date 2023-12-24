export type Viewmodel = Model & {
	weapon: Model & {
		Handle: BasePart,
		Muzzle: BasePart,
	},
	Humanoid: Humanoid & {
		Animator: Animator,
	},
	FakeCamera: BasePart,
	HumanoidRootPart: BasePart & {
		FakeCamera: Motor6D,
		Handle: Motor6D,
	},
	LeftArm: BasePart,
	RightArm: BasePart,
}

return table.freeze({})
