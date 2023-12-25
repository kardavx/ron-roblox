local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local CurrentCamera = require(ReplicatedStorage.Shared.CurrentCamera)
local cameraModifier = require(ReplicatedStorage.Shared.classes.camera.cameraModifier)
local fovModifier = require(ReplicatedStorage.Shared.classes.camera.fovModifier)
local cameraConfig = require(ReplicatedStorage.Shared.configurations.cameraConfig)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)

export type Class = {
	__index: Class,
	new: () -> Object,
	UpdateDelta: (self: Object, deltaTime: number) -> (),
	Shove: (self: Object, shoveAmount: Vector2) -> (),
	SetLocked: (self: Object, locked: boolean) -> (),
	UpdateRotationDelta: (self: Object) -> (),
} & GameTypes.ClientMethods<Object>

export type Object = typeof(setmetatable(
	{} :: {
		baseFov: number,
		character: Model?,
		orientation: Vector2,
		rawCameraCFrame: CFrame,
		lastRawCameraCFrame: CFrame,
		rotationDelta: Vector2,
		actualCameraCFrame: CFrame,
		currentShove: Vector2,
		targetShove: Vector2,
		cameraLocked: boolean,
	},
	{} :: Class
))

local Camera: Class = {} :: Class
Camera.__index = Camera

function Camera.new()
	local self = setmetatable({}, Camera)

	self.baseFov = 80
	self.character = nil
	self.orientation = Vector2.zero
	self.rawCameraCFrame = CFrame.identity
	self.lastRawCameraCFrame = self.rawCameraCFrame
	self.actualCameraCFrame = CFrame.identity
	self.targetShove = Vector2.zero
	self.currentShove = Vector2.zero
	self.cameraLocked = false
	self.rotationDelta = Vector2.zero

	return self
end

function Camera:UpdateCharacter(character)
	self.character = character
end

function Camera:UpdateDelta(deltaTime: number)
	if self.cameraLocked then
		return
	end

	local mouseDelta = UserInputService:GetMouseDelta() * 100
	local mouseSensitivity = UserGameSettings.MouseSensitivity

	self.orientation = Vector2.new(
		self.orientation.X + (mouseDelta.X * mouseSensitivity * deltaTime),
		math.clamp(
			self.orientation.Y + (mouseDelta.Y * mouseSensitivity * deltaTime),
			-cameraConfig.yBounds,
			cameraConfig.yBounds
		)
	)
end

function Camera:UpdateRotationDelta()
	local currentCameraLookVector = self.rawCameraCFrame.LookVector
	local shouldInvert = Vector3.zAxis:Dot(currentCameraLookVector) >= 0
	local difference = currentCameraLookVector - self.lastRawCameraCFrame.LookVector
	self.rotationDelta = Vector2.new(difference.X, difference.Y) * 100 * (shouldInvert and Vector2.new(-1, 1) or 1)

	self.lastRawCameraCFrame = self.rawCameraCFrame
end

function Camera:Shove(shoveAmount: Vector2)
	self.targetShove += shoveAmount
end

function Camera:Update(deltaTime: number)
	CurrentCamera.CameraType = Enum.CameraType.Scriptable
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	UserInputService.MouseIconEnabled = false

	if not self.character then
		return
	end

	local relativePart = self.character:FindFirstChild(cameraConfig.relativeTo) :: BasePart
	if not relativePart then
		return
	end

	local humanoid = self.character:FindFirstChild("Humanoid") :: Humanoid
	if not humanoid then
		return
	end

	local neck = self.character:FindFirstChild("Neck", true) :: Motor6D
	if not neck then
		return
	end

	fovModifier.UpdateAll(deltaTime)
	cameraModifier.UpdateAll(deltaTime)

	CurrentCamera.Focus = CFrame.new(relativePart.Position)

	humanoid.AutoRotate = false

	self:UpdateDelta(deltaTime)
	CurrentCamera.FieldOfView = self.baseFov + fovModifier.SumModifiers()

	self.currentShove = self.currentShove:Lerp(self.targetShove, 20 * deltaTime)
	self.orientation += self.currentShove

	self.rawCameraCFrame = (
		CFrame.new((relativePart.CFrame * CFrame.new(cameraConfig.offset)).Position)
		* CFrame.fromEulerAnglesYXZ(math.rad(-self.orientation.Y), math.rad(-self.orientation.X), 0)
	) * cameraModifier.SumModifiers("Raw")

	self:UpdateRotationDelta()

	self.targetShove = self.targetShove:Lerp(Vector2.zero, 20 * deltaTime)

	self.actualCameraCFrame = self.rawCameraCFrame * cameraModifier.SumModifiers("Default")
	CurrentCamera.CFrame = self.actualCameraCFrame
end

function Camera:SetLocked(locked: boolean)
	self.cameraLocked = locked
end

function Camera:UpdatePhysics(deltaTime: number)
	if not self.character then
		return
	end

	local rootPart = self.character:FindFirstChild("HumanoidRootPart") :: BasePart
	if not rootPart then
		return
	end

	rootPart.CFrame = rootPart.CFrame:Lerp(
		CFrame.new(rootPart.Position) * CFrame.Angles(0, math.rad(-self.orientation.X), 0),
		20 * deltaTime
	)
end

return Camera
