local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerPlayerData = require(ServerScriptService.module.ServerPlayerData)
local GameTypes = require(ReplicatedStorage.Shared.types.GameTypes)

export type Class = {
	__index: Class,
	new: (player: Player, data: ServerPlayerData.ServerPlayerProfile) -> Object,
} & GameTypes.ServerMethods<Object>

export type Object = typeof(setmetatable({} :: {}, {} :: Class))

local Weapon: Class = {} :: Class
Weapon.__index = Weapon

function Weapon.new(player: Player, data: ServerPlayerData.ServerPlayerProfile)
	local self = setmetatable({}, Weapon)

	return self
end

return Weapon
