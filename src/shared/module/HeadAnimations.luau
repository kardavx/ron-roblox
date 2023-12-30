local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local cameraModifier = require(ReplicatedStorage.Shared.classes.camera.cameraModifier)

type LocalProperties = {
	cameraModifier: cameraModifier.Object,
	Update: (self: LocalProperties, deltaTime: number) -> (),
}

local HeadAnimations: LocalProperties = {
	cameraModifier = cameraModifier.new(),
} :: LocalProperties

function HeadAnimations:Update(deltaTime: number)
	if not LocalPlayer.Character then
		self.cameraModifier:SetTarget(CFrame.identity, 0)
		return
	end

	local neck = LocalPlayer.Character:FindFirstChild("Neck", true) :: Motor6D
	if not neck then
		self.cameraModifier:SetTarget(CFrame.identity, 0)
		return
	end

	self.cameraModifier:SetTarget(neck.Transform, 6)
end

return HeadAnimations
