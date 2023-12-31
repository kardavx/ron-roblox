local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DialogTypes = require(ReplicatedStorage.Shared.types.DialogTypes)

return {
	SWAT_COOPERATE_01 = {
		Occlusion = "Friendly",
		Text = "Drop to your knees!",
		Name = "SWAT",
	},
	TOC_ARRESTED_RESONSE_01 = {
		Occlusion = "Friendly",
		Text = "Copy that element, we'll send some folks to pick them up",
		Name = "TOC",
	},
	TOC_ARRESTED_RESONSE_02 = {
		Occlusion = "Friendly",
		Text = "Copy that, trailers inbound",
		Name = "TOC",
	},
	TOC_ARRESTED_RESONSE_03 = {
		Occlusion = "Friendly",
		Text = "Roger, trailers on their way",
		Name = "TOC",
	},
	TOC_PREFIX_01 = {
		Occlusion = "Friendly",
		Text = "TOC to Entry team",
		Name = "TOC",
	},
	TOC_PREFIX_02 = {
		Occlusion = "Friendly",
		Text = "Entry team, this is TOC",
		Name = "TOC",
	},
	TOC_PREFIX_03 = {
		Occlusion = "Friendly",
		Text = "Hey guys, this is TOC",
		Name = "TOC",
	},
} :: { [string]: DialogTypes.DialogData }
