local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local camera = require(ReplicatedStorage.Shared.classes.camera.camera)
local debug = require(ReplicatedStorage.Shared.classes.debug)
local freelook = require(ReplicatedStorage.Shared.classes.freelook)
local input = require(ReplicatedStorage.Shared.classes.input)
local movement = require(ReplicatedStorage.Shared.classes.movement)
local weaponClient = require(ReplicatedStorage.Shared.classes.weaponClient)
local Glock17Config = require(ReplicatedStorage.Shared.configurations.weapons.Glock17Config)
local MK18Config = require(ReplicatedStorage.Shared.configurations.weapons.MK18Config)
local MK18TacConfig = require(ReplicatedStorage.Shared.configurations.weapons.MK18TacConfig)
local SigSauerConfig = require(ReplicatedStorage.Shared.configurations.weapons.SigSauerConfig)
local BodyVisibility = require(ReplicatedStorage.Shared.module.BodyVisibility)
local ClassBag = require(ReplicatedStorage.Shared.module.ClassBag)
local ClientPlayerData = require(ReplicatedStorage.Shared.module.ClientPlayerData)
local ClientTags = require(ReplicatedStorage.Shared.module.ClientTags)
local Gloves = require(ReplicatedStorage.Shared.module.Gloves)
local HumanoidStateAdjuster = require(ReplicatedStorage.Shared.module.HumanoidStateAdjuster)
local Interace = require(ReplicatedStorage.Shared.module.Interace)
local Projectors = require(ReplicatedStorage.Shared.module.Projectors)
local Scream = require(ReplicatedStorage.Shared.module.Scream)
local HumanoidStateAdjuster = require(ReplicatedStorage.Shared.module.HumanoidStateAdjuster)
local SignalBag = require(ReplicatedStorage.Shared.module.SignalBag)
local Watch = require(ReplicatedStorage.Shared.module.Watch)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)
local chooseRandomFromArray = require(ReplicatedStorage.Shared.util.chooseRandomFromArray)
local Maid = require(ReplicatedStorage.package.Maid)

local possibleGloves = { "bulky", "None" }
local possibleWatches = { "silver", "None" }

type LoadoutUnion = "Primary" | "Secondary"

export type Class = {
	__index: Class,
	new: () -> Object,
	ApplyLoadout: (self: Object) -> (),
} & GameTypes.ClientMethods<Object>

export type Object = typeof(setmetatable(
	{} :: {
		currentWeapon: LoadoutUnion?,
		weaponChangeQueued: boolean,
		weapons: {
			[LoadoutUnion]: weaponClient.Object,
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
	self.weaponsDebug = debug.new(UDim2.fromOffset(0, 100))
	self.weaponChangeQueued = false
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

		if self.weaponChangeQueued == true then
			return
		end

		if self.currentWeapon == "Secondary" then
			return
		else
			self.weaponChangeQueued = true
			self.weapons[self.currentWeapon]:Unequip():await()

			self.currentWeapon = "Secondary"
			self.weapons[self.currentWeapon]:Equip():await()
			self.weaponChangeQueued = false
		end
	end)

	input.SubscribeToInput("Primary", function()
		if not self.weapons then
			return
		end

		if self.weaponChangeQueued == true then
			print("stopping because weaponChange is queued")
			return
		end

		if self.currentWeapon == "Primary" then
			return
		else
			self.weaponChangeQueued = true
			self.weapons[self.currentWeapon]:Unequip():await()

			self.currentWeapon = "Primary"
			self.weapons[self.currentWeapon]:Equip():await()
			self.weaponChangeQueued = false
		end
	end)

	input.SubscribeToInput("LeanLeft", function(holding: boolean)
		if ClientPlayerData.serverProfile:getState().leanFactor == -1 then
			return
		end

		ClientPlayerData.serverProfile.setLeanFactor(holding and 1 or 0)
	end)

	input.SubscribeToInput("LeanRight", function(holding: boolean)
		if ClientPlayerData.serverProfile:getState().leanFactor == 1 then
			return
		end

		ClientPlayerData.serverProfile.setLeanFactor(holding and -1 or 0)
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
		Primary = weaponClient.new(MK18TacConfig),
		Secondary = weaponClient.new(Glock17Config),
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

	self.currentWeapon = lastEquippedWeapon or "Primary"
	self.weapons[self.currentWeapon]:Equip()
end

function Client:UpdateCharacter(character)
	self.camera:UpdateCharacter(character)
	BodyVisibility:UpdateCharacter(character)
	Interace:UpdateCharacter(character)

	if self.movement then
		self.movement = nil
	end

	if character then
		self.movement = movement.new(character, 4)
		HumanoidStateAdjuster:AdjustStates(character.Humanoid)

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

	if self.movement then
		self.movement:Update(deltaTime)
	end

	if self.weapons then
		local combinedWeaponsDebugMessage = {
			`weaponChangeQueued: {self.weaponChangeQueued}`,
			``,
		}

		for _, singleWeapon in self.weapons do
			singleWeapon:Update(deltaTime)
			table.insert(combinedWeaponsDebugMessage, `<b>{singleWeapon.config.ViewmodelName}</b>`)
			table.insert(combinedWeaponsDebugMessage, ``)
			for _, debugMessage in singleWeapon.debug do
				table.insert(combinedWeaponsDebugMessage, debugMessage)
			end
		end

		self.weaponsDebug:LogMultilineMessage(combinedWeaponsDebugMessage)
		self.weaponsDebug:Update()
	else
		self.weaponsDebug:LogMessage("weapons doesn't exist")
	end
end

function Client:UpdatePhysics(deltaTime: number)
	self.camera:UpdatePhysics(deltaTime)
end

function Client:PostUpdate(deltaTime: number)
	Projectors:PostUpdate(deltaTime)
end

return Client
