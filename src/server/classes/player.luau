local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local lean = require(ServerScriptService.classes.lean)
local ServerPlayerData = require(ServerScriptService.module.ServerPlayerData)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)
local Maid = require(ReplicatedStorage.package.Maid)

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
		Data: ServerPlayerData.ServerPlayerProfile,
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
	self.lean = lean.new(self.player, self.data)

	print(`player class created for {player.Name}`)

	return self
end

function PlayerClass:OnCharacterDied() end

function PlayerClass:UpdateCharacter(character: Model?) end

function PlayerClass:Update(deltaTime: number)
	self.lean:Update(deltaTime)
end

function PlayerClass:Destroy()
	self.janitor:Destroy()
	self.janitor = nil
end

return PlayerClass
