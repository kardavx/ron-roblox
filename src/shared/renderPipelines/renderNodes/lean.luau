local ReplicatedStorage = game:GetService("ReplicatedStorage")

local leanConfig = require(ReplicatedStorage.Shared.configurations.leanConfig)
local ClientPlayerData = require(ReplicatedStorage.Shared.module.ClientPlayerData)
local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local offsetFromPivot = require(ReplicatedStorage.Shared.util.offsetFromPivot)

local Lean: RenderPipelineTypes.NodeClass = {} :: RenderPipelineTypes.NodeClass
Lean.__index = Lean

function Lean.new(): RenderPipelineTypes.NodeObject
	local self = setmetatable({}, Lean)

	self.characterCurrent = CFrame.identity
	self.viewmodelCurrent = CFrame.identity

	return self
end

function Lean:PreUpdate(deltaTime: number, viewmodel: WeaponTypes.Viewmodel, curentAimPart, isAiming, viewmodelInfo)
	if not ClientPlayerData.serverProfile then
		return
	end

	local state = ClientPlayerData.serverProfile:getState()
	local factor = state.leanFactor

	self.viewmodelCurrent = self.viewmodelCurrent:Lerp(
		CFrame.Angles(0, 0, math.rad(leanConfig.leanAngularAmount * factor)),
		leanConfig.leanSpeed * deltaTime
	)
end

function Lean:Update(
	deltaTime: number,
	currentCFrame: CFrame,
	viewmodel: WeaponTypes.Viewmodel,
	viewmodelInfo,
	curentAimPart,
	isAiming
): CFrame
	return currentCFrame * self.viewmodelCurrent
end

return Lean
