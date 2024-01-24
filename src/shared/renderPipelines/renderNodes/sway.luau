local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local getActualMouseDelta = require(ReplicatedStorage.Shared.functions.getActualMouseDelta)
local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)
local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local offsetFromPivot = require(ReplicatedStorage.Shared.util.offsetFromPivot)
local smoothClamp = require(ReplicatedStorage.Shared.util.smoothClamp)
local spring = require(ReplicatedStorage.package.spring)

local Sway: RenderPipelineTypes.NodeClass = {} :: RenderPipelineTypes.NodeClass
Sway.__index = Sway

function Sway.new(): RenderPipelineTypes.NodeObject
	local self = setmetatable({}, Sway)

	self.camera = ClassBag:GetClass("camera", true)
	self.spring = spring.new(Vector3.zero)
	self.spring.Damper = 0.4
	self.spring.Speed = 8

	return self
end

function Sway:PreUpdate()
	local rotationDelta = getActualMouseDelta()
	self.spring:Impulse(Vector3.new(rotationDelta.x / 600, rotationDelta.y / 300))
end

function Sway:Update(
	deltaTime: number,
	currentCFrame: CFrame,
	viewmodel: WeaponTypes.Viewmodel,
	animationInfo,
	currentAimPart: BasePart,
	isAiming: boolean,
	clientScale: number
): CFrame
	return offsetFromPivot(
		currentCFrame
			* CFrame.new(0, (-math.abs(self.spring.Value.x) * 0.5), 0)
			* CFrame.Angles(0, smoothClamp(self.spring.Value.x * 1.2, -0.4, 0.4), 0),
		viewmodel.weapon.Handle.CFrame,
		CFrame.Angles(
			self.spring.Value.y - (math.abs(self.spring.Value.x) * 0.5),
			0,
			smoothClamp(-self.spring.Value.x, -0.3, 0.3)
		)
	)
end

return Sway
