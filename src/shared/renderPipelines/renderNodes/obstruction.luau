local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrentCamera = require(ReplicatedStorage.Shared.CurrentCamera)
local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)
local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local lerpNumber = require(ReplicatedStorage.Shared.util.lerpNumber)

local Obstruction: RenderPipelineTypes.NodeClass = {} :: RenderPipelineTypes.NodeClass
Obstruction.__index = Obstruction

function Obstruction.new(): RenderPipelineTypes.NodeObject
	local self = setmetatable({}, Obstruction)

	self.camera = ClassBag:GetClass("camera", true)
	self.obstructionAmount = 0
	self.params = RaycastParams.new()
	self.params.FilterType = Enum.RaycastFilterType.Exclude
	self.obstructionOffsetMultiplier = -1

	return self
end

function Obstruction:PreUpdate(deltaTime: number, viewmodel: WeaponTypes.Viewmodel)
	local obstructionOffset = self.camera.rawCameraCFrame.LookVector * self.obstructionOffsetMultiplier

	local origin = self.camera.rawCameraCFrame.Position + obstructionOffset
	local target = viewmodel.weapon.Muzzle.CFrame.Position
	local direction = target - origin

	self.params.FilterDescendantsInstances = { LocalPlayer.Character, CurrentCamera }

	local raycastResult = workspace:Blockcast(
		self.camera.rawCameraCFrame + obstructionOffset,
		Vector3.new(1, 1, 0.1),
		direction,
		self.params
	)

	if raycastResult and (origin - target).Magnitude - raycastResult.Distance >= self.obstructionAmount - 0.5 then
		self.obstructionAmount =
			lerpNumber(self.obstructionAmount, (origin - target).Magnitude - raycastResult.Distance, 12 * deltaTime)
	else
		self.obstructionAmount = lerpNumber(self.obstructionAmount, 0, 8 * deltaTime)
	end
end

function Obstruction:Update(deltaTime: number, currentCFrame: CFrame, viewmodel: WeaponTypes.Viewmodel): CFrame
	return currentCFrame * CFrame.new(0, 0, self.obstructionAmount)
end

return Obstruction
