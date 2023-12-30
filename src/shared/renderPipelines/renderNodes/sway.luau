local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)
local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local offsetFromPivot = require(ReplicatedStorage.Shared.util.offsetFromPivot)
local spring = require(ReplicatedStorage.package.spring)

local Sway: RenderPipelineTypes.NodeClass = {} :: RenderPipelineTypes.NodeClass
Sway.__index = Sway

function Sway.new(): RenderPipelineTypes.NodeObject
	local self = setmetatable({}, Sway)

	self.camera = ClassBag:GetClass("camera", true)
	self.spring = spring.new(Vector3.zero)
	self.spring.Damper = 0.8
	self.spring.Speed = 15

	return self
end

function Sway:PreUpdate()
	local rotationDelta = self.camera.rotationDelta
	self.spring:Impulse(Vector3.new(rotationDelta.x / 100, rotationDelta.y / 100))
end

function Sway:Update(deltaTime: number, currentCFrame: CFrame, viewmodel: WeaponTypes.Viewmodel): CFrame
	return offsetFromPivot(
		currentCFrame
			* CFrame.new(
				self.spring.Value.x * 3,
				math.abs(self.spring.Value.x) * 0.3,
				-math.abs(self.spring.Value.x) * 0.4
			),
		viewmodel.weapon.Handle.CFrame,
		CFrame.Angles(-self.spring.Value.y, self.spring.Value.x, self.spring.Value.x * 2)
	)
end

return Sway
