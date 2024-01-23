local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientGenericWeaponConfig = require(ReplicatedStorage.Shared.configurations.weapons.ClientGenericWeaponConfig)
local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)
local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local lerpNumber = require(ReplicatedStorage.Shared.util.lerpNumber)
local offsetFromPivot = require(ReplicatedStorage.Shared.util.offsetFromPivot)
local spring = require(ReplicatedStorage.package.spring)

local Aim: RenderPipelineTypes.NodeClass = {} :: RenderPipelineTypes.NodeClass
Aim.__index = Aim

local function getTransformWithoutIdle(transform: CFrame, idleCFrame: CFrame)
	return CFrame.new()
		:Lerp(transform * idleCFrame:Inverse(), ClientGenericWeaponConfig.aimingHandleTransformMultiplier)
end

function Aim.new(): RenderPipelineTypes.NodeObject
	local self = setmetatable({}, Aim)

	self.camera = ClassBag:GetClass("camera", true)
	self.aimFactor = 0
	self.spring = spring.new(Vector3.zero)
	self.spring.Damper = 1.1
	self.spring.Speed = 8
	self.previousAimingState = false
	self.onAimChanged = function(multiplier: number)
		self.spring:Impulse(Vector3.new(-1 * multiplier, -1 * multiplier, 0))
	end

	return self
end

function Aim:PreUpdate(deltaTime: number, viewmodel: WeaponTypes.Viewmodel, currentAimPart: BasePart, isAiming: boolean)
	if self.previousAimingState ~= isAiming then
		self.onAimChanged(isAiming and 1 or -1)
	end

	self.previousAimingState = isAiming

	self.aimFactor = lerpNumber(self.aimFactor, isAiming and 1 or 0, 10 * deltaTime)
end

function Aim:Update(
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
			* CFrame.new():Lerp(
				currentAimPart.CFrame:ToObjectSpace(currentCFrame)
					* getTransformWithoutIdle(
						viewmodel.HumanoidRootPart.Handle.Transform,
						CFrame.new():Lerp(animationInfo.Idle[1].Handle, clientScale)
					),
				self.aimFactor
			),
		viewmodel.weapon.Handle.CFrame,
		CFrame.new():Lerp(CFrame.Angles(self.spring.Value.Y, self.spring.Value.X, self.spring.Value.Z), clientScale)
	)
end

return Aim
