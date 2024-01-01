local ReplicatedStorage = game:GetService("ReplicatedStorage")

local input = require(ReplicatedStorage.Shared.classes.input)
local movementConfig = require(ReplicatedStorage.Shared.configurations.movementConfig)
local ClientPlayerData = require(ReplicatedStorage.Shared.module.ClientPlayerData)
local SignalBag = require(ReplicatedStorage.Shared.module.SignalBag)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)
local getMoveDirectionInObjectSpace = require(ReplicatedStorage.Shared.util.getMoveDirectionInObjectSpace)
local lerpNumber = require(ReplicatedStorage.Shared.util.lerpNumber)
local Maid = require(ReplicatedStorage.package.Maid)

--- .new appends to a character, implements inertia and lean

type Character = Model & {
	Humanoid: Humanoid,
}

export type Class = {
	__index: Class,
	new: (character: Character, accelerationMultiplier: number, decelerationMultiplier: number) -> Object,
	UpdateSpeed: (self: Object) -> (),
	BindInput: (self: Object) -> (),
	Destroy: (self: Object) -> (),
} & GameTypes.ClientMethods<Object>

export type Object = typeof(setmetatable(
	{} :: {
		slowWalk: boolean,
		lowReady: boolean,

		inputJanitor: Maid.Maid,

		character: Model & {
			Humanoid: Humanoid,
		},

		accelerationMultiplier: number,
		decelerationMultiplier: number,

		turnDecelerationMultiplier: number,

		desiredSpeed: number,
		lastDesiredSpeed: number,

		lastMoveDirection: Vector3,
		lastPositiveInput: Vector3,

		isLeaning: boolean,
	},
	{} :: Class
))

local Movement: Class = {} :: Class
Movement.__index = Movement

function Movement.new(character: Character, accelerationMultiplier: number, decelerationMultiplier: number)
	local self = setmetatable({}, Movement)

	self.slowWalk = false
	self.lowReady = false
	self.lastMoveDirection = Vector3.zero

	self.inputJanitor = Maid.new()

	self.character = character

	self.accelerationMultiplier = accelerationMultiplier or movementConfig.defaultAccelerationMultiplier
	self.decelerationMultiplier = decelerationMultiplier or movementConfig

	self.turnDecelerationMultiplier = movementConfig.turnDecelerationMultiplier

	self.desiredSpeed = 0
	self.lastDesiredSpeed = self.desiredSpeed

	self.lastPositiveInput = Vector3.zero

	self.character.Humanoid.WalkSpeed = self.desiredSpeed

	self.isLeaning = false

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

	local leaningConnection = ClientPlayerData.serverProfile:subscribe(function(state)
		return state.leanFactor
	end, function(newValue: number)
		self.isLeaning = newValue ~= 0
	end)

	self.inputJanitor:GiveTask(function()
		slowWalkConnection:Destroy()
		lowReadyConnection:Destroy()
		leaningConnection()
	end)
end

function Movement:UpdateSpeed()
	local moveDirection = getMoveDirectionInObjectSpace()
	self.lastDesiredSpeed = self.desiredSpeed

	if moveDirection.Magnitude > 0 then
		if ClientPlayerData.clientProducer:getState().crouching then
			if self.slowWalk then
				self.desiredSpeed = movementConfig.slowCrouchWalkSpeed
				return
			end

			self.desiredSpeed = movementConfig.crouchWalkSpeed
			return
		end

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

	if self.isLeaning then
		self.desiredSpeed = self.desiredSpeed * movementConfig.leaningWalkspeedMultiplier
	end

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
