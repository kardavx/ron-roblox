local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local offsetFromPivot = require(ReplicatedStorage.Shared.util.offsetFromPivot)
local sine = require(ReplicatedStorage.Shared.util.sine)
local spring = require(ReplicatedStorage.package.spring)

local Bobbing: RenderPipelineTypes.NodeClass = {} :: RenderPipelineTypes.NodeClass
Bobbing.__index = Bobbing

local walkspeedDivider = 1.7
local bobbingMultiplier = 7

function Bobbing.new(): RenderPipelineTypes.NodeObject
	local self = setmetatable({}, Bobbing)

	self.spring = spring.new(Vector3.zero)
	self.spring.Damper = 0.2
	self.spring.Speed = 8

	self.sines = {
		x = sine.new(1, 6, 0, 0.005),
		y = sine.new(1, 12, 0, 0.005),
		z = sine.new(0.1, 18, 0, 0.001),
	}

	return self
end

function Bobbing:PreUpdate(deltaTime: number)
	local movementSway = Vector3.new(self.sines.x:Update(), self.sines.y:Update(), self.sines.z:Update())
	local primaryPart = LocalPlayer.Character.PrimaryPart

	self.sines.x:SetFrequency(1 * LocalPlayer.Character.Humanoid.WalkSpeed / walkspeedDivider)
	self.sines.y:SetFrequency(2 * LocalPlayer.Character.Humanoid.WalkSpeed / walkspeedDivider)
	self.sines.z:SetFrequency(2 * LocalPlayer.Character.Humanoid.WalkSpeed / walkspeedDivider)

	self.spring:Impulse(movementSway * primaryPart.AssemblyLinearVelocity.Magnitude * deltaTime * bobbingMultiplier)
end

function Bobbing:Update(
	deltaTime: number,
	currentCFrame: CFrame,
	viewmodel: WeaponTypes.Viewmodel,
	animationInfo,
	currentAimPart: BasePart,
	isAiming: boolean,
	clientScale: number
): CFrame
	return offsetFromPivot(
		currentCFrame,
		viewmodel.weapon.Handle.CFrame,
		CFrame.new():Lerp(
			CFrame.new(-self.spring.Value.X * 0.5, -self.spring.Value.Y * 1.3, -self.spring.Value.Z * 0.5)
				* CFrame.Angles(self.spring.Value.Y, self.spring.Value.X, self.spring.Value.Z),
			clientScale
		)
	)
end

return Bobbing
