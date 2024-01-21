local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local weapon = require(ServerScriptService.classes.weapon)
local OnBridge = require(ServerScriptService.module.OnBridge)
local ServerPlayerData = require(ServerScriptService.module.ServerPlayerData)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)

export type Class = {
	__index: Class,
	new: (player: Player, data: ServerPlayerData.ServerPlayerProfile) -> Object,
	BindBridges: (self: Object) -> (),
	Equip: (self: Object, weaponName: string) -> (),
	Unequip: (self: Object) -> (),
	Destroy: (self: Object) -> (),
} & GameTypes.ServerMethods<Object>

export type ObjectProperties = {
	data: ServerPlayerData.ServerPlayerProfile,
	player: Player,
	currentWeapon: weapon.Object?,
}

export type Object = typeof(setmetatable({} :: ObjectProperties, {} :: Class))

local PlayerWeapon: Class = {} :: Class
PlayerWeapon.__index = PlayerWeapon

function PlayerWeapon.new(player: Player, data: ServerPlayerData.ServerPlayerProfile)
	local self = setmetatable({}, PlayerWeapon)

	self.data = data
	self.player = player

	self:BindBridges()

	return self
end

function PlayerWeapon:Equip(weaponName: string)
	if self.currentWeapon then
		self:Unequip()
	end

	print(`equipped {weaponName}`)

	self.currentWeapon = weapon.new(self.player.Character, weaponName, "Trained")
end

function PlayerWeapon:Unequip()
	if not self.currentWeapon then
		return
	end

	self.currentWeapon:Destroy()
	self.currentWeapon = nil
end

function PlayerWeapon:BindBridges()
	OnBridge(self.player, "Weapon_Equip", function(weaponName: string)
		if not self.player.Character then
			return
		end

		self:Equip(weaponName)
	end)

	OnBridge(self.player, "Weapon_Shoot", function()
		self.currentWeapon:Shoot()
	end)

	OnBridge(self.player, "Weapon_Reload", function()
		self.currentWeapon:Reload()
	end)

	OnBridge(self.player, "Weapon_Aim", function(aimState: boolean)
		self.currentWeapon:SetAiming(aimState)
	end)

	OnBridge(self.player, "Weapon_Unequip", function()
		self:Unequip()
	end)
end

function PlayerWeapon:Destroy() end

return PlayerWeapon
