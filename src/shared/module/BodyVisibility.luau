local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)
local mergeArrays = require(ReplicatedStorage.Shared.util.mergeArrays)

type LocalProperties = {
	character: Model?,
}

local BodyVisibility = {} :: GameTypes.ClientMethods<LocalProperties>

local baseAllowedBodyParts = {
	"Left Leg",
	"Right Leg",
	"Torso",
}

local noWeaponAllowedBodyParts = {
	"Right Arm",
	"Left Arm",
}

local baseAllowedAccesories = {
	"BodyFrontAttachment",
	"BodyBackAttachment",
	"WaistFrontAttachment",
	"WaistCenterAttachment",
	"WaistBackAttachment",
}

local noWeaponAllowedAccesories = {
	"GloveAttachment",
	"WatchAttachment",
}

function BodyVisibility:UpdateCharacter(character)
	self.character = character
end

function BodyVisibility:Update(deltaTime: number, isWeaponEquipped: boolean)
	if not self.character then
		return
	end

	local bodyPartsTable = (
		isWeaponEquipped == true and baseAllowedBodyParts
		or mergeArrays(baseAllowedBodyParts, noWeaponAllowedBodyParts)
	)

	local accesoriesTable = (
		isWeaponEquipped == true and baseAllowedAccesories
		or mergeArrays(baseAllowedAccesories, noWeaponAllowedAccesories)
	)

	for _, descendant: Instance in self.character:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end

		descendant.LocalTransparencyModifier = 1

		if table.find(bodyPartsTable, descendant.Name) then
			descendant.LocalTransparencyModifier = 0
		else
			local attachment = descendant:FindFirstChildOfClass("Attachment")

			if attachment and table.find(accesoriesTable, attachment.Name) then
				descendant.LocalTransparencyModifier = 0
			else
				descendant.LocalTransparencyModifier = 1
			end
		end
	end
end

return BodyVisibility
