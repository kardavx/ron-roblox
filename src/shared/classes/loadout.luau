local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local debug = require(ReplicatedStorage.Shared.classes.debug)
local input = require(ReplicatedStorage.Shared.classes.input)
local weaponClient = require(ReplicatedStorage.Shared.classes.weaponClient)
local Glock17Config = require(ReplicatedStorage.Shared.configurations.weapons.Glock17Config)
local MK18TacConfig = require(ReplicatedStorage.Shared.configurations.weapons.MK18TacConfig)
local SignalBag = require(ReplicatedStorage.Shared.module.SignalBag)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)
local Maid = require(ReplicatedStorage.package.Maid)

type LoadoutUnion = "Primary" | "Secondary"

export type Class = {
	__index: Class,
	new: () -> Object,
	BindInput: (self: Object) -> (),
	ApplyLoadout: (self: Object) -> (),
} & GameTypes.ClientMethods<Object>

export type Object = typeof(setmetatable(
	{} :: {
		currentWeapon: LoadoutUnion?,
		weaponsJanitor: Maid.Maid,
		weaponChangeQueued: boolean,
		weapons: {
			[LoadoutUnion]: weaponClient.Object,
		}?,
	},
	{} :: Class
))

local Loadout: Class = {} :: Class
Loadout.__index = Loadout

function Loadout.new()
	local self = setmetatable({}, Loadout)

	self.weaponsJanitor = Maid.new()
	self.weaponChangeQueued = false
	self.weaponsDebug = debug.new(UDim2.fromOffset(0, 100))

	SignalBag:Connect("ApplyLoadout", function()
		self:ApplyLoadout()
	end)

	self:BindInput()

	return self
end

function Loadout:BindInput()
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
end

function Loadout:UpdateCharacter(character)
	if character then
		self:ApplyLoadout(true)
	else
		self.weaponsJanitor:DoCleaning()
	end
end

function Loadout:ApplyLoadout(forced: boolean?)
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

function Loadout:Update(deltaTime)
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

return Loadout
