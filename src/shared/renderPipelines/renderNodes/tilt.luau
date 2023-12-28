local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local getMoveDirectionInObjectSpace = require(ReplicatedStorage.Shared.util.getMoveDirectionInObjectSpace)
local offsetFromPivot = require(ReplicatedStorage.Shared.util.offsetFromPivot)

local Tilt: RenderPipelineTypes.NodeClass = {} :: RenderPipelineTypes.NodeClass
Tilt.__index = Tilt

function Tilt.new(): RenderPipelineTypes.NodeObject
	local self = setmetatable({}, Tilt)

	self.target = CFrame.identity
	self.current = CFrame.identity

	return self
end

function Tilt:PreUpdate(deltaTime: number)
	local primaryPart = LocalPlayer.Character.PrimaryPart

	self.target = CFrame.Angles(
		0,
		0,
		math.rad(10 * -getMoveDirectionInObjectSpace().X * math.min(primaryPart.AssemblyLinearVelocity.Magnitude, 1))
	)

	self.current = self.current:Lerp(self.target, 3 * deltaTime)
end

function Tilt:Update(deltaTime: number, currentCFrame: CFrame, viewmodel: WeaponTypes.Viewmodel): CFrame
	return offsetFromPivot(currentCFrame, viewmodel.weapon.Handle.CFrame, self.current)
end

return Tilt
