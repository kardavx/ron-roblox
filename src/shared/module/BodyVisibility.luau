local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OOPTypes = require(ReplicatedStorage.Shared.types.OOPTypes)

type LocalProperties = {
	character: Model?,
}

local BodyVisibility = {} :: OOPTypes.ClientClassMethods<LocalProperties>

local allowedBodyParts = {
	"Left Leg",
	"Right Leg",
	"Torso",
}

local allowedAccesories = {
	"BodyFrontAttachment",
	"BodyBackAttachment",
	"WaistFrontAttachment",
	"WaistCenterAttachment",
	"WaistBackAttachment",
}

function BodyVisibility:UpdateCharacter(character)
	self.character = character
end

function BodyVisibility:Update(deltaTime: number)
	if not self.character then
		return
	end

	for _, descendant: Instance in self.character:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end

		if table.find(allowedBodyParts, descendant.Name) then
			descendant.LocalTransparencyModifier = 0
		else
			if descendant.Name == "Handle" then
				local attachment = descendant:FindFirstChildOfClass("Attachment")

				if attachment and table.find(allowedAccesories, attachment.Name) then
					descendant.LocalTransparencyModifier = 0
				else
					descendant.LocalTransparencyModifier = 1
				end
			else
				descendant.LocalTransparencyModifier = 1
			end
		end
	end
end

return BodyVisibility
