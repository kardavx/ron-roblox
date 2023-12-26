local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)

type LocalProperties = {
	character: Model?,
}

local BodyVisibility = {} :: GameTypes.ClientMethods<LocalProperties>

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
