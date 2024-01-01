local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrentCamera = require(ReplicatedStorage.Shared.CurrentCamera)
local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local debug = require(ReplicatedStorage.Shared.classes.debug)
local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)
local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local clampedInverseLerpNumber = require(ReplicatedStorage.Shared.util.clampedInverseLerpNumber)
local lerpNumber = require(ReplicatedStorage.Shared.util.lerpNumber)

local Obstruction: RenderPipelineTypes.NodeClass = {} :: RenderPipelineTypes.NodeClass
Obstruction.__index = Obstruction

local maxPullback = 2

function Obstruction.new(): RenderPipelineTypes.NodeObject
	local self = setmetatable({}, Obstruction)

	self.camera = ClassBag:GetClass("camera", true)
	self.obstructionAmount = 0
	self.debug = debug.new(UDim2.fromOffset(1400, 200))
	self.params = RaycastParams.new()
	self.params.FilterType = Enum.RaycastFilterType.Exclude
	self.obstructionOffsetMultiplier = -1
	self.lastUpwardFactor = 0

	return self
end

function Obstruction:Update(deltaTime: number, currentCFrame: CFrame, viewmodel: WeaponTypes.Viewmodel): CFrame
	local actualObstruction = math.min(self.obstructionAmount, maxPullback)
	local rotateUpwardFactor = lerpNumber(
		self.lastUpwardFactor,
		clampedInverseLerpNumber(maxPullback - 1, maxPullback, actualObstruction),
		6 * deltaTime
	)

	self.debug:LogMessage(actualObstruction)
	self.debug:Update()

	self.lastUpwardFactor = rotateUpwardFactor

	return currentCFrame
		* CFrame.new(0, -4 * rotateUpwardFactor, actualObstruction)
		* CFrame.Angles(math.rad(80) * rotateUpwardFactor, 0, 0)
end

function Obstruction:PostUpdate(deltaTime: number, viewmodel: WeaponTypes.Viewmodel)
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
		self.obstructionAmount = lerpNumber(self.obstructionAmount, 0, 4 * deltaTime)
	end
end

return Obstruction
