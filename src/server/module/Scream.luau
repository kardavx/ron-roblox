local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local NPCManager = require(ServerScriptService.classes.NPCManager)
local Bridgenet2 = require(ReplicatedStorage.package.Bridgenet2)

Bridgenet2.ReferenceBridge("OnScream"):Connect(function(player)
	local character = player.Character
	if not character then
		return
	end

	SoundService["FBI OPEN UP"]:Play()

	NPCManager:OnScream(character:GetPivot())
end)

Bridgenet2.ReferenceBridge("OnSurrender"):Connect(function(player, character)
	NPCManager:OnSurrender(character)
end)

return {}
