local ReplicatedStorage = game:GetService("ReplicatedStorage")

local input = require(ReplicatedStorage.Shared.classes.input)
local movementConfig = require(ReplicatedStorage.Shared.configurations.movementConfig)
local SignalBag = require(ReplicatedStorage.Shared.module.SignalBag)
local OOPTypes = require(ReplicatedStorage.Shared.types.OOPTypes)
local getMoveDirectionInObjectSpace = require(ReplicatedStorage.Shared.util.getMoveDirectionInObjectSpace)
local lerpNumber = require(ReplicatedStorage.Shared.util.lerpNumber)
local Maid = require(ReplicatedStorage.package.Maid)

--- .new appends to a character, implements inertia and lean

type Character = Model & {
	Humanoid: Humanoid,
}

export type Class = {
	__index: Class,
	new: (character: Character, accelerationMultiplier: number) -> Object,
	UpdateSpeed: (self: Object) -> (),
	BindInput: (self: Object) -> (),
	Destroy: (self: Object) -> (),
} & OOPTypes.ClientClassMethods<Object>

export type Object = typeof(setmetatable(
	{} :: {
		slowWalk: boolean,
		lowReady: boolean,

		inputJanitor: Maid.Maid,

		character: Model & {
			Humanoid: Humanoid,
		},

		accelerationMultiplier: number,
		turnDecelerationMultiplier: number,
		desiredSpeed: number,
		lastMoveDirection: Vector3,
		lastPositiveInput: Vector3,
	},
	{} :: Class
))

local Movement: Class = {} :: Class
Movement.__index = Movement

function Movement.new(character: Character, accelerationMultiplier: number)
	local self = setmetatable({}, Movement)

	self.slowWalk = false
	self.lowReady = false
	self.lastMoveDirection = Vector3.zero

	self.inputJanitor = Maid.new()

	self.character = character

	self.accelerationMultiplier = accelerationMultiplier or movementConfig.defaultAccelerationMultiplier
	self.turnDecelerationMultiplier = movementConfig.turnDecelerationMultiplier
	self.desiredSpeed = 0

	self.lastPositiveInput = Vector3.zero

	self.character.Humanoid.WalkSpeed = self.desiredSpeed

	self:BindInput()

	return self
end

function Movement:BindInput()
	local slowWalkConnection = input.SubscribeToInput("SlowWalk", function(holding: boolean)
		self.slowWalk = holding
	end)

	local lowReadyConnection = SignalBag:Connect("LowReady", function(lowReadyState: boolean)
		self.lowReady = lowReadyState
	end)

	self.inputJanitor:GiveTask(function()
		slowWalkConnection:Destroy()
		lowReadyConnection:Destroy()
	end)
end

function Movement:UpdateSpeed()
	local moveDirection = getMoveDirectionInObjectSpace()

	if moveDirection.Magnitude > 0 then
		if self.slowWalk then
			self.desiredSpeed = movementConfig.slowWalkSpeed
			return
		end

		if self.lowReady then
			self.desiredSpeed = movementConfig.lowReadySpeed
			return
		end

		self.desiredSpeed = movementConfig.normalSpeed
	else
		self.desiredSpeed = 0
	end
end

function Movement:Update(deltaTime: number)
	local moveDirection = getMoveDirectionInObjectSpace()

	self:UpdateSpeed()

	local angle = math.deg(math.acos(self.lastMoveDirection:Dot(moveDirection)))
	if angle ~= angle then
		angle = 0
	end
	self.lastMoveDirection = moveDirection

	--[[
		1 Wersja
		self.character.Humanoid.WalkSpeed = lerpNumber(
		self.character.Humanoid.WalkSpeed,
		self.desiredSpeed - angle * (self.desiredSpeed * self.turnDecelerationMultiplier),
		self.accelerationMultiplier * deltaTime)
	]]

	self.character.Humanoid.WalkSpeed =
		lerpNumber(self.character.Humanoid.WalkSpeed, self.desiredSpeed, self.accelerationMultiplier * deltaTime)

	self.character.Humanoid.WalkSpeed = lerpNumber(
		self.character.Humanoid.WalkSpeed,
		self.character.Humanoid.WalkSpeed - angle * self.desiredSpeed,
		self.turnDecelerationMultiplier * deltaTime
	)

	if math.abs(self.desiredSpeed - self.character.Humanoid.WalkSpeed) < 0.01 then
		self.character.Humanoid.WalkSpeed = self.desiredSpeed
	end

	if
		moveDirection.Magnitude == 0
		and math.abs(self.desiredSpeed - self.character.Humanoid.WalkSpeed) > 1
		and self.lastPositiveInput
	then
		self.character.Humanoid:Move(
			self.character.PrimaryPart.CFrame:VectorToWorldSpace(
				self.lastPositiveInput or self.character.PrimaryPart.CFrame.LookVector * 2
			),
			false
		)
	end

	if moveDirection.Magnitude ~= 0 then
		self.lastPositiveInput = moveDirection
	end
end

function Movement:Destroy()
	self.inputJanitor:Destroy()
end

return Movement
