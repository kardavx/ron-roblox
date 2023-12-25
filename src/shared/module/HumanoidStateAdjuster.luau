local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OOPTypes = require(ReplicatedStorage.Shared.types.OOPTypes)

type LocalProperties = {} & OOPTypes.ClientClassMethods<LocalProperties>

local HumanoidStateAdjuster = {}

function HumanoidStateAdjuster:AdjustStates(humanoid: Humanoid)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
end

return HumanoidStateAdjuster
