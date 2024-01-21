local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local cameraModifier = require(ReplicatedStorage.Shared.classes.camera.cameraModifier)
local headAnimationConfig = require(ReplicatedStorage.Shared.configurations.headAnimationConfig)

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

	local x, y, z = neck.Transform:ToOrientation()

	self.cameraModifier:SetTarget(
		CFrame.Angles(
			z * headAnimationConfig.HeadMovementMultiplier,
			x * headAnimationConfig.HeadMovementMultiplier,
			y * headAnimationConfig.HeadMovementMultiplier
		),
		6
	)
end

return HeadAnimations
