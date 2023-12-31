local ReplicatedStorage = game:GetService("ReplicatedStorage")

local camera = require(ReplicatedStorage.Shared.classes.camera.camera)
local freelook = require(ReplicatedStorage.Shared.classes.freelook)
local input = require(ReplicatedStorage.Shared.classes.input)
local loadout = require(ReplicatedStorage.Shared.classes.loadout)
local movement = require(ReplicatedStorage.Shared.classes.movement)
local Ambience = require(ReplicatedStorage.Shared.module.Ambience)
local BodyVisibility = require(ReplicatedStorage.Shared.module.BodyVisibility)
local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)
local ClientPlayerData = require(ReplicatedStorage.Shared.module.ClientPlayerData)
local ClientTags = require(ReplicatedStorage.Shared.module.ClientTags)
local DynamicReverb = require(ReplicatedStorage.Shared.module.DynamicReverb)
local HeadAnimations = require(ReplicatedStorage.Shared.module.HeadAnimations)
local Interace = require(ReplicatedStorage.Shared.module.Interace)
local Lean = require(ReplicatedStorage.Shared.module.Lean)
local Projectors = require(ReplicatedStorage.Shared.module.Projectors)
local HumanoidStateAdjuster = require(ReplicatedStorage.Shared.module.HumanoidStateAdjuster)
local TOC = require(ReplicatedStorage.Shared.module.TOC)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)

require(ReplicatedStorage.Shared.module.Scream)

export type Class = {
	__index: Class,
	new: () -> Object,
} & GameTypes.ClientMethods<Object>

export type Object = typeof(setmetatable(
	{} :: {
		movement: movement.Object?,
		freelook: freelook.Object,
		camera: camera.Class,
		loadout: loadout.Object,
	},
	{} :: Class
))

local Client: Class = {} :: Class
Client.__index = Client

function Client.new()
	local self = setmetatable({}, Client)

	self.camera = camera.new()
	self.input = input.new({
		Primary = {
			keyCode = Enum.KeyCode.One,
			inputType = "Click",
		},
		Secondary = {
			keyCode = Enum.KeyCode.Two,
			inputType = "Click",
		},
		Reload = {
			keyCode = Enum.KeyCode.R,
			inputType = "Click",
		},
		Shoot = {
			keyCode = Enum.UserInputType.MouseButton1,
			inputType = "Hold",
		},
		Aim = {
			keyCode = Enum.UserInputType.MouseButton2,
			inputType = "Hold",
		},
		LowReady = {
			keyCode = Enum.KeyCode.Space,
			inputType = "Click",
		},
		SlowWalk = {
			keyCode = Enum.KeyCode.LeftShift,
			inputType = "Hold",
		},
		Freelook = {
			keyCode = Enum.UserInputType.MouseButton3,
			inputType = "Hold",
		},
		LeanLeft = {
			keyCode = Enum.KeyCode.Q,
			inputType = "Hold",
		},
		LeanRight = {
			keyCode = Enum.KeyCode.E,
			inputType = "Hold",
		},
		Scream = {
			keyCode = Enum.KeyCode.F,
			inputType = "Click",
		},
		Arrest = {
			keyCode = Enum.KeyCode.G,
			inputType = "Click",
		},
	})

	ClassBag:ReplaceBag({
		camera = self.camera,
	})

	self.loadout = loadout.new()
	self.freelook = freelook.new()

	input.SubscribeToInput("LeanLeft", function(holding: boolean)
		if ClientPlayerData.serverProfile:getState().leanFactor == -0.75 then
			return
		end

		ClientPlayerData.serverProfile.setLeanFactor(holding and 0.75 or 0)
	end)

	input.SubscribeToInput("LeanRight", function(holding: boolean)
		if ClientPlayerData.serverProfile:getState().leanFactor == 0.75 then
			return
		end

		ClientPlayerData.serverProfile.setLeanFactor(holding and -0.75 or 0)
	end)

	ClientTags:Start()
	TOC:Start()

	return self
end

function Client:UpdateCharacter(character)
	self.camera:UpdateCharacter(character)
	BodyVisibility:UpdateCharacter(character)
	Interace:UpdateCharacter(character)
	self.loadout:UpdateCharacter(character)

	if self.movement then
		self.movement = nil
	end

	if character then
		self.movement = movement.new(character, 4, 7)
		HumanoidStateAdjuster:AdjustStates(character.Humanoid)
	end
end

function Client:Update(deltaTime: number)
	self.camera:Update(deltaTime)
	self.freelook:Update(deltaTime)
	BodyVisibility:Update(deltaTime, self.loadout:IsWeaponEquipped())
	DynamicReverb:Update(deltaTime)
	Ambience:Update(deltaTime)
	self.loadout:Update(deltaTime)
	HeadAnimations:Update(deltaTime)

	if self.movement then
		self.movement:Update(deltaTime)
	end
end

function Client:UpdateAfterCharacter(deltaTime: number)
	self.camera:UpdatePhysics(deltaTime)
end

function Client:UpdatePhysics(deltaTime: number)
	Lean:Update(deltaTime)
end

function Client:PostUpdate(deltaTime: number)
	Projectors:PostUpdate(deltaTime)
end

return Client
