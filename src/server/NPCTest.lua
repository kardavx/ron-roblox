local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local chooseRandomFromArray = require(ReplicatedStorage.Shared.util.chooseRandomFromArray)
local NPCManager = require(ServerScriptService.classes.NPCManager)
local Scream = require(ServerScriptService.module.Scream)
NPCManager.new()

local availibleNPCs = { "Tonya", "Patrick" }

for _, npcSpawnPoint: BasePart in CollectionService:GetTagged("NPCSpawnPoint") do
	NPCManager:CreateNPC(
		"Civilian",
		chooseRandomFromArray(availibleNPCs),
		npcSpawnPoint.CFrame,
		math.random(),
		math.random()
	)
end

return table.freeze({})
