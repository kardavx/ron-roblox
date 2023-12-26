local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)

type LocalProperties = {} & GameTypes.ClientMethods<LocalProperties>

local HumanoidStateAdjuster = {}

function HumanoidStateAdjuster:AdjustStates(humanoid: Humanoid)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
end

return HumanoidStateAdjuster
