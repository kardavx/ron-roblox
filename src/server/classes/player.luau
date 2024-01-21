local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Gloves = require(ReplicatedStorage.Shared.module.Gloves)
local Watch = require(ReplicatedStorage.Shared.module.Watch)
local lean = require(ServerScriptService.classes.lean)
local playerWeapon = require(ServerScriptService.classes.playerWeapon)
local ServerPlayerData = require(ServerScriptService.module.ServerPlayerData)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)
local chooseRandomFromArray = require(ReplicatedStorage.Shared.util.chooseRandomFromArray)
local Maid = require(ReplicatedStorage.package.Maid)

local possibleGloves = { "bulky", "None" }
local possibleWatches = { "silver", "None" }

export type Class = {
	__index: Class,
	new: (player: Player) -> Object,
	Update: (self: Object, deltaTime: number) -> (),
	UpdateCharacter: (self: Object, character: Model?) -> (),
	OnCharacterDied: (self: Object) -> (),
	Destroy: (self: Object) -> (),
} & GameTypes.ServerMethods<Object>

export type Object = typeof(setmetatable(
	{} :: {
		data: ServerPlayerData.ServerPlayerProfile,
		janitor: Maid.Maid,
		lean: lean.Object,
		player: Player,
	},
	{} :: Class
))

local PlayerClass: Class = {} :: Class
PlayerClass.__index = PlayerClass

local function waitForPlayerData(player: Player): ServerPlayerData.ServerPlayerProfile
	local resolved, data = ServerPlayerData.WaitForPlayerProfile(player):await()

	if not resolved then
		error(`Failed to resolve player data!`)
	end

	return data
end

function PlayerClass.new(player: Player)
	local self = setmetatable({}, PlayerClass)

	self.data = waitForPlayerData(player)
	self.janitor = Maid.new()
	self.player = player
	self.playerWeapon = playerWeapon.new(self.player, self.data)
	self.lean = lean.new(self.player, self.data)

	print(`player class created for {player.Name}`)

	return self
end

function PlayerClass:OnCharacterDied() end

function PlayerClass:UpdateCharacter(character: Model?)
	if character then
		local choosenGloves = chooseRandomFromArray(possibleGloves)
		if choosenGloves == "None" then
			choosenGloves = nil
		end

		local choosenWatch = chooseRandomFromArray(possibleWatches)
		if choosenWatch == "None" then
			choosenWatch = nil
		end

		self.data.producer.setCurrentGloves(choosenGloves)
		self.data.producer.setCurrentWatch(choosenWatch)

		Watch:ApplyToCharacter(character, self.data.producer:getState().currentWatch)
		Gloves:ApplyToCharacter(character, self.data.producer:getState().currentGloves)
	end
end

function PlayerClass:Update(deltaTime: number) end

function PlayerClass:Destroy()
	self.lean:Destroy()
	self.janitor:Destroy()
	self.janitor = nil
end

return PlayerClass
