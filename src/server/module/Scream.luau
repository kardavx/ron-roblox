local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local NPCManager = require(ServerScriptService.classes.NPCManager)
local Bridgenet2 = require(ReplicatedStorage.package.Bridgenet2)

Bridgenet2.ReferenceBridge("OnScream"):Connect(function(player: Player)
	local character = player.Character
	if not character then
		return
	end

	SoundService["FBI OPEN UP"]:Play()

	NPCManager:OnScream(player, character:GetPivot())
end)

Bridgenet2.ReferenceBridge("OnSurrender"):Connect(function(player, character)
	NPCManager:OnSurrender(player, character)
end)

Bridgenet2.ReferenceBridge("OnArrest"):Connect(function(player, character)
	NPCManager:OnArrest(player, character)
end)

return table.freeze({})
