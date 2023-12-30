local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = require(ReplicatedStorage.Shared.LocalPlayer)
local debug = require(ReplicatedStorage.Shared.classes.debug)
local input = require(ReplicatedStorage.Shared.classes.input)
local weaponClient = require(ReplicatedStorage.Shared.classes.weaponClient)
local Glock17Config = require(ReplicatedStorage.Shared.configurations.weapons.Glock17Config)
local MK18TacConfig = require(ReplicatedStorage.Shared.configurations.weapons.MK18TacConfig)
local ClientPlayerData = require(ReplicatedStorage.Shared.module.ClientPlayerData)
local SignalBag = require(ReplicatedStorage.Shared.module.SignalBag)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)
local Maid = require(ReplicatedStorage.package.Maid)

type LoadoutUnion = "Primary" | "Secondary"

export type Class = {
	__index: Class,
	new: () -> Object,
	BindInput: (self: Object) -> (),
	ApplyLoadout: (self: Object) -> (),
	UpdateForcedUnequip: (self: Object) -> (),
	IsWeaponEquipped: (self: Object) -> boolean,
} & GameTypes.ClientMethods<Object>

export type Object = typeof(setmetatable(
	{} :: {
		currentWeapon: LoadoutUnion?,
		weaponsJanitor: Maid.Maid,
		weaponChangeQueued: boolean,

		weaponForceHide: boolean,
		lastWeaponOnForceHide: LoadoutUnion?,

		forceUnequip: {
			active: boolean,
			lastWeapon: LoadoutUnion?,
		},
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

	self.weaponForceHide = false

	self.actionsQueue = {}
	self.weaponsDebug = debug.new(UDim2.fromOffset(0, 100))

	self.forceUnequip = {
		active = false,
	}

	SignalBag:Connect("ApplyLoadout", function()
		self:ApplyLoadout()
	end)

	task.spawn(function()
		if not ClientPlayerData.serverProfile then
			repeat
				task.wait()
			until ClientPlayerData.serverProfile
		end

		ClientPlayerData.serverProfile:subscribe(function(state)
			return state.weaponHiders
		end, function(newValue: { string })
			print(#newValue > 0)
			self.weaponForceHide = (#newValue > 0)
		end)
	end)

	self:BindInput()

	return self
end

function Loadout:IsWeaponEquipped()
	return (self.currentWeapon ~= nil and self.weaponChangeQueued == false)
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
			if self.currentWeapon then
				self.weapons[self.currentWeapon]:Unequip():await()
			end

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
			if self.currentWeapon then
				self.weapons[self.currentWeapon]:Unequip():await()
			end

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
	self.weaponChangeQueued = true

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
	self.weapons[self.currentWeapon]:Equip():await()
	self.weaponChangeQueued = false
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

	if not self.weaponChangeQueued then
		if self.weaponForceHide and self.currentWeapon then
			self.lastWeaponOnForceHide = self.currentWeapon
			self.weaponChangeQueued = true

			self.weapons[self.currentWeapon]:Unequip():andThen(function()
				self.weaponChangeQueued = false
			end)

			self.currentWeapon = nil
		elseif not self.weaponForceHide and not self.currentWeapon and self.lastWeaponOnForceHide then
			self.currentWeapon = self.lastWeaponOnForceHide
			self.lastWeaponOnForceHide = nil
			self.weaponChangeQueued = true

			self.weapons[self.currentWeapon]:Equip():andThen(function()
				self.weaponChangeQueued = false
			end)
		end
	end
end

return Loadout
