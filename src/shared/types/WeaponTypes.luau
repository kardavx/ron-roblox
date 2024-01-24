export type Weapon = Model & {
	Handle: BasePart,
	Muzzle: BasePart,
}

export type Viewmodel = Model & {
	attachmentNodes: Folder & {
		sight: BasePart,
	},
	weapon: Weapon,
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
