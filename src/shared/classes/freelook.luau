local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local camera = require(ReplicatedStorage.Shared.classes.camera.camera)
local cameraModifier = require(ReplicatedStorage.Shared.classes.camera.cameraModifier)
local input = require(ReplicatedStorage.Shared.classes.input)
local freelookConfig = require(ReplicatedStorage.Shared.configurations.freelookConfig)
local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)
local Maid = require(ReplicatedStorage.package.Maid)

export type Class = {
	__index: Class,
	new: () -> Object,
	BindInput: (self: Object) -> (),
} & GameTypes.ClientMethods<Object>

export type Object = typeof(setmetatable(
	{} :: {
		camera: camera.Object,
		inputJanitor: Maid.Maid,
		enabled: boolean,
		freelookOffset: Vector2,
		modifier: cameraModifier.Object,
	},
	{} :: Class
))

local Freelook: Class = {} :: Class
Freelook.__index = Freelook

function Freelook.new()
	local self = setmetatable({}, Freelook)

	self.camera = ClassBag:GetClass("camera", true)
	self.modifier = cameraModifier.new()
	self.inputJanitor = Maid.new()
	self.enabled = false
	self.freelookOffset = Vector2.zero

	self:BindInput()

	return self
end

function Freelook:BindInput()
	local freelookConnection = input.SubscribeToInput("Freelook", function(holding: boolean)
		self.enabled = holding
		self.camera:SetLocked(self.enabled)
	end)

	self.inputJanitor:GiveTask(function()
		freelookConnection:Destroy()
	end)
end

function Freelook:Update(deltaTime: number)
	if self.enabled then
		local mouseDelta = UserInputService:GetMouseDelta() * 2
		local mouseSensitivity = UserGameSettings.MouseSensitivity

		self.freelookOffset += (mouseDelta * mouseSensitivity * deltaTime) * -1
	else
		self.freelookOffset = self.freelookOffset:Lerp(Vector2.zero, 5 * deltaTime)
	end

	self.freelookOffset = Vector2.new(
		math.clamp(self.freelookOffset.X, -freelookConfig.xAxisMax, freelookConfig.xAxisMax),
		math.clamp(self.freelookOffset.Y, -freelookConfig.yAxisMax, freelookConfig.yAxisMax)
	)

	self.modifier:SetTarget(CFrame.Angles(self.freelookOffset.Y, self.freelookOffset.X, 0), 0)
end

return Freelook
