local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GenericWeaponConfig = require(ReplicatedStorage.Shared.configurations.weapons.GenericWeaponConfig)
local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)
local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local lerpNumber = require(ReplicatedStorage.Shared.util.lerpNumber)

local Aim: RenderPipelineTypes.NodeClass = {} :: RenderPipelineTypes.NodeClass
Aim.__index = Aim

local function getTransformWithoutIdle(transform: CFrame, idleCFrame: CFrame)
	return CFrame.new():Lerp(transform * idleCFrame:Inverse(), GenericWeaponConfig.aimingHandleTransformMultiplier)
end

function Aim.new(): RenderPipelineTypes.NodeObject
	local self = setmetatable({}, Aim)

	self.camera = ClassBag:GetClass("camera", true)
	self.aimFactor = 0

	return self
end

function Aim:PreUpdate(deltaTime: number, viewmodel: WeaponTypes.Viewmodel, currentAimPart: BasePart, isAiming: boolean)
	self.aimFactor = lerpNumber(self.aimFactor, isAiming and 1 or 0, 10 * deltaTime)
end

function Aim:Update(
	deltaTime: number,
	currentCFrame: CFrame,
	viewmodel: WeaponTypes.Viewmodel,
	animationInfo,
	currentAimPart: BasePart,
	isAiming: boolean
): CFrame
	return currentCFrame
		* CFrame.new():Lerp(
			currentAimPart.CFrame:ToObjectSpace(currentCFrame)
				* getTransformWithoutIdle(viewmodel.HumanoidRootPart.Handle.Transform, animationInfo.Idle[1].Handle),
			self.aimFactor
		)
end

return Aim
