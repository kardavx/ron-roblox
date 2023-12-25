local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local camera = require(ReplicatedStorage.Shared.classes.camera.camera)
local freelook = require(ReplicatedStorage.Shared.classes.freelook)
local input = require(ReplicatedStorage.Shared.classes.input)
local movement = require(ReplicatedStorage.Shared.classes.movement)
local weapon = require(ReplicatedStorage.Shared.classes.weapon)
local SigSauerConfig = require(ReplicatedStorage.Shared.configurations.weapons.SigSauerConfig)
local BodyVisibility = require(ReplicatedStorage.Shared.module.BodyVisibility)
local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)
local ClientTags = require(ReplicatedStorage.Shared.module.ClientTags)
local Gloves = require(ReplicatedStorage.Shared.module.Gloves)
local Projectors = require(ReplicatedStorage.Shared.module.Projectors)
local SignalBag = require(ReplicatedStorage.Shared.module.SignalBag)
local Watch = require(ReplicatedStorage.Shared.module.Watch)
local OOPTypes = require(ReplicatedStorage.Shared.types.OOPTypes)
local chooseRandomFromArray = require(ReplicatedStorage.Shared.util.chooseRandomFromArray)
local Maid = require(ReplicatedStorage.package.Maid)

local possibleGloves = { "bulky", "None" }
local possibleWatches = { "silver", "None" }

export type Class = {
	__index: Class,
	new: () -> Object,
	ApplyLoadout: (self: Object) -> (),
} & OOPTypes.ClientClassMethods<Object>

export type Object = typeof(setmetatable(
	{} :: {
		currentWeapon: "Secondary"?,
		weapons: {
			Secondary: weapon.Object,
		}?,
		movement: movement.Object?,
		freelook: freelook.Object,
		weaponsJanitor: Maid.Maid,
		camera: camera.Class,
	},
	{} :: Class
))

local Client: Class = {} :: Class
Client.__index = Client

function Client.new()
	local self = setmetatable({}, Client)

	self.camera = camera.new()
	self.input = input.new({
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
	})

	ClassBag:ReplaceBag({
		camera = self.camera,
	})

	self.weaponsJanitor = Maid.new()
	self.freelook = freelook.new()

	input.SubscribeToInput("Secondary", function()
		if not self.weapons then
			return
		end

		if self.currentWeapon == "Secondary" then
			return
		else
			self.currentWeapon = "Secondary"
			self.weapons[self.currentWeapon]:Equip()
		end
	end)

	ClientTags:Start()

	SignalBag:Connect("ApplyLoadout", function()
		print("got signal")
		self:ApplyLoadout()
	end)

	return self
end

function Client:ApplyLoadout(forced: boolean?)
	if not LocalPlayer.Character then
		return
	end

	local lastEquippedWeapon

	if not forced then
		if self.currentWeapon then
			lastEquippedWeapon = self.currentWeapon
			self.weapons[self.currentWeapon]:Unequip():await()
		end
	end

	self.weaponsJanitor:DoCleaning()
	self.weapons = {
		Secondary = weapon.new(SigSauerConfig),
	}

	for _, singleWeapon in self.weapons do
		self.weaponsJanitor:GiveTask(function()
			singleWeapon:Destroy()
		end)
	end

	self.weaponsJanitor:GiveTask(function()
		self.weapons = nil
		self.currentWeapon = nil
	end)

	self.currentWeapon = lastEquippedWeapon or "Secondary"
	self.weapons[self.currentWeapon]:Equip()
end

function Client:UpdateCharacter(character)
	self.camera:UpdateCharacter(character)
	BodyVisibility:UpdateCharacter(character)

	if self.movement then
		self.movement = nil
	end

	if character then
		local choosenGloves = chooseRandomFromArray(possibleGloves)
		if choosenGloves == "None" then
			choosenGloves = nil
		end

		local choosenWatch = chooseRandomFromArray(possibleWatches)
		if choosenWatch == "None" then
			choosenWatch = nil
		end

		Gloves:SetCurrentGloves(choosenGloves)
		Watch:SetCurrentWatch(choosenWatch)
		self.movement = movement.new(character, 4)
		self:ApplyLoadout(true)
	else
		self.weaponsJanitor:DoCleaning()
	end
end

function Client:Update(deltaTime: number)
	self.camera:Update(deltaTime)
	self.freelook:Update(deltaTime)
	BodyVisibility:Update(deltaTime)
	Projectors:Update(deltaTime)

	if self.movement then
		self.movement:Update(deltaTime)
	end

	if self.weapons then
		for _, singleWeapon in self.weapons do
			singleWeapon:Update(deltaTime)
		end
	end
end

function Client:UpdatePhysics(deltaTime: number)
	self.camera:UpdatePhysics(deltaTime)
end

return Client
