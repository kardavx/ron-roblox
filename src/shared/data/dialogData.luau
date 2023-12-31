local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DialogTypes = require(ReplicatedStorage.Shared.types.DialogTypes)

return {
	SWAT_COOPERATE_01 = {
		Occlusion = "Friendly",
		Text = "Drop to your knees!",
		Name = "SWAT",
	},
} :: { [string]: DialogTypes.DialogData }
