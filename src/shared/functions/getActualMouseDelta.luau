local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)

local function getActualMouseDelta(): Vector2
	local freelook = ClassBag:GetClass("freelook")
	if freelook.enabled then
		return Vector2.zero
	end

	return UserInputService:GetMouseDelta()
end

return getActualMouseDelta
