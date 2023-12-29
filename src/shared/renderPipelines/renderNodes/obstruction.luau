local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrentCamera = require(ReplicatedStorage.Shared.CurrentCamera)
local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)
local SignalBag = require(ReplicatedStorage.Shared.module.SignalBag)
local RenderPipelineTypes = require(ReplicatedStorage.Shared.types.RenderPipelineTypes)
local WeaponConfigTypes = require(ReplicatedStorage.Shared.types.WeaponConfigTypes)
local WeaponTypes = require(ReplicatedStorage.Shared.types.WeaponTypes)
local playAnimationIfNotPlaying = require(ReplicatedStorage.Shared.util.animations.playAnimationIfNotPlaying)
local stopAnimationIfPlaying = require(ReplicatedStorage.Shared.util.animations.stopAnimationIfPlaying)
local lerpNumber = require(ReplicatedStorage.Shared.util.lerpNumber)

local Obstruction: RenderPipelineTypes.NodeClass = {} :: RenderPipelineTypes.NodeClass
Obstruction.__index = Obstruction

local maxPullback = 0.5

function Obstruction.new(): RenderPipelineTypes.NodeObject
	local self = setmetatable({}, Obstruction)

	self.camera = ClassBag:GetClass("camera", true)
	self.desiredObstructionAmount = 0
	self.actualObstructionAmount = 0
	self.params = RaycastParams.new()
	self.params.FilterType = Enum.RaycastFilterType.Exclude
	self.obstructionOffsetMultiplier = -1
	self.lastViewmodel = ""
	self.lastMaxDistance = 0

	return self
end

function Obstruction:PreUpdate(
	deltaTime: number,
	viewmodel: WeaponTypes.Viewmodel,
	animations: { [WeaponConfigTypes.AnimationsUnion]: AnimationTrack }
)
	local obstructionOffset = self.camera.rawCameraCFrame.LookVector * self.obstructionOffsetMultiplier

	local origin = self.camera.rawCameraCFrame.Position + obstructionOffset
	local target = (viewmodel.weapon.Muzzle.CFrame).Position
	local direction = target - origin
	self.params.FilterDescendantsInstances = { LocalPlayer.Character, CurrentCamera }

	local maxDistance = math.round((origin - target).Magnitude)

	if self.lastViewmodel ~= viewmodel.Name or maxDistance > self.lastMaxDistance then
		self.lastViewmodel = viewmodel.Name
		self.lastMaxDistance = maxDistance
	end

	local raycastResult = workspace:Blockcast(
		self.camera.rawCameraCFrame + obstructionOffset,
		Vector3.new(1, 1, 0.1),
		self.camera.rawCameraCFrame.LookVector * self.lastMaxDistance,
		self.params
	)

	if raycastResult and self.lastMaxDistance - raycastResult.Distance >= self.desiredObstructionAmount - 0.5 then
		self.desiredObstructionAmount =
			lerpNumber(self.desiredObstructionAmount, self.lastMaxDistance - raycastResult.Distance, 12 * deltaTime)
	else
		self.desiredObstructionAmount = lerpNumber(self.desiredObstructionAmount, 0, 8 * deltaTime)
	end

	self.actualObstructionAmount = math.min(self.desiredObstructionAmount, maxPullback)

	if self.actualObstructionAmount >= maxPullback then
		SignalBag:Fire("EnableLowReadyExternally", "obstruction")
	else
		SignalBag:Fire("DisableLowReadyExternally", "obstruction")
	end
end

function Obstruction:Update(deltaTime: number, currentCFrame: CFrame, viewmodel: WeaponTypes.Viewmodel): CFrame
	return currentCFrame * CFrame.new(0, 0, self.actualObstructionAmount)
end

return Obstruction
