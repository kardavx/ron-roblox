local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SignalBag = require(ReplicatedStorage.Shared.module.SignalBag)
local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local offsetFromPivot = require(ReplicatedStorage.Shared.util.offsetFromPivot)
local spring = require(ReplicatedStorage.package.spring)

local Scream: RenderPipelineTypes.NodeClass = {} :: RenderPipelineTypes.NodeClass
Scream.__index = Scream

function Scream.new(): RenderPipelineTypes.NodeObject
	local self = setmetatable({}, Scream)

	self.spring = spring.new(Vector3.zero)
	self.spring.Damper = 0.26
	self.spring.Speed = 10

	SignalBag:Connect("OnScream", function()
		self.spring:Impulse(Vector3.new(0, -1, 0))
	end)

	return self
end

function Scream:Update(deltaTime: number, currentCFrame: CFrame, viewmodel: WeaponTypes.Viewmodel): CFrame
	return offsetFromPivot(
		currentCFrame,
		viewmodel.weapon.Handle.CFrame,
		CFrame.new(0, self.spring.Value.Y, 0)
			* CFrame.Angles(self.spring.Value.Y * 1.4, -self.spring.Value.Y / 2, -self.spring.Value.Y * 0.8)
	)
end

return Scream
