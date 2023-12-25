local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
		janitor: Maid.Maid,
		player: Player,
	},
	{} :: Class
))

local PlayerClass: Class = {} :: Class
PlayerClass.__index = PlayerClass

function PlayerClass.new(player: Player)
	local self = setmetatable({}, PlayerClass)

	self.janitor = Maid.new()
	self.player = player

	return self
end

function PlayerClass:Update(deltaTime: number) end

function PlayerClass:Destroy()
	self.janitor:Destroy()
	self.janitor = nil
end

return PlayerClass
