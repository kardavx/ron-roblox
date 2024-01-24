local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local getMoveDirectionInObjectSpace = require(ReplicatedStorage.Shared.util.getMoveDirectionInObjectSpace)

local Move: RenderPipelineTypes.NodeClass = {} :: RenderPipelineTypes.NodeClass
Move.__index = Move

function Move.new(): RenderPipelineTypes.NodeObject
	local self = setmetatable({}, Move)

	self.target = CFrame.identity
	self.current = CFrame.identity

	return self
end

function Move:PreUpdate(deltaTime: number)
	local primaryPart = LocalPlayer.Character.PrimaryPart

	self.target = CFrame.new():Lerp(
		CFrame.new(0, -0.03, 0.1 * primaryPart.AssemblyLinearVelocity.Magnitude / 6),
		math.min(getMoveDirectionInObjectSpace().Magnitude, 1)
	)
	self.current = self.current:Lerp(self.target, 2 * deltaTime)
end

function Move:Update(
	deltaTime: number,
	currentCFrame: CFrame,
	viewmodel: WeaponTypes.Viewmodel,
	animationInfo,
	currentAimPart: BasePart,
	isAiming: boolean,
	clientScale: number
): CFrame
	return currentCFrame * CFrame.new():Lerp(self.current, clientScale)
end

return Move
