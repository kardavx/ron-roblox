local ReplicatedStorage = game:GetService("ReplicatedStorage")

local leanConfig = require(ReplicatedStorage.Shared.configurations.leanConfig)
local ClientPlayerData = require(ReplicatedStorage.Shared.module.ClientPlayerData)
local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)

local Lean: RenderPipelineTypes.NodeClass = {} :: RenderPipelineTypes.NodeClass
Lean.__index = Lean

local leanAmount = 20

function Lean.new(): RenderPipelineTypes.NodeObject
	local self = setmetatable({}, Lean)

	self.characterCurrent = CFrame.identity
	self.viewmodelCurrent = CFrame.identity

	return self
end

function Lean:PreUpdate(deltaTime: number)
	if not ClientPlayerData.serverProfile then
		return
	end

	local state = ClientPlayerData.serverProfile:getState()
	local factor = state.leanFactor

	self.viewmodelCurrent = self.viewmodelCurrent:Lerp(
		CFrame.new(-0.1 * factor, -0.1 * factor, 0) * CFrame.Angles(0, 0, math.rad(leanAmount * factor)),
		leanConfig.leanSpeed * deltaTime
	)
end

function Lean:Update(deltaTime: number, currentCFrame: CFrame, viewmodel: WeaponTypes.Viewmodel): CFrame
	return currentCFrame * self.viewmodelCurrent
end

return Lean
